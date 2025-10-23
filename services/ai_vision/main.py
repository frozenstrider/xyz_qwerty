from fastapi import FastAPI, UploadFile, File
from typing import List, Dict, Any

app = FastAPI(title="ai_vision", version="0.2.0")

@app.get("/health")
def health():
    return {"service": "ai_vision", "status": "ok"}

@app.post("/dbnet/detect")
async def dbnet_detect(file: UploadFile = File(...)) -> Dict[str, Any]:
    # TODO: call DBNet++ runner. Return polygons for text/SFX.
    return {"polygons": [{"id": 1, "points": [[10,10],[120,10],[120,40],[10,40]], "kind": "text"}],
            "version": "dbnetpp@stub"}

@app.post("/seg/balloons")
async def seg_balloons(file: UploadFile = File(...)) -> Dict[str, Any]:
    # TODO: Mask2Former balloons
    return {"masks": [{"id": 101, "rle": "STUB", "class": "balloon", "score": 0.95}]}

@app.post("/seg/panels")
async def seg_panels(file: UploadFile = File(...)) -> Dict[str, Any]:
    # TODO: Mask2Former panels
    return {"masks": [{"id": 201, "rle": "STUB", "class": "panel", "score": 0.99}], "order": [201]}

@app.post("/containers/fuse")
async def containers_fuse(payload: Dict[str, Any]):
    # TODO: Grow merged text containers to bubble borders
    return {"containers": [{"id": "c1", "polygon": [[12,12],[118,12],[118,38],[12,38]], "children_text_poly_ids":[1]}]}
