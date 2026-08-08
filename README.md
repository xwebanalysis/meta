<h1 align="center">XWA — X Web Analysis</h1>

<div align="center">
<p><em>Modular web analysis ecosystem — each tool lives in its own repository under the <a href="https://github.com/xwebanalysis">xwebanalysis</a> organization.</em></p>
</div>

<hr>

## Repositories

| Repo | Focus | Stack | Status |
|------|-------|-------|--------|
| [samurai](https://github.com/xwebanalysis/samurai) | Web cybersecurity analysis | Angular + FastAPI/Python + Rust TUI | Released |
| [shinobi](https://github.com/xwebanalysis/shinobi) | Stealth web scraping with anti-blocking | Rust (Axum) + Angular + Python extractor | Released |
| [tengu](https://github.com/xwebanalysis/tengu) | Web quality auditor | Rust (Axum) + Angular | Released |
| [kensei](https://github.com/xwebanalysis/kensei) | Web technology stack profiler | Angular + FastAPI/Python | Planned |
| [kabuki](https://github.com/xwebanalysis/kabuki) | WAF and CDN analysis | TBD | Planned |
| [yari](https://github.com/xwebanalysis/yari) | API security testing | TBD | Planned |
| [musha](https://github.com/xwebanalysis/musha) | Web content and DOM analysis | Angular + FastAPI/Python | In development |
| [azuma](https://github.com/xwebanalysis/azuma) | Web form and authentication flow analyzer | Angular + FastAPI/Python | In development |
| [xwa-sdk](https://github.com/xwebanalysis/xwa-sdk) | Shared data schemas and API contracts | TBD | Planned |
| [meta](https://github.com/xwebanalysis/meta) | Ecosystem docs, roadmap, orchestration | — | — |

## Getting Started

Each tool is self-contained with its own Docker Compose setup. Clone and run any tool individually:

```bash
git clone https://github.com/xwebanalysis/<tool>.git
cd <tool>
docker compose up
```

See the [ROADMAP](ROADMAP.md) for cross-module integration plans.
