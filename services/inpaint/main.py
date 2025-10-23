from __future__ import annotations

import asyncio
import json
import os
from typing import Any, Dict, List

import httpx
from fastapi import FastAPI, UploadFile, File, Form, HTTPException

SIDECAR_URL = os.getenv("INPAINT_SIDECAR_URL", "http://sidecar:7869")
REQUEST_TIMEOUT = float(os.getenv("INPAINT_TIMEOUT_SECONDS", "120"))
MAX_RETRIES = int(os.getenv("INPAINT_MAX_RETRIES", "3"))
RETRY_BACKOFF = float(os.getenv("INPAINT_RETRY_BACKOFF", "2"))

app = FastAPI(title="inpaint", version="0.2.0", docs_url=None)


def _parse_masks(raw: str) -> List[Dict[str, Any]]:
    if not raw:
        return []
    try:
        value = json.loads(raw)
        if isinstance(value, list):
            return value
    except json.JSONDecodeError as exc:  # pragma: no cover - validation path
        raise HTTPException(status_code=400, detail=f"Invalid masks payload: {exc.msg}") from exc
    raise HTTPException(status_code=400, detail="Masks payload must be a list")


@app.get("/health")
def health() -> Dict[str, Any]:
    return {"service": "inpaint", "status": "ok", "sidecar": SIDECAR_URL}


async def _call_sidecar(image_bytes: bytes, filename: str, content_type: str, masks: List[Dict[str, Any]]) -> Dict[str, Any]:
    files = {
        "image": (
            filename or "page.png",
            image_bytes,
            content_type or "application/octet-stream",
        )
    }
    data = {"masks": json.dumps(masks)}
    attempt = 0
    delay = 1.0
    last_error: Exception | None = None

    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT) as client:
        while attempt < MAX_RETRIES:
            try:
                response = await client.post(f"{SIDECAR_URL.rstrip('/')}/run", data=data, files=files)
                if response.status_code in {429, 500, 502, 503, 504}:
                    raise httpx.HTTPStatusError("Sidecar returned retryable status", request=response.request, response=response)
                response.raise_for_status()
                payload = response.json()
                payload.setdefault("sidecar_url", SIDECAR_URL)
                return payload
            except (httpx.HTTPStatusError, httpx.TransportError, httpx.TimeoutException) as exc:
                last_error = exc
                attempt += 1
                if attempt >= MAX_RETRIES:
                    break
                await asyncio.sleep(delay)
                delay *= RETRY_BACKOFF
            except json.JSONDecodeError as exc:
                raise HTTPException(status_code=502, detail=f"Sidecar returned non-JSON response: {exc.msg}") from exc

    detail = "Sidecar request failed" if last_error is None else f"Sidecar request failed: {last_error}"
    raise HTTPException(status_code=502, detail=detail)


@app.post("/run")
async def run(file: UploadFile = File(...), masks: str = Form("[]")) -> Dict[str, Any]:
    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Empty image payload")
    parsed_masks = _parse_masks(masks)
    return await _call_sidecar(image_bytes, file.filename or "page.png", file.content_type or "image/png", parsed_masks)
