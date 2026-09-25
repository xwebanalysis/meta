#!/usr/bin/env bash
# xwa.sh — XWA ecosystem orchestrator (SQLite-first, no Docker required).
#
# Expects every tool checked out as a sibling of this repo (the directory that
# contains meta/ is the workspace root). Usage:
#
#   ./meta/xwa.sh list                  # module inventory + ports
#   ./meta/xwa.sh bootstrap [app ...]   # venvs, pip deps, npm install
#   ./meta/xwa.sh up [app ...]          # start backends (+ Angular dev servers)
#   ./meta/xwa.sh status [app ...]      # health of every running module
#   ./meta/xwa.sh down [app ...]        # stop everything (or a subset)
#   ./meta/xwa.sh logs <app>            # tail the backend log
#
# Everything is logged under <root>/.xwa-run/ and cleaned on `down`.
# Compatible with bash 3.2+ and zsh (no associative arrays).

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUN_DIR="$ROOT_DIR/.xwa-run"
LOG_DIR="$RUN_DIR/logs"
PID_DIR="$RUN_DIR/pids"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'

PYTHON="${PYTHON:-python3}"
XWA_SDK="$ROOT_DIR/xwa-sdk/bindings/python"

# Spec table: app|kind|backend_dir|backend_cmd|frontend_dir|health_url|frontend_port
SPEC="$(cat <<'SPECEOF'
samurai|python|samurai/backend|.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000|samurai/frontend|http://localhost:8000/api/health|4200
kensei|python|kensei/backend|.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8010|kensei/frontend|http://localhost:8010/api/health|4210
musha|python|musha/backend|.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8020|musha/frontend|http://localhost:8020/api/health|4220
azuma|python|azuma/backend|.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8030|azuma/frontend|http://localhost:8030/api/health|4230
kabuki|python|kabuki/backend|.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8040|kabuki/frontend|http://localhost:8040/api/health|4240
yari|python|yari/backend|.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8050|yari/frontend|http://localhost:8050/api/health|4250
shinobi|rust|shinobi|cargo run|shinobi/frontend|http://localhost:8060/api/health|4260
tengu|rust|tengu|cargo run|tengu/frontend|http://localhost:8070/api/health|4270
SPECEOF
)"

ALL_APPS="samurai kensei musha azuma kabuki yari shinobi tengu"

spec_line() { printf '%s\n' "$SPEC" | grep -E "^$1\|"; }
spec_field() { printf '%s\n' "$SPEC" | grep -E "^$1\|" | cut -d'|' -f"$2"; }

app_exists() { [ -n "$(spec_line "$1")" ]; }

resolve_apps() {
  if [ "$#" -eq 0 ]; then printf '%s\n' $ALL_APPS; else printf '%s\n' "$@"; fi
}

# ------------------------------------------------------------------ bootstrap

bootstrap_python() {
  local app="$1" dir="$ROOT_DIR/$(spec_field "$app" 3)"
  if [ ! -x "$dir/.venv/bin/python" ]; then
    echo -e "${YELLOW}[bootstrap] $app: creating venv${NC}"
    "$PYTHON" -m venv "$dir/.venv" || { echo -e "${RED}[bootstrap] $app: venv failed${NC}"; return 1; }
  fi
  "$dir/.venv/bin/pip" install -q --upgrade pip >/dev/null 2>&1
  "$dir/.venv/bin/pip" install -q -r "$dir/requirements.txt" || return 1
  if [ -f "$dir/requirements-dev.txt" ]; then
    "$dir/.venv/bin/pip" install -q -r "$dir/requirements-dev.txt" || return 1
  fi
  if [ -d "$XWA_SDK" ]; then
    "$dir/.venv/bin/pip" install -q -e "$XWA_SDK" || return 1
  fi
}

bootstrap_node() {
  local app="$1" dir="$ROOT_DIR/$(spec_field "$app" 5)"
  if [ ! -d "$dir/node_modules" ]; then
    echo -e "${YELLOW}[bootstrap] $app: npm install (frontend)${NC}"
    ( cd "$dir" && npm install --no-audit --no-fund ) || return 1
  fi
}

bootstrap_app() {
  local app="$1"
  app_exists "$app" || { echo -e "${RED}unknown app: $app${NC}"; return 1; }
  case "$(spec_field "$app" 2)" in
    python) bootstrap_python "$app" || return 1 ;;
    rust)   echo -e "${YELLOW}[bootstrap] $app: cargo build (deferred to first run)${NC}" ;;
  esac
  bootstrap_node "$app" || return 1
  echo -e "${GREEN}[bootstrap] $app: ready${NC}"
}

# ------------------------------------------------------------------ start/stop

is_running() {
  [ -f "$PID_DIR/$1.pid" ] && kill -0 "$(cat "$PID_DIR/$1.pid")" 2>/dev/null
}

