# XWA Development Roadmap

This document tracks the strategic steps required to evolve XWA into a full-scale modular web analysis ecosystem.
This file is formatted to be synced automatically with GitHub Issues using the `xgh` roadmap standard.

## Submodule Release Pipeline <!-- phase:releases -->

- [x] samurai v0.1.0 -- Web cybersecurity analysis platform (port scanning, web recon, DAST)
- [x] shinobi v0.1.0 -- Stealth web scraper with anti-blocking system
- [x] kensei v0.1.0 -- Web technology stack profiler (JS bundle analysis, SPA route discovery, server fingerprinting)
- [x] tengu v0.1.0 -- Web quality auditor (Core Web Vitals, WCAG compliance, structured data validation)
- [x] kabuki v0.1.0 -- WAF and CDN analysis module (fingerprinting, challenge mechanism analysis, rate-limit profiling)
- [x] yari v0.1.0 -- API security testing module (REST/GraphQL/gRPC endpoint discovery, fuzzing, auth testing)
- [x] musha v0.1.0 -- Web content and DOM analysis module (structural diffing, third-party inventory, content drift)
- [x] azuma v0.1.0 -- Web form and authentication flow analyzer (form discovery, OAuth mapping, session analysis)

All eight modules now run locally with SQLite, emit xwa-sdk contracts and ship tests + docs.

## Cross-Module Integration <!-- phase:integration -->

- [x] Define standard data exchange schemas across all submodules (xwa-sdk v0.2.0)
- [ ] Angular shared component library consumed by all frontends (Nothing Design tokens are standardized; components are still per-repo)
- [x] Unified XWA orchestration for local development (`xwa.sh`, SQLite-first)
- [ ] Unified XWA docker-compose orchestration (per-tool compose exists, no single stack)
- [ ] XWA API gateway for inter-module communication
- [ ] Common authentication and authorization layer (each module supports optional JWT via `<TOOL>_JWT_SECRET`)
- [ ] Centralized result aggregation and correlation pipeline

## Infrastructure <!-- phase:infrastructure -->

- [x] XWA workspace orchestrator script (`xwa.sh` + `verify.sh`) for checked-out sibling repositories
- [ ] CI/CD pipeline for cross-module integration testing
- [ ] Shared documentation site with per-module sections
- [x] Common design system (Nothing Design) tokens applied to every frontend, fonts self-hosted
- [ ] Shared Angular component library extracted from the per-repo `core/` + `shared/` structure
- [ ] Release automation for coordinated version bumps

## Documentation <!-- phase:docs -->

- [x] Architecture overview with module dependency graph
- [x] Submodule contribution guide (local-first workflow)
- [x] API contract specifications for cross-module communication (xwa-sdk schemas + REST/WS conventions)
- [x] Deployment guide for full XWA stack
