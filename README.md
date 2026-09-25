<h1 align="center">XWA — X Web Analysis</h1>

<div align="center">
<p><em>Modular web analysis ecosystem — each tool lives in its own repository under the <a href="https://github.com/xwebanalysis">xwebanalysis</a> organization.</em></p>
</div>

<hr>

## Repositories

| Repo | Focus | Stack | Status |
|------|-------|-------|--------|
| [samurai](https://github.com/xwebanalysis/samurai) | Web cybersecurity analysis | Angular 22 + FastAPI/Python + Rust TUI | Released (v2.5.0) |
| [shinobi](https://github.com/xwebanalysis/shinobi) | Stealth web scraping with anti-blocking | Rust (Axum 0.8) + Angular 22 + Python extractor | Released (v0.1.0) |
| [tengu](https://github.com/xwebanalysis/tengu) | Web quality auditor | Rust (Axum 0.8) + Angular 22 | Released (v0.2.0) |
| [kensei](https://github.com/xwebanalysis/kensei) | Web technology stack profiler | Angular 22 + FastAPI/Python | In development (v0.3.0) |
| [kabuki](https://github.com/xwebanalysis/kabuki) | WAF and CDN analysis | Angular 22 + FastAPI/Python | In development (v0.1.0) |
| [yari](https://github.com/xwebanalysis/yari) | API security testing | Angular 22 + FastAPI/Python | In development (v0.1.0) |
| [musha](https://github.com/xwebanalysis/musha) | Web content and DOM analysis | Angular 22 + FastAPI/Python | In development (v0.2.0) |
| [azuma](https://github.com/xwebanalysis/azuma) | Web form and authentication flow analyzer | Angular 22 + FastAPI/Python | In development (v0.3.0) |
| [xwa-sdk](https://github.com/xwebanalysis/xwa-sdk) | Shared data schemas and API contracts | JSON Schema + Python/TypeScript/Rust bindings | Active (v0.2.0) |
| [meta](https://github.com/xwebanalysis/meta) | Ecosystem docs, roadmap, orchestration | — | — |

## Getting Started (local-first)

Every tool runs 100% locally with SQLite. No Docker, Redis or external services required.

```bash
git clone https://github.com/xwebanalysis/<tool>.git
cd <tool>
./<tool>.sh local          # SQLite + native backend & frontend
```

When the whole ecosystem is checked out side by side, a single workspace orchestrator starts everything:

```bash
./meta/xwa.sh up           # start all apps on distinct ports
./meta/xwa.sh status       # health of every module
./meta/xwa.sh down         # stop everything
./meta/verify.sh           # run the full test suite (pytest + cargo + npm)
```

Both scripts live in this repository (run them from the directory that
contains all the tool repos checked out side by side) and need no Docker:
they create per-tool venvs, install `xwa-sdk` editably and start every
backend on its XWA port plus the Angular dev servers.

| App | Backend | Frontend | Storage |
|-----|--------:|---------:|---------|
| samurai | 8000 | 4200 | samurai.db |
| kensei | 8010 | 4210 | kensei.db |
| musha | 8020 | 4220 | musha.db |
| azuma | 8030 | 4230 | azuma.db |
| kabuki | 8040 | 4240 | kabuki.db |
| yari | 8050 | 4250 | yari.db |
| shinobi | 8060 | served by backend | shinobi.db |
| tengu | 8070 | served by backend | tengu.db |

Docker Compose remains available per tool (`./<tool>.sh docker`) for PostgreSQL-backed deployments.

## Documentation

- [Architecture overview](docs/architecture.md)
- [Shared contracts](docs/contracts.md)
- [Local development](docs/development.md)
- [Deployment](docs/deployment.md)
- [ROADMAP](ROADMAP.md) for cross-module integration plans
