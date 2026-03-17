# Workflow

The intended loop is:

1. Edit [src/game.asm](/Users/david/Documents/bbc-vibe-coding/src/game.asm).
2. Run `make build` to assemble the code and generate `build/game.ssd`.
3. Run `make run` to rebuild, launch `b2 Debug` if needed, and rerun the latest disc image.
4. Inspect behavior in `b2 Debug`, adjust code, and repeat.

## Build

`make build` calls [scripts/build.sh](/Users/david/Documents/bbc-vibe-coding/scripts/build.sh), which:

- verifies `beebasm` is available
- creates `build/`
- assembles `src/game.asm`
- writes `build/game.ssd`
- configures the disc to auto-boot `GAME`

## Run

`make run` does three things in order:

1. `make build`
2. [scripts/launch_b2.sh](/Users/david/Documents/bbc-vibe-coding/scripts/launch_b2.sh)
3. [scripts/run_b2_http.sh](/Users/david/Documents/bbc-vibe-coding/scripts/run_b2_http.sh)

The HTTP step talks to `b2 Debug` on `127.0.0.1:48075`, resets the current machine, and uploads the latest `game.ssd` so the emulator boots the new build.

If your setup differs from the defaults, the scripts accept:

- `BEEBASM` for a non-default assembler path
- `B2_APP` for a non-default app location
- `B2_WINDOW` for a non-default b2 window title
- `B2_CONFIG` if you want `reset` to force a specific hardware config before running

## Keep It Predictable

- Prefer the Make targets instead of calling tools directly.
- Keep new automation in `scripts/` and expose it through the Makefile.
- Treat `build/` as generated output only.
