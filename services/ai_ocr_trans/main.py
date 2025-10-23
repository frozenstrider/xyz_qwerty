from fastapi import FastAPI, UploadFile, File
from typing import Dict, Any, List

app = FastAPI(title="ai_ocr_trans", version="0.2.0")

@app.get("/health")
def health():
    return {"service": "ai_ocr_trans", "status": "ok"}

@app.post("/ocr/run")
async def ocr_run(file: UploadFile = File(...)) -> Dict[str, Any]:
    # TODO: integrate Manga_OCR; this is stub text
    return {"engine":"manga_ocr@stub","spans":[{"id":"b1","text":"こんにちは","conf":0.92}]}

@app.post("/typeset/layout")
async def typeset_layout(body: Dict[str, Any]):
    # TODO: implement layout inside containers given translations
    translations = {t["id"]: t.get("text","") for t in body.get("translations", [])}
    return {"lines":[{"container_id": c["id"], "bboxes":[[16,16,112,32]], "text": translations.get("b1","Hello!")}
                     for c in body.get("containers", [])]}
