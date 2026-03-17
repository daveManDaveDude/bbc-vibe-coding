# BBC Micro Model B Game Repo

This repo is a macOS-first BBC Micro Model B assembly game development setup with a small, repeatable command surface:

- `make verify` checks the local toolchain.
- `make build` assembles `src/game.asm` with BeebAsm and creates `build/game.ssd`.
- `make run` rebuilds and sends the latest disc image to `b2 Debug` over its local HTTP API.

The first version stays intentionally small. All automation lives behind Make targets and shell scripts, `b2 Debug` is the primary emulator/debugger, and MAME is optional only.

## Repo Layout

```text
.codex/
.vscode/
build/
docs/
scripts/
src/
  lib/
Makefile
README.md
```

## Quick Start

1. Run `make verify`.
2. Install any missing tools the script calls out.
3. Run `make build` to create `build/game.ssd`.
4. Open `b2 Debug` once and keep it around for the edit -> build -> run loop.
5. Run `make run` to rebuild and rerun the latest disc image.

If you want a guided macOS setup check first, run `./scripts/bootstrap_macos.sh`.

## Toolchain Notes

- BeebAsm is the assembler and disc-image builder.
- `b2 Debug` is the primary emulator/debugger and exposes the local HTTP API used by `make run`.
- Make is the stable automation surface for humans, VS Code tasks, and Codex.
- MAME is optional and is not required for the default workflow.

If `beebasm` is not already on `PATH`, build it from source from [stardot/beebasm](https://github.com/stardot/beebasm) and place the resulting `beebasm` binary somewhere on your shell `PATH`.

Install `b2 Debug` from the latest macOS release of [tom-seddon/b2](https://github.com/tom-seddon/b2/releases/latest), then drag `b2 Debug.app` into `/Applications` or `~/Applications`.

More detail lives in [docs/toolchain.md](/Users/david/Documents/bbc-vibe-coding/docs/toolchain.md), [docs/workflow.md](/Users/david/Documents/bbc-vibe-coding/docs/workflow.md), and [docs/debugging.md](/Users/david/Documents/bbc-vibe-coding/docs/debugging.md).

## Daily Workflow

- Edit [src/game.asm](/Users/david/Documents/bbc-vibe-coding/src/game.asm).
- Keep shared BBC constants in [src/lib/os.asm](/Users/david/Documents/bbc-vibe-coding/src/lib/os.asm) and tiny helper macros in [src/lib/macros.asm](/Users/david/Documents/bbc-vibe-coding/src/lib/macros.asm).
- Run `make build` for a new bootable DFS image.
- Run `make run` to push the latest `build/game.ssd` into `b2 Debug`.
- Set breakpoints, inspect memory, and step in `b2 Debug`.

The built disc auto-boots `GAME`, so the emulator can restart straight into the latest program.

Useful overrides:

- `BEEBASM=/path/to/beebasm make build`
- `B2_APP=/Applications/b2\\ Debug.app make run`
- `B2_WINDOW=b2 make run`
- `B2_CONFIG='your b2 config name' make run`

## VS Code

VS Code tasks call the same Make targets:

- `Beeb verify`
- `Beeb build`
- `Beeb run`
- `Beeb clean`

`Beeb build` is marked as the default build task, so `Terminal: Run Build Task` maps straight to `make build`.

## Working With Codex

New Codex sessions should prefer:

- `make verify`
- `make build`
- `make run`

That keeps the repo easy to reason about and avoids one-off shell commands drifting away from the documented workflow.

## Troubleshooting

- Missing `beebasm`: run `make verify`, then build BeebAsm from [stardot/beebasm](https://github.com/stardot/beebasm) and ensure the binary is on `PATH`.
- Missing `b2 Debug`: install `b2 Debug.app` into `/Applications` or `~/Applications`.
- `b2 Debug` installed somewhere else: set `B2_APP=/full/path/to/b2\ Debug.app`.
- `b2 Debug` window title is not `b2`: set `B2_WINDOW=your-window-title`.
- `make run` cannot reach the HTTP API: launch `b2 Debug` manually once, let it finish starting, then rerun `make run`.
- Need a clean rebuild: run `make clean` and then `make build`.
