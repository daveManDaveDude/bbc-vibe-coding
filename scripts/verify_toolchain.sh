#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${repo_root}/build"

failures=0
warnings=0

pass() {
  printf '[PASS] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
  warnings=$((warnings + 1))
}

fail() {
  printf '[FAIL] %s\n' "$1"
  failures=$((failures + 1))
}

have_command() {
  command -v "$1" >/dev/null 2>&1
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

check_executable() {
  local path="$1"
  local label="$2"

  if [[ -x "${path}" ]]; then
    pass "${label} is executable."
  else
    fail "${label} is missing or not executable: ${path}"
  fi
}

printf 'Verifying BBC Micro macOS toolchain...\n'

if xcode-select -p >/dev/null 2>&1; then
  pass "Xcode Command Line Tools are available."
else
  fail "Xcode Command Line Tools are missing. Run: xcode-select --install"
fi

for tool in curl git make; do
  if have_command "${tool}"; then
    pass "${tool} is on PATH."
  else
    fail "${tool} is missing from PATH."
  fi
done

if have_command beebasm; then
  pass "BeebAsm is on PATH."
else
  fail "BeebAsm is missing. Build it from https://github.com/stardot/beebasm and place the binary on PATH."
fi

if b2_path="$(find_b2_app)"; then
  pass "b2 Debug was found at ${b2_path}."
else
  fail "b2 Debug.app was not found in /Applications or ~/Applications."
fi

if have_command mame; then
  pass "MAME is available (optional)."
else
  warn "MAME is not installed. That is optional for this repo."
fi

check_executable "${repo_root}/scripts/bootstrap_macos.sh" "scripts/bootstrap_macos.sh"
check_executable "${repo_root}/scripts/verify_toolchain.sh" "scripts/verify_toolchain.sh"
check_executable "${repo_root}/scripts/build.sh" "scripts/build.sh"
check_executable "${repo_root}/scripts/launch_b2.sh" "scripts/launch_b2.sh"
check_executable "${repo_root}/scripts/run_b2_http.sh" "scripts/run_b2_http.sh"

mkdir -p "${build_dir}"
write_test="${build_dir}/.write-test.$$"
if : > "${write_test}" 2>/dev/null; then
  rm -f "${write_test}"
  pass "build/ is writable."
else
  fail "build/ is not writable: ${build_dir}"
fi

printf '\nSummary: %d required issue(s), %d warning(s).\n' "${failures}" "${warnings}"

if (( failures > 0 )); then
  printf 'Toolchain verification failed. Fix the required items above and re-run make verify.\n'
  exit 1
fi

printf 'Toolchain verification passed.\n'
