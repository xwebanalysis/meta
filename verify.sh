#!/usr/bin/env bash
# verify.sh — full XWA ecosystem test suite (pytest + vitest + cargo + xwa-sdk).
#
# Run from the workspace root (the directory containing every tool repo and
# meta/):  ./meta/verify.sh [app ...]   (no args = everything)
#
# Bootstraps anything missing (venvs, npm install, xwa-sdk editable install)
# and prints a summary table. Exits non-zero when any suite fails.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
PYTHON="${PYTHON:-python3}"

PASS=0; FAIL=0; FAILED_APPS=()

check() {
  local name="$1"; shift
  echo -e "${YELLOW}[verify] $name ...${NC}"
  if "$@" >/dev/null 2>&1; then
    echo -e "${GREEN}  PASS $name${NC}"
    PASS=$((PASS+1))
  else
    echo -e "${RED}  FAIL $name${NC}"
    FAIL=$((FAIL+1))
    FAILED_APPS+=("$name")
  fi
}

bootstrap_python_backend() {
  local app="$1" dir="$ROOT_DIR/$app/backend"
  [ -x "$dir/.venv/bin/python" ] || "$PYTHON" -m venv "$dir/.venv" || return 1
  "$dir/.venv/bin/pip" install -q --upgrade pip >/dev/null 2>&1
  "$dir/.venv/bin/pip" install -q -r "$dir/requirements.txt" || return 1
  [ ! -f "$dir/requirements-dev.txt" ] || "$dir/.venv/bin/pip" install -q -r "$dir/requirements-dev.txt" || return 1
  [ ! -d "$ROOT_DIR/xwa-sdk/bindings/python" ] || "$dir/.venv/bin/pip" install -q -e "$ROOT_DIR/xwa-sdk/bindings/python" || return 1
  return 0
}

bootstrap_node_frontend() {
  local app="$1" dir="$ROOT_DIR/$app/frontend"
  [ -d "$dir/node_modules" ] || ( cd "$dir" && npm install --no-audit --no-fund ) || return 1
  return 0
}

verify_python_app() {
  local app="$1"
  bootstrap_python_backend "$app" || { FAILED_APPS+=("$app:backend-bootstrap"); FAIL=$((FAIL+1)); return; }
  check "$app:backend(pytest)" bash -c "( cd '$ROOT_DIR/$app/backend' && .venv/bin/python -m pytest -q )"
}

verify_rust_app() {
  local app="$1"
  check "$app:backend(cargo)" bash -c "( cd '$ROOT_DIR/$app' && cargo test -q )"
}

verify_angular_app() {
  local app="$1"
  bootstrap_node_frontend "$app" || { FAILED_APPS+=("$app:frontend-bootstrap"); FAIL=$((FAIL+1)); return; }
  check "$app:frontend(vitest)" bash -c "( cd '$ROOT_DIR/$app/frontend' && npm test )"
}

resolve_apps() {
  if [ $# -eq 0 ]; then
    printf '%s\n' samurai kensei musha azuma kabuki yari shinobi tengu xwa-sdk
  else
    printf '%s\n' "$@"
  fi
}

APPS="$(resolve_apps "$@")"

for app in $APPS; do
  case "$app" in
    samurai|kensei|musha|azuma|kabuki|yari)
      verify_python_app "$app"
      verify_angular_app "$app"
      ;;
    shinobi|tengu)
      verify_rust_app "$app"
      verify_angular_app "$app"
      ;;
    xwa-sdk)
      check "xwa-sdk:python(pytest)" bash -c "
        [ -x '$ROOT_DIR/xwa-sdk/.venv/bin/python' ] || '$PYTHON' -m venv '$ROOT_DIR/xwa-sdk/.venv'
        '$ROOT_DIR/xwa-sdk/.venv/bin/pip' install -q -e '$ROOT_DIR/xwa-sdk/bindings/python[test]'
        ( cd '$ROOT_DIR/xwa-sdk' && .venv/bin/python -m pytest -q )"
      check "xwa-sdk:typescript(node:test)" bash -c "
        ( cd '$ROOT_DIR/xwa-sdk/bindings/typescript' && [ -d node_modules ] || npm install --no-audit --no-fund
          npm test )"
      check "xwa-sdk:rust(cargo)" bash -c "( cd '$ROOT_DIR/xwa-sdk/bindings/rust' && cargo test -q )"
      ;;
    *)
      echo -e "${RED}unknown app: $app${NC}"
      FAIL=$((FAIL+1))
      ;;
  esac
done

echo
echo "=============================================="
echo -e "  PASS: ${GREEN}$PASS${NC}   FAIL: ${RED}$FAIL${NC}"
if [ "$FAIL" -gt 0 ]; then
  printf '  failed: %s\n' "${FAILED_APPS[@]}"
  exit 1
fi
echo -e "  ${GREEN}all suites green${NC}"
echo "=============================================="
