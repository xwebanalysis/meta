# XWA Deployment Guide

## Local / single host (recommended)

Each module is self-contained. Run `./<tool>.sh local` (SQLite) behind a reverse proxy if needed. For the full suite, `./xwa.sh up` starts all eight modules on fixed ports.

## Docker Compose (per module)

Every tool ships a `docker-compose.yml`:

```bash
./<tool>.sh docker
```

- Python modules build with `python:3.13-slim`; Rust modules with multi-stage `rust` → `debian` builds that also build the Angular UI.
- The compose stacks provide PostgreSQL 17 and set `DB_DRIVER=postgresql`; SQLite is ignored in this mode.
- samurai's image bundles Playwright Chromium, nmap, sqlmap and nuclei.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `DB_DRIVER` | `sqlite` (default local) or `postgresql` |
| `DB_PATH` | SQLite file path (`<repo>/<tool>.db` by default) |
| `DB_HOST/DB_NAME/DB_USER/DB_PASS` | PostgreSQL connection |
| `<TOOL>_JWT_SECRET` | Enables JWT auth (`<TOOL>` = `SAMURAI`, `KENSEI`, …) |
| `<TOOL>_AUTH_PASSWORD` | Password for `POST /api/auth/token` |
| `<TOOL>_RATE_LIMIT_MAX` | Requests per minute per IP (default 120) |
| `XWA_CORS_ORIGINS` | Comma-separated allowed origins (default localhost/LAN) |
| `PORT` | Override the backend port |
| `TENGU_DB_PATH` / `SHINOBI_DB_PATH` | Explicit SQLite paths for the Rust modules |

## Hardening checklist

1. Set `<TOOL>_JWT_SECRET` and a strong `<TOOL>_AUTH_PASSWORD` before exposing any API.
2. Restrict `XWA_CORS_ORIGINS` to the real frontend origins.
3. Put a reverse proxy (nginx/Caddy) in front for TLS; WebSockets require `Upgrade` headers.
4. Keep scans within authorization: active kabuki/yari probing is opt-in, respect request budgets.
5. Back up `<tool>.db` (or PostgreSQL) regularly; every module exposes JSON/CSV export.

## Notes

- The Rust modules serve the compiled Angular UI themselves (`static/`); rebuild with `npm run build` after frontend changes.
- xwa-sdk is installed from the sibling checkout during local development and from git in Docker builds.
