<h1 align="center">XWA — X Web Analyzer</h1>

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
| [xwa-sdk](https://github.com/xwebanalysis/xwa-sdk) | Shared data schemas and API contracts | TBD | Planned |
| [meta](https://github.com/xwebanalysis/meta) | This repo — ecosystem docs, roadmap, orchestration | — | — |

## Planned Tools

- **kabuki** — WAF and CDN analysis
- **yari** — API security testing
- **musha** — Web content and DOM analysis
- **azuma** — Web form and authentication flow analyzer

## Getting Started

Each tool is self-contained with its own Docker Compose setup. Clone and run any tool individually:

```bash
git clone https://github.com/xwebanalysis/<tool>.git
cd <tool>
docker compose up
```

See the [ROADMAP](ROADMAP.md) for cross-module integration plans.
