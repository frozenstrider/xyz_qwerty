from __future__ import annotations

import json
import os
from typing import Any, Dict, List

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, field_validator

OLLAMA_BASE = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "qwen3:latest")
REQUEST_TIMEOUT = float(os.getenv("OLLAMA_TIMEOUT_SECONDS", "120"))

app = FastAPI(title="mt_gateway", version="0.3.0", docs_url=None)


class Balloon(BaseModel):
    id: str = Field(..., description="Unique balloon identifier")
    text: str = Field(..., description="Source text to translate")

    @field_validator("text")
    @classmethod
    def _strip(cls, value: str) -> str:
        cleaned = value.strip()
        if not cleaned:
            raise ValueError("Balloon text cannot be empty")
        return cleaned


class PanelCtx(BaseModel):
    panel_id: str | int | None = None
    text: str = ""


class MTIn(BaseModel):
    balloons: List[Balloon]
    panel_context: List[PanelCtx] = []
    lang: str = Field("en", description="Target language code")
    tier: str = Field("premium", description="Translation tier")
    model: str | None = Field(None, description="Override Ollama model tag")

    @field_validator("balloons")
    @classmethod
    def _ensure_balloons(cls, value: List[Balloon]) -> List[Balloon]:
        if not value:
            raise ValueError("At least one balloon is required")
        return value


def _build_prompt(payload: MTIn) -> str:
    ctx_lines = []
    for ctx in payload.panel_context:
        prefix = f"Panel {ctx.panel_id}:" if ctx.panel_id is not None else "Panel:"
        ctx_lines.append(f"- {prefix} {ctx.text.strip()}")
    context_block = "\n".join(ctx_lines) if ctx_lines else "- No panel summaries available."

    balloon_lines = []
    for idx, balloon in enumerate(payload.balloons, start=1):
        balloon_lines.append(f"{idx}. (id={balloon.id}) {balloon.text}")
    balloon_block = "\n".join(balloon_lines)

    return (
        "You are an expert manga translator. Translate each balloon faithfully, keeping tone, honorifics, "
        "and cultural nuance. Return STRICT JSON with the schema: {\"translations\": [{\"id\": string, \"text\": string}]} "
        "and no surrounding prose. Use double quotes, escape characters properly, and never include extra keys.\n"
        f"Target language: {payload.lang}. Tier: {payload.tier}.\n"
        "Panel context:\n"
        f"{context_block}\n\n"
        "Balloon texts to translate:\n"
        f"{balloon_block}\n"
        "Respond only with the JSON object."
    )


async def _call_ollama(model: str, prompt: str, temperature: float, top_p: float) -> str:
    payload = {
        "model": model,
        "messages": [
            {"role": "user", "content": prompt},
        ],
        "stream": False,
        "options": {
            "temperature": temperature,
            "top_p": top_p,
        },
    }
    async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT) as client:
        response = await client.post(f"{OLLAMA_BASE.rstrip('/')}/api/chat", json=payload)
        response.raise_for_status()
        body = response.json()
    message = body.get("message", {}).get("content")
    if not message:
        raise HTTPException(status_code=502, detail="Ollama returned empty response")
    return message


def _extract_json_maybe(text: str) -> Dict[str, Any]:
    snippet = text.strip()
    if snippet.startswith("```"):
        parts = snippet.split("```")
        if len(parts) > 1:
            candidate = parts[1]
            if candidate.startswith("json"):
                candidate = candidate[4:]
            snippet = candidate.strip()
    parsed = json.loads(snippet)
    if not isinstance(parsed, dict):
        raise ValueError("Response must be a JSON object")
    if "translations" not in parsed:
        raise ValueError("Missing 'translations' key")
    return parsed


async def _translate_with_retries(payload: MTIn) -> Dict[str, Any]:
    model_name = payload.model or DEFAULT_MODEL
    prompt = _build_prompt(payload)

    attempts = [
        {"temperature": 0.7, "top_p": 0.9},
        {"temperature": 0.0, "top_p": 0.1},
    ]
    last_error: Exception | None = None

    for opts in attempts:
        try:
            message = await _call_ollama(model_name, prompt, **opts)
            parsed = _extract_json_maybe(message)
            return {"model": model_name, "translations": parsed.get("translations", [])}
        except HTTPException:
            raise
        except (httpx.HTTPStatusError) as exc:  # pragma: no cover - network path
            detail = exc.response.text if exc.response is not None else str(exc)
            raise HTTPException(status_code=exc.response.status_code if exc.response else 502, detail=detail) from exc
        except httpx.HTTPError as exc:  # pragma: no cover - network path
            raise HTTPException(status_code=502, detail=str(exc)) from exc
        except Exception as exc:  # parsing errors, retry with safer settings
            last_error = exc
            continue

    raise HTTPException(status_code=502, detail=str(last_error) if last_error else "Translation failed")


@app.get("/health")
def health() -> Dict[str, Any]:
    return {"service": "mt_gateway", "status": "ok", "ollama": OLLAMA_BASE}


@app.post("/mt/translate")
async def translate(payload: MTIn) -> Dict[str, Any]:
    result = await _translate_with_retries(payload)
    balloon_ids = {balloon.id for balloon in payload.balloons}
    cleaned = []
    for item in result["translations"]:
        if not isinstance(item, dict):
            continue
        bid = item.get("id")
        text = item.get("text")
        if bid in balloon_ids and isinstance(text, str):
            cleaned.append({"id": bid, "text": text.strip()})
    missing = balloon_ids - {item["id"] for item in cleaned}
    if missing:
        raise HTTPException(status_code=502, detail=f"Missing translations for balloons: {sorted(missing)}")
    result["translations"] = cleaned
    return result
