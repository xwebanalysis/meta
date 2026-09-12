# XWA Shared Contracts

The canonical definitions live in [xwa-sdk](https://github.com/xwebanalysis/xwa-sdk) (`schemas/`). This document summarizes the runtime conventions every module follows.

## REST

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/` | Service info: `{"status":"ok","service":"<tool>","version":"X.Y.Z"}` |
| GET | `/api/health` | `{"status","database","version","tool"}` (503 when the DB is down) |
| GET | `/api/analyses` | List recent analyses (persisted ids as strings) |
| GET | `/api/analyses/{id}` | Analysis detail with findings/items |
| DELETE | `/api/analyses/{id}` | Delete one analysis (cascades) |
| GET | `/api/analyses/{id}/export?format=json\|csv` | Download export (`Content-Disposition`) |
| POST | `/api/<domain>/<action>` | Start work, body `{"target": "..."}` plus module options |
| POST | `/api/auth/token` | Issue a JWT when `<TOOL>_JWT_SECRET` is set |

Errors always use the `error.json` envelope:

```json
{"error": {"code": "UPSTREAM_ERROR", "message": "…", "detail": {}, "retryable": true}}
```

HTTP status mapping: `400` invalid input, `401/403` auth, `404` missing, `422` validation, `429` rate limit, `502/503` upstream/database.

## Streaming

WebSocket path convention: `/api/<domain>/live?target=...` (shinobi uses SSE at `/api/jobs/{id}/stream`). Frames are `Event` envelopes:

```json
{"seq": 7, "type": "item_found", "tool": "kabuki", "analysis_id": "42",
 "ts": "2026-09-12T10:00:00Z", "payload": {"vendor": "Cloudflare"}}
```

Lifecycle: `analysis_started` → `analysis_progress`/`log`/`item_found*` → `analysis_completed` | `analysis_error`.
`analysis_error.payload` is a top-level `Error` object.

## Findings

Unified severity scale: `pass < info < low < medium < high < critical`.

Module mapping examples: tengu `Pass→pass, Info→info, Warning→medium, Error→high`; kensei confidence `low→info, medium→medium, high→high`.

## Security defaults

- CORS restricted via `XWA_CORS_ORIGINS` (default localhost/LAN), `allow_credentials=False`.
- Rate limiting per process (default 120 req/min, `/api/health` exempt).
- Optional JWT (`<TOOL>_JWT_SECRET`, `<TOOL>_AUTH_PASSWORD`) also enforced on WebSockets when configured.
- Respectful scanning: request budgets, jitter, cancellation, no destructive payloads by default.
