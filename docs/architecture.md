# XWA Architecture Overview

## Modules

| Module | Domain | Backend | Frontend | Storage |
|--------|--------|---------|----------|---------|
| samurai | Cybersecurity (nmap, recon, DAST) | FastAPI + Playwright/nmap/sqlmap/nuclei + Rust TUI | Angular 22 | SQLite (PostgreSQL optional) |
| shinobi | Stealth scraping + mirroring | Rust Axum 0.8 + Python extractor (spaCy/httrack) | Angular 22 (served by Axum) | SQLite (rusqlite) |
| tengu | Web quality audit (perf, SEO, a11y, best practices) | Rust Axum 0.8 | Angular 22 (served by Axum) | SQLite (sqlx) |
| kensei | Technology stack profiler | FastAPI | Angular 22 | SQLite |
| kabuki | WAF and CDN analysis | FastAPI | Angular 22 | SQLite |
| yari | API security testing (REST/GraphQL/gRPC) | FastAPI | Angular 22 | SQLite |
| musha | Content/DOM + third-party inventory | FastAPI | Angular 22 | SQLite |
| azuma | Forms, OAuth and session analysis | FastAPI | Angular 22 | SQLite |

```
                     +-----------------------------+
                     |        xwa-sdk 0.2.0         |
                     |  JSON Schemas + bindings     |
                     |  (Python / TypeScript / Rust)|
                     +--------------+--------------+
                                    |
        +---------------------------+----------------------------+
        |                           |                            |
  Python modules               Rust modules                 Frontends
  samurai kensei              shinobi tengu                Angular 22
  kabuki yari                 samurai-tui                  (Nothing Design)
  musha azuma
        |                           |                            |
        +------------- REST + WS/SSE Event ----------------------+
                                    |
                         +----------+-----------+
                         |  xwa.sh orchestrator  |
                         |  (workspace root)     |
                         +----------------------+
```

## Data contracts

Every module speaks the same language:

- **`Analysis`** — one unit of work (`id` string, `tool`, `target`, `status`, timestamps, summary, error).
- **`Finding`** — one observation with unified severity `pass|info|low|medium|high|critical`.
- **`Event`** — streaming envelope (`seq`, `type`, `tool`, `analysis_id`, `ts`, `payload`).
- **`Error`** — `{code, message, detail, retryable}`.
- **Module items** — `link`, `technology`, `route`, `dependency`, `waf`, `cdn`, `challenge`, `rate_limit`, `api_endpoint`.

See [contracts.md](contracts.md) for the wire-level REST/WS conventions.

## Runtime model

- **Local-first**: SQLite in WAL mode, `create_all` schema bootstrap with a `schema_meta` version row; PostgreSQL available behind `DB_DRIVER=postgresql` / Docker Compose.
- **Streaming**: WebSocket or SSE with `Event` envelopes; `analysis_id` always references the persisted row.
- **Long-running work**: async tasks (Python) or Tokio tasks (Rust) with cancellation; no Redis/Celery requirement.
- **Safety**: per-process rate limiting, request budgets, jittered delays, subprocess timeouts. Active probing in kabuki/yari requires explicit opt-in.

## Ports

`samurai 8000/4200`, `kensei 8010/4210`, `musha 8020/4220`, `azuma 8030/4230`, `kabuki 8040/4240`, `yari 8050/4250`, `shinobi 8060`, `tengu 8070`.
