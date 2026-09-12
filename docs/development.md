# XWA Local Development

## Requirements

- Linux/macOS, `git`, `curl`
- Python 3.13 (`uv` recommended: `curl -LsSf https://astral.sh/uv/install.sh | sh`)
- Node 24 LTS (`mise` recommended: `curl https://mise.run | sh && mise use -g node@24`)
- Rust 1.8x with `cargo`, `clippy`, `rustfmt`
- Optional: `nmap`, `sqlmap`, `nuclei`, `httrack` for the full samurai/shinobi feature set

Every backend runs on SQLite by default; no Docker required.

## Single tool

```bash
cd kabuki
./kabuki.sh local            # SQLite backend :8040 + Angular dev server :4240
./kabuki.sh docker           # optional PostgreSQL stack
./clean.sh                   # remove venv, node_modules, local .db files
```

`local` is the default command in every `<tool>.sh`. Legacy flags (`--sqlite`, `--native`, `--fast`, `local backend`, …) remain as aliases.

## Whole ecosystem

With all repositories checked out under one directory:

```bash
./xwa.sh up                  # start all apps (distinct ports)
./xwa.sh status              # health + database state of every module
./xwa.sh open                # list URLs
./xwa.sh logs samurai        # tail one app
./xwa.sh down                # stop everything

./verify.sh                  # pytest + cargo test + npm test/build/audit
./verify.sh --quick          # skip builds and audits
```

The orchestrator exports the Node 24 toolchain automatically and stores logs/PIDs under `tmp/`.

## Tests per module

| Layer | Command |
|-------|---------|
| Python | `cd backend && .venv/bin/pytest -q` |
| Rust | `cargo test && cargo clippy -- -D warnings` |
| Angular | `cd frontend && npm test && npm run build` |

## Shared SDK during development

`musha`, `azuma`, `kabuki`, `yari`, `samurai` and `kensei` load `xwa-sdk` from the sibling repository when present (editable install performed by the launcher); otherwise they fall back to the documented `git+https` dependency.
