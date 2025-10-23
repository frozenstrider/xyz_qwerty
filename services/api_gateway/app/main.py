from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
import httpx, uuid, asyncio
from enum import Enum
from .config import settings

app = FastAPI(title="API Gateway", version="0.2.0")

@app.get("/health")
def health():
    return {"service": "api_gateway", "status": "ok"}

class Stage(str, Enum):
    QUEUED="QUEUED"
    DETECT_DBNET="DETECT_DBNET"
    SEG_BALLOONS="SEG_BALLOONS"
    SEG_PANELS="SEG_PANELS"
    FUSE_CONTAINERS="FUSE_CONTAINERS"
    OCR="OCR"
    VL="VL"
    MT="MT"
    INPAINT="INPAINT"
    TYPESET="TYPESET"
    COMPOSITE="COMPOSITE"

JOBS: dict[str, dict] = {}

@app.post("/translate")
async def translate(image: UploadFile, target_lang: str = Form("en"), tier: str = Form("premium")):
    job_id = str(uuid.uuid4())
    JOBS[job_id] = {"stage": Stage.QUEUED, "target_lang": target_lang, "tier": tier}
    image_bytes = await image.read()

    async with httpx.AsyncClient(timeout=120) as http:
        try:
            JOBS[job_id]["stage"] = Stage.DETECT_DBNET
            dbnet = (await http.post(f"{settings.ai_vision_url}/dbnet/detect", files={"file": image_bytes})).json()

            JOBS[job_id]["stage"] = Stage.SEG_BALLOONS
            balloons = (await http.post(f"{settings.ai_vision_url}/seg/balloons", files={"file": image_bytes})).json()

            JOBS[job_id]["stage"] = Stage.SEG_PANELS
            panels = (await http.post(f"{settings.ai_vision_url}/seg/panels", files={"file": image_bytes})).json()

            JOBS[job_id]["stage"] = Stage.FUSE_CONTAINERS
            fuse = (await http.post(f"{settings.ai_vision_url}/containers/fuse",
                        json={"polygons_dbnet": dbnet.get("polygons", []),
                              "masks_balloons": balloons.get("masks", [])})).json()

            JOBS[job_id]["stage"] = Stage.OCR
            ocr = (await http.post(f"{settings.ai_ocr_url}/ocr/run", files={"file": image_bytes},
                                   data={"polygons": ""})).json()

            JOBS[job_id]["stage"] = Stage.VL
            vl = (await http.post(f"{settings.vl_url}/describe",
                        json={"panels": panels.get("masks", [])})).json()

            JOBS[job_id]["stage"] = Stage.MT
            mt = (await http.post(f"{settings.mt_url}/mt/translate",
                        json={"balloons": ocr.get("spans", []),
                              "panel_context": vl.get("summaries", []),
                              "lang": target_lang, "tier": tier})).json()

            JOBS[job_id]["stage"] = Stage.INPAINT
            inp = (await http.post(f"{settings.inpaint_url}/run",
                        files={"file": image_bytes},
                        data={"masks": ""})).json()

            JOBS[job_id]["stage"] = Stage.TYPESET
            ts = (await http.post(f"{settings.ai_ocr_url}/typeset/layout",
                        json={"containers": fuse.get("containers", []),
                              "translations": mt.get("translations", [])})).json()

            JOBS[job_id]["stage"] = Stage.COMPOSITE
            return {"job_id": job_id, "status": "done", "outputs": {"ocr": ocr, "mt": mt, "layout": ts}}
        except Exception as e:
            JOBS[job_id]["error"] = str(e)
            return JSONResponse({"job_id": job_id, "status": "error", "error": str(e)}, status_code=500)

@app.get("/translate/{job_id}")
def job_status(job_id: str):
    return JOBS.get(job_id, {"status": "unknown"})
