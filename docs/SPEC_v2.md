# Manga App — Product & Technical Spec v2 (updated pipeline)

This spec reflects the pipeline where DBNet++ → Manga_OCR → Manga‑Lama sidecar (inpaint) →
Balloon/Panel detection (replacing YOLO with Mask2Former) → Container fusion →
Qwen3‑VL‑8B panel summaries → Ollama (Qwen3‑30B/Gemma‑30B) translation → Typesetting.

## Monorepo
```
Manga_App/
  apps/reader_app/         # Flutter shell
  services/
    api_gateway/           # public REST, orchestration, job status
    ai_vision/             # DBNet++, Mask2Former (balloons+panels), container fusion
    ai_ocr_trans/          # OCR (Manga_OCR) + typesetting
    mt_gateway/            # Ollama-backed translation (Qwen3/Gemma), prompt guards
    vl_panels/             # Qwen3‑VL‑8B panel summarizer
    inpaint/               # proxy to Manga‑Lama sidecar (HTTP), retries/batching
    search/                # semantic search (stub)
  infra/docker/            # docker compose + .env.example
  docs/                    # specs & tasks
```

## Internal Contracts (summary)
- `ai_vision`:
  - POST `/dbnet/detect` → polygons for text/SFX
  - POST `/seg/balloons` → balloon masks (Mask2Former; stubbed now)
  - POST `/seg/panels`   → panel masks + suggested order
  - POST `/containers/fuse` → merged containers grown to bubble borders
- `vl_panels`:
  - POST `/describe` → ≤20‑word summaries per panel
- `ai_ocr_trans`:
  - POST `/ocr/run` → OCR spans (Manga_OCR)
  - POST `/typeset/layout` → line boxes inside containers
- `mt_gateway`:
  - POST `/mt/translate` → translations per balloon (tier, model selectable)
- `inpaint`:
  - POST `/run` → inpainted page image via Manga‑Lama sidecar

`api_gateway` exposes a single public operation:
- `POST /translate` → orchestrates the above steps per page with progress states:
  `QUEUED → DETECT_DBNET → SEG_BALLOONS → SEG_PANELS → FUSE_CONTAINERS → OCR → VL → MT → INPAINT → TYPESET → COMPOSITE`

## Storage & Caching
Artifacts are written to object storage (MinIO in dev) with keys:
`{page_sha256}/{stage}@{version}.json|png`

## Notes for Implementers
- Replace all stubs with real model runners. Each service already has FastAPI stubs.
- Keep step‑local caching (idempotent endpoints) and retry on transient failures.
- Sidecar: do not call `localhost` from the gateway; call `inpaint` service, which calls the sidecar URL from env.
