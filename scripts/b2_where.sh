#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
listing_file="${repo_root}/build/game.lst"
label_file="${repo_root}/build/game.labels"
query="${1:-}"

fail() {
  printf '[ERROR] %s\n' "$1" >&2
  exit 1
}

if [[ -z "${query}" ]]; then
  fail 'Usage: ./scripts/b2_where.sh QUERY'
fi

if [[ ! -f "${listing_file}" || ! -f "${label_file}" ]]; then
  fail "Build artefacts are missing. Run make build first."
fi

printf '[WHERE] Listing matches for %s\n' "${query}"
if ! grep -ni -- "${query}" "${listing_file}"; then
  printf '[WHERE] No listing matches.\n'
fi

printf '[WHERE] Label matches for %s\n' "${query}"
if ! grep -ni -- "${query}" "${label_file}"; then
  printf '[WHERE] No label matches.\n'
fi
