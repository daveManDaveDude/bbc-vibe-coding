#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/b2_http_common.sh"

addr="${1:-}"
len="${2:-16}"
suffix="${SUFFIX:-}"
mos="${MOS:-false}"

if [[ -z "${addr}" ]]; then
  fail "Usage: ./scripts/b2_peek.sh ADDR [LEN]"
fi

require_hex "${addr}" "ADDR"
require_hex "${len}" "LEN"

ensure_b2

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

query=()
if [[ -n "${suffix}" ]]; then
  query+=(--data-urlencode "s=${suffix}")
fi
query+=(--data-urlencode "mos=${mos}")

pass "Peeking ${b2_window} at &${addr} for &${len} byte(s)"
curl --silent --show-error --fail --get \
  "${query[@]}" \
  --output "${tmp_file}" \
  "${base_url}/peek/${b2_window}/${addr}/+0x${len}"

if command -v xxd >/dev/null 2>&1; then
  xxd -g 1 "${tmp_file}"
else
  hexdump -Cv "${tmp_file}"
fi
