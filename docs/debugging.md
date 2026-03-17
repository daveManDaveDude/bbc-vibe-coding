# Debugging

`b2 Debug` is the primary debugger for this repo.

## Basic Loop

1. Open `b2 Debug`.
2. Set breakpoints in its disassembly or memory views.
3. Run `make run` to rebuild and rerun `build/game.ssd`.
4. Step, inspect registers, memory, and disassembly.
5. Repeat.

## Useful Conventions

- The current bootable disc image is always [build/game.ssd](/Users/david/Documents/bbc-vibe-coding/build/game.ssd).
- `make run` is the fastest way to get the newest image back into the emulator.
- `BRK` is a reasonable temporary development trap when you want execution to stop at a known point.

## b2 Debug Tips

- Use the `Debug` menu to stop and run the machine.
- Right-click bytes or addresses in debugger views to add breakpoints.
- Keep the emulator open during development so the HTTP API can reload the newest build quickly.
