from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Dict, Any

app = FastAPI(title="vl_panels", version="0.2.0")

class DescribeIn(BaseModel):
    panels: List[Dict[str, Any]] = []

@app.get("/health")
def health():
    return {"service":"vl_panels","status":"ok"}

@app.post("/describe")
def describe(body: DescribeIn):
    # TODO: load Qwen3-VL-8B; stub 20-word summaries
    sums = [{"panel_id": p.get("id","p?"), "text": "Two characters talking in a room about a secret plan."} for p in body.panels]
    return {"summaries": sums, "model":"qwen3-vl-8b@stub"}
