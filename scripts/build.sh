#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src_dir="${repo_root}/src"
build_dir="${repo_root}/build"
source_file="${src_dir}/game.asm"
output_ssd="${build_dir}/game.ssd"
label_file="${build_dir}/game.labels"
listing_file="${build_dir}/game.lst"
assembler="${BEEBASM:-beebasm}"

pass() {
  printf '[BUILD] %s\n' "$1"
}

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

if ! command -v "${assembler}" >/dev/null 2>&1; then
  fail "BeebAsm was not found. Set BEEBASM or put beebasm on PATH, then run make verify."
fi

if [[ ! -f "${source_file}" ]]; then
  fail "Source file is missing: ${source_file}"
fi

mkdir -p "${build_dir}"

pass "Assembling ${source_file} -> ${output_ssd}"
(
  cd "${src_dir}"
  "${assembler}" \
    -i "game.asm" \
    -do "${output_ssd}" \
    -boot "GAME" \
    -title "BBCVIBE" \
    -labels "${label_file}" \
    -dd \
    -v > "${listing_file}"
)

if [[ ! -f "${output_ssd}" ]]; then
  fail "Build completed without producing ${output_ssd}"
fi

size_bytes="$(wc -c < "${output_ssd}" | tr -d '[:space:]')"
pass "Created ${output_ssd} (${size_bytes} bytes)"
pass "Wrote ${listing_file} and ${label_file}"
