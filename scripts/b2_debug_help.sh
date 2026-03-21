#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cat <<EOF
BBC Micro b2 Debug helpers

Build artefacts:
  - ${repo_root}/build/game.ssd
  - ${repo_root}/build/game.lst
  - ${repo_root}/build/game.labels

Suggested loop:
  - set a breakpoint in b2 Debug
  - make build
  - make run
  - inspect memory/disassembly in b2 Debug
  - repeat

Useful commands:
  - make run
  - make reset
  - make peek ADDR=1918 LEN=16
  - make poke ADDR=0070 BYTES="25 19"
  - make where QUERY=191E
  - make where QUERY=print_loop

Tips:
  - game.lst shows the assembled address for each instruction.
  - game.labels shows label-to-address mappings dumped by BeebAsm.
  - BRK is a useful temporary trap when you want execution to stop at a known point.
  - Use b2 Debug for breakpoints and stepping; use peek/poke for quick scripted inspection.
EOF
