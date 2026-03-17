# AGENTS.md

## Repo purpose
macOS-first BBC Micro Model B 6502 assembly game repo.
Default loop: edit -> build DFS image -> run in b2 Debug.

## Important paths
- `src/game.asm` main program entry.
- `src/lib/os.asm` BBC OS constants/helpers.
- `src/lib/macros.asm` small shared macros.
- `build/` generated output. Treat as build artefacts.
- `scripts/` automation used by Make.
- `docs/` human docs. Update when workflow changes.

## Command surface
Prefer these commands. Do not invent new workflow commands unless required.

- `make verify` check local toolchain.
- `make build` assemble `src/game.asm` and create `build/game.ssd`.
- `make run` rebuild and push latest disc to `b2 Debug`.
- `make clean` remove generated output.

## Working rules
- Prefer Make targets over ad-hoc shell commands.
- Keep automation in `Makefile` and `scripts/`.
- Keep changes small and easy to review.
- Do not hand-edit generated files in `build/`.
- Preserve the simple default toolchain: BeebAsm + b2 Debug + Make.
- Only add new tools when the current flow cannot support the task.

## Verification
- For assembly or build changes, run `make build`.
- For toolchain or workflow changes, run `make verify` then `make build`.
- Run `make run` when emulator integration is part of the change and the local machine supports `b2 Debug`.
- In the final summary, state exactly what was run and what could not be run.

## Done means
- Repo still builds with the documented Make workflow.
- Docs stay aligned with the real command surface.
- New behaviour is explained briefly and in the right file.

## Long tasks
For features that need multiple steps or decisions, create or update a task plan using `PLANS.md` before making large changes.
