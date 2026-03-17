#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
disc_image="${repo_root}/build/game.ssd"
b2_host="${B2_HOST:-127.0.0.1}"
b2_port="${B2_PORT:-48075}"
b2_window="${B2_WINDOW:-b2}"
b2_config="${B2_CONFIG:-}"
base_url="http://${b2_host}:${b2_port}"

pass() {
  printf '[RUN] %s\n' "$1"
}

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

server_is_up() {
  curl --silent --output /dev/null --max-time 1 "${base_url}/"
}

if [[ ! -f "${disc_image}" ]]; then
  fail "Disc image is missing: ${disc_image}. Run make build first."
fi

if ! server_is_up; then
  fail "b2 Debug HTTP API is not reachable on ${b2_host}:${b2_port}. Launch b2 Debug and try again."
fi

if [[ -n "${b2_config}" ]]; then
  pass "Resetting b2 Debug window ${b2_window} with config ${b2_config}"
  curl --silent --show-error --fail --get \
    --data-urlencode "config=${b2_config}" \
    "${base_url}/reset/${b2_window}" >/dev/null
else
  pass "Resetting b2 Debug window ${b2_window}"
  curl --silent --show-error --fail \
    "${base_url}/reset/${b2_window}" >/dev/null
fi

pass "Uploading ${disc_image} to b2 Debug"
curl --silent --show-error --fail \
  --header "Content-Type: application/octet-stream" \
  --upload-file "${disc_image}" \
  "${base_url}/run/${b2_window}?name=$(basename "${disc_image}")" >/dev/null

pass "Latest disc image is running in b2 Debug."
