#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/b2_http_common.sh"

config_name="${1:-${B2_CONFIG:-}}"

ensure_b2

if [[ -n "${config_name}" ]]; then
  pass "Resetting ${b2_window} with config ${config_name}"
  curl --silent --show-error --fail --get \
    --data-urlencode "config=${config_name}" \
    "${base_url}/reset/${b2_window}" >/dev/null
else
  pass "Resetting ${b2_window}"
  curl --silent --show-error --fail \
    "${base_url}/reset/${b2_window}" >/dev/null
fi

pass "Reset complete."