start_app() {
  local app="$1"
  app_exists "$app" || { echo -e "${RED}unknown app: $app${NC}"; return 1; }
  if is_running "$app"; then
    echo -e "${YELLOW}[up] $app: already running${NC}"
    return 0
  fi
  mkdir -p "$LOG_DIR" "$PID_DIR"

  ( cd "$ROOT_DIR/$(spec_field "$app" 3)" && nohup sh -c "$(spec_field "$app" 4)" \
      > "$LOG_DIR/$app-backend.log" 2>&1 & echo $! > "$PID_DIR/$app.pid" )
  echo -e "${GREEN}[up] $app: backend starting (log: .xwa-run/logs/$app-backend.log)${NC}"

  if [ "$(spec_field "$app" 2)" = "python" ]; then
    ( cd "$ROOT_DIR/$(spec_field "$app" 5)" && nohup npm start \
      > "$LOG_DIR/$app-frontend.log" 2>&1 & echo $! > "$PID_DIR/$app-frontend.pid" )
    echo -e "${GREEN}[up] $app: frontend starting (port $(spec_field "$app" 7))${NC}"
  fi
}

stop_app() {
  local app="$1" pidfile pid port had=0 p
  app_exists "$app" || { echo -e "${RED}unknown app: $app${NC}"; return 1; }

  # Kill recorded wrapper PIDs first, then anything still listening on the
  # app's ports (uvicorn/npm children survive the wrapper on macOS).
  for pidfile in "$PID_DIR/$app.pid" "$PID_DIR/$app-frontend.pid"; do
    [ -f "$pidfile" ] || continue
    pid="$(cat "$pidfile" 2>/dev/null)"
    [ -n "$pid" ] && kill "$pid" 2>/dev/null
    rm -f "$pidfile"
  done

  for port in "$(spec_field "$app" 6 | sed 's#.*localhost:##;s#/.*##')" "$(spec_field "$app" 7)"; do
    [ -z "$port" ] && continue
    for p in $(lsof -ti "tcp:$port" 2>/dev/null); do
      kill "$p" 2>/dev/null
      had=1
    done
  done

  if [ "$had" -eq 1 ]; then
    echo -e "${GREEN}[down] $app: stopped${NC}"
  else
    echo -e "${YELLOW}[down] $app: not running${NC}"
  fi
}

health_app() {
  local url
  url="$(spec_field "$1" 6)"
  curl -s --max-time 3 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null
}

# ------------------------------------------------------------------ commands

cmd_list() {
  printf '%-10s %-9s %-10s %s\n' "APP" "KIND" "BACKEND" "STATUS"
  for app in $ALL_APPS; do
    local port status="offline"
    port="$(spec_field "$app" 6 | sed 's#http://localhost:##;s#/api/health##')"
    is_running "$app" && status="running"
    printf '%-10s %-9s %-10s %s\n' "$app" "$(spec_field "$app" 2)" "$port" "$status"
  done
}

cmd_status() {
  local code=0 app http body
  printf '%-10s %-8s %s\n' "APP" "HTTP" "HEALTH"
  for app in $(resolve_apps "$@"); do
    app_exists "$app" || { echo -e "${RED}unknown app: $app${NC}"; code=1; continue; }
    http="$(health_app "$app")"
    if [ "$http" = "200" ]; then
      body="$(curl -s --max-time 3 "$(spec_field "$app" 6)" | tr -d '\n' | head -c 140)"
      echo -e "${GREEN}ok${NC}   $app    $http    $body"
    else
      echo -e "${RED}down${NC} $app    $http    offline"
      code=1
    fi
  done
  return "$code"
}

cmd_logs() {
  local app="$1" file="$LOG_DIR/$app-backend.log"
  app_exists "$app" || { echo -e "${RED}unknown app: $app${NC}"; return 1; }
  [ -f "$file" ] || { echo -e "${RED}no log for $app${NC}"; return 1; }
  tail -n 50 "$file"
}

# ------------------------------------------------------------------ main

mkdir -p "$RUN_DIR" "$LOG_DIR" "$PID_DIR"

command="${1:-help}"
shift 2>/dev/null || true

case "$command" in
  list)      cmd_list ;;
  bootstrap) for app in $(resolve_apps "$@"); do bootstrap_app "$app" || exit 1; done ;;
  up)        for app in $(resolve_apps "$@"); do start_app "$app" || exit 1; done ;;
  down)      for app in $(resolve_apps "$@"); do stop_app "$app"; done ;;
  status)    cmd_status "$@" ;;
  logs)      [ $# -ge 1 ] || { echo "usage: xwa.sh logs <app>"; exit 1; }
             cmd_logs "$1" ;;
  *)         echo "usage: xwa.sh {list|bootstrap|up|down|status|logs} [app ...]" ; exit 1 ;;
esac
