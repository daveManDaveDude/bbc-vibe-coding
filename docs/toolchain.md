# Toolchain

This repo uses a deliberately small toolchain:

- BeebAsm assembles the source and writes the bootable DFS disc image directly.
- `b2 Debug` is the primary emulator and debugger on macOS.
- Make provides the stable entry points that VS Code tasks and Codex both call.
- Bash scripts hold the OS-specific glue and keep the Makefile readable.
- MAME stays optional for comparison or second-opinion testing only.

## Why BeebAsm

BeebAsm is BBC-specific, understands DFS disc output, and can generate a disc that auto-boots `GAME` without any extra packer or post-processing step.

## Why b2 Debug

`b2 Debug` gives a BBC-focused debugger and a local HTTP API. That API is what makes `make run` useful: rebuild, reset the emulator, and rerun the latest disc without manual mounting.

## Why Make

Make gives the repo a tiny command surface:

- `make verify`
- `make build`
- `make run`
- `make clean`

That is simple enough for humans, editor tasks, and Codex sessions to share.

## macOS Setup Notes

- Run `./scripts/bootstrap_macos.sh` for setup guidance.
- Run `make verify` for the actual readiness check.
- If `beebasm` is missing, build it from [stardot/beebasm](https://github.com/stardot/beebasm) and put the binary on `PATH`.
- Install `b2 Debug.app` from [tom-seddon/b2 releases](https://github.com/tom-seddon/b2/releases/latest).
