#!/usr/bin/env bash
set -euo pipefail

pass() {
  printf '[PASS] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

printf 'Checking macOS development prerequisites...\n'

if have_command brew; then
  pass "Homebrew is installed."
else
  warn "Homebrew is missing. Install it from https://brew.sh before setting up extra tooling."
fi

if xcode-select -p >/dev/null 2>&1; then
  pass "Xcode Command Line Tools are available."
else
  fail "Xcode Command Line Tools are missing. Run: xcode-select --install"
fi

for tool in curl make git; do
  if have_command "$tool"; then
    pass "$tool is available."
  else
    fail "$tool is missing. Install Xcode Command Line Tools first, then re-run this script."
  fi
done

printf '\nSuggested next steps for BBC Micro tooling:\n'
printf '  - Build BeebAsm from source if it is not already on PATH: https://github.com/stardot/beebasm\n'
printf '  - Install b2 Debug.app from: https://github.com/tom-seddon/b2/releases/latest\n'
printf '  - Optional only: install MAME if you want a secondary emulator/debugger.\n'
printf '\nRun make verify for the repo-specific readiness check.\n'
