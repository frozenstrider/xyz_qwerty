# Tasks & Milestones (for Codex)

## Milestone A — Bring-up (services up, end-to-end stub OK)
1. Copy `infra/docker/.env.example` → `.env`; run `docker compose up --build -d`.
2. Verify health endpoints on ports 8000..8005.
3. In `services/api_gateway`, run e2e: POST `/translate` with a sample image URL. Confirm progress states.

## Milestone B — Implement pipeline runners
1. ai_vision:
   - Wire DBNet++ (text/SFX polygons) — model path via env `DBNET_WEIGHTS`.
   - Integrate Mask2Former for balloons/panels — two endpoints; share the model.
   - Implement container fusion (grow polygons to bubble borders).
2. ai_ocr_trans:
   - Hook Manga_OCR for `/ocr/run` (CUDA), return spans with confidences and orientation.
   - Implement `/typeset/layout` to fit text inside containers (autosize, padding, outline).
3. vl_panels:
   - Load Qwen3‑VL‑8B via transformers; implement `/describe` with ≤20‑word cap and JSON guard.
4. mt_gateway:
   - Call Ollama (Qwen3‑30B/Gemma‑30B) with prompt templates that include panel summaries.
   - Enforce JSON‑only responses; retry with temperature=0 on schema failures.
5. inpaint:
   - Proxy to Manga‑Lama sidecar at `INPAINT_SIDECAR_URL`, handle 429/5xx with backoff.
6. api_gateway:
   - Replace stub orchestrator with robust chain (async jobs), persist artifacts to MinIO, stream progress.

## Milestone C — Reader app wiring
- Implement screens and call the gateway:
  - Purchase/Library (stubbed).
  - Reader: vertical/double/page, progress display for translation job.
  - Settings: language, tier, name mapping toggle (policy-gated).

## Acceptance Checks
- POST `/translate` runs full chain and returns composited page.
- Re-running on same input hits cache for earlier steps.
- Panel order & balloon placement match heuristics for RTL manga.
