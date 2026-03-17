#!/usr/bin/env bash
set -euo pipefail

b2_host="${B2_HOST:-127.0.0.1}"
b2_port="${B2_PORT:-48075}"

pass() {
  printf '[B2] %s\n' "$1"
}

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

server_is_up() {
  curl --silent --output /dev/null --max-time 1 "http://${b2_host}:${b2_port}/"
}

find_b2_app() {
  local candidate

  for candidate in \
    "${B2_APP:-}" \
    "/Applications/b2 Debug.app" \
    "${HOME}/Applications/b2 Debug.app"
  do
    if [[ -n "${candidate}" && -d "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

if server_is_up; then
  pass "b2 Debug HTTP API is already reachable on ${b2_host}:${b2_port}."
  exit 0
fi

if ! b2_app="$(find_b2_app)"; then
  fail "b2 Debug.app was not found. Install it into /Applications or set B2_APP."
fi

pass "Launching ${b2_app}"
open -a "${b2_app}"

for _ in {1..30}; do
  if server_is_up; then
    pass "b2 Debug HTTP API is ready."
    exit 0
  fi
  sleep 1
done

fail "b2 Debug launched, but its HTTP API is still not reachable on ${b2_host}:${b2_port}. Open the app once manually, let it finish starting, then retry."
