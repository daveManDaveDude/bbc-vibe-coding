#!/usr/bin/env bash

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
b2_host="${B2_HOST:-127.0.0.1}"
b2_port="${B2_PORT:-48075}"
b2_window="${B2_WINDOW:-b2}"
base_url="http://${b2_host}:${b2_port}"

pass() {
  printf '[B2DBG] %s\n' "$1"
}

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

server_is_up() {
  curl --silent --output /dev/null --max-time 1 "${base_url}/"
}

ensure_b2() {
  if ! server_is_up; then
    "${repo_root}/scripts/launch_b2.sh"
  fi

  if ! server_is_up; then
    fail "b2 Debug HTTP API is not reachable on ${b2_host}:${b2_port}."
  fi
}

require_hex() {
  local value="$1"
  local label="$2"

  if [[ ! "${value}" =~ ^[0-9A-Fa-f]+$ ]]; then
    fail "${label} must be hex digits only, got: ${value}"
  fi
}
