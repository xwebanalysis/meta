# Changelog

All notable changes to the XWA project will be documented in this file.

## 0.3.0 - 2026-09-12

### Added

- **xwa-sdk** v0.2.0 -- offline JSON Schema validation, nullable optionals fixed, WAF/CDN/challenge/rate-limit/API-endpoint items, Rust binding and TypeScript tests
- **kabuki** v0.1.0 -- WAF and CDN analysis module (fingerprinting, challenge detection, rate-limit profiling, CDN mapping) with Angular 22 frontend
- **yari** v0.1.0 -- API security testing module (REST/OpenAPI, GraphQL, gRPC detection, safe fuzzing, auth testing) with Angular 22 frontend
- Workspace orchestrator `xwa.sh` (up/down/status/open/logs/test) and `verify.sh` full test suite
- Local-first SQLite mode for every Python and Rust backend; PostgreSQL remains optional via Docker Compose

### Changed

- **samurai**, **kensei**, **musha**, **azuma** backends standardized: `DB_DRIVER`/`DB_PATH`, `/api/health`, `/api/analyses*`, xwa-sdk `Event` streaming, CORS/rate-limit hardening, pytest suites
- **shinobi** and **tengu** upgraded to Axum 0.8 with SQLite persistence, xwa-sdk contracts, robust schedulers/rate limiting and tests
- Every frontend upgraded to Angular 22 with Nothing Design tokens, self-hosted fonts, `environment.ts` API configuration and Vitest suites
- Per-tool launchers default to `local` (SQLite); distinct ports per module for simultaneous runs
- Documentation updated per repository; ecosystem docs added under `meta/docs/`

### Security

- Dependency refresh across all modules (FastAPI/SQLAlchemy/pydantic, Axum/reqwest/sqlx, Angular 22); `npm audit --omit=dev` reports 0 vulnerabilities in every frontend
- Anti-blocking guardrails: request budgets, jittered delays, kill timeouts, opt-in active probing

## 0.2.0 - 2026-07-04

### Added

- ROADMAP.md with integrated submodule release pipeline and cross-module integration planning
- README.md with submodule overview table and getting started guide
- CHANGELOG.md for project-level release tracking

## 0.1.0 - 2026-06-28

### Added

- Initial XWA monorepo structure
- **samurai** v0.1.0 -- Web cybersecurity analysis platform with port scanning, web reconnaissance, DAST crawling, and dual-interface (web + TUI)
- **shinobi** v0.1.0 -- Stealth web scraper with recursive crawling, JavaScript rendering, asset download, and multi-layer anti-blocking system
