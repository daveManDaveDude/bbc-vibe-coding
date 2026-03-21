# Debugging

This repo treats `b2 Debug` as the main debugger. Keep it open while you work and use the Make targets to rebuild and reload the latest disc image.

## Intended Loop

1. Set or adjust a breakpoint in `b2 Debug`.
2. Run `make build` after editing code.
3. Run `make run` to load the latest [build/game.ssd](/Users/david/Documents/bbc-vibe-coding/build/game.ssd) into the current `b2 Debug` window.
4. Let the program stop, then inspect memory and disassembly in `b2 Debug`.
5. Edit, rebuild, rerun, and repeat.

`make run` already rebuilds before it reloads, so in day-to-day use it is often the only command you need. `make build` is still useful on its own when you just want fresh listing files or want to confirm the code assembles cleanly.

## Finding The Right Address

- [build/game.lst](/Users/david/Documents/bbc-vibe-coding/build/game.lst) shows the assembled address of each instruction.
- [build/game.labels](/Users/david/Documents/bbc-vibe-coding/build/game.labels) maps labels to addresses.
- `make where QUERY=print_loop` or `make where QUERY=191E` is the quickest way to search those files from the terminal.

If a rebuild moves code around, update the breakpoint to match the new address.

## Inspecting State

- Use the memory and disassembly views in `b2 Debug` once execution stops.
- `make peek ADDR=1918 LEN=16` is handy for quick scripted memory reads.
- `make poke ADDR=0070 BYTES="25 19"` is useful for temporary experiments without rebuilding.
- `make reset` resets the current `b2 Debug` machine.

## Optional `BRK` Trap

`BRK` is a simple temporary trap when you want execution to stop at a known point during development. It is useful as short-lived scaffolding, but treat it as a debug aid and remove it once you are done with that investigation.

## Notes

- `make debug-help` prints a short reminder of the debug files and helper commands.
- VS Code `F5` still works as a shortcut because it runs the same `make run` flow, but the real debugging happens in `b2 Debug`.
