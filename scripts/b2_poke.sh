#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/b2_http_common.sh"

addr="${1:-}"
shift || true
byte_text="${*:-}"
suffix="${SUFFIX:-}"
mos="${MOS:-false}"

if [[ -z "${addr}" || -z "${byte_text}" ]]; then
  fail 'Usage: ./scripts/b2_poke.sh ADDR "25 19"'
fi

require_hex "${addr}" "ADDR"

hex_bytes="$(printf '%s' "${byte_text}" | tr -d '[:space:]')"
if [[ -z "${hex_bytes}" ]]; then
  fail "BYTES must contain at least one hex byte."
fi

if [[ ! "${hex_bytes}" =~ ^[0-9A-Fa-f]+$ ]]; then
  fail "BYTES must contain only hex digits and spaces, got: ${byte_text}"
fi

if (( ${#hex_bytes} % 2 != 0 )); then
  fail "BYTES must contain an even number of hex digits."
fi

ensure_b2

tmp_file="$(mktemp)"
trap 'rm -f "${tmp_file}"' EXIT

printf '%s' "${hex_bytes}" | xxd -r -p > "${tmp_file}"

query=()
if [[ -n "${suffix}" ]]; then
  query+=(--data-urlencode "s=${suffix}")
fi
query+=(--data-urlencode "mos=${mos}")

pass "Poking ${b2_window} at &${addr} with ${byte_text}"
curl --silent --show-error --fail --get \
  "${query[@]}" \
  --header "Content-Type: application/octet-stream" \
  --upload-file "${tmp_file}" \
  "${base_url}/poke/${b2_window}/${addr}" >/dev/null

pass "Poke complete."
