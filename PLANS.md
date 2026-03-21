# PLANS.md

Use this file for bigger features, refactors, or emulator/debug workflow work.
Keep it short and keep it current.

## Phase 8 - Reusable Assembly Foundation

### Goal
Keep the initial BBC Micro program behaviour unchanged while moving shared MOS entry points, BBC constants, and tiny helper macros out of `src/game.asm` into reusable library files.

### Constraints
- Keep Make as the main command surface.
- Keep BeebAsm + b2 Debug as the default path.
- Avoid breaking the simple edit -> build -> run loop.
- Avoid adding game systems or speculative abstractions.

### Files likely to change
- `PLANS.md`
- `src/game.asm`
- `src/lib/os.asm`
- `src/lib/macros.asm`

### Plan
1. Inspect the current assembly layout and confirm which shared values already exist.
2. Keep only the smallest reusable pieces in `src/lib/os.asm` and `src/lib/macros.asm`.
3. Verify with `make build` that the program still assembles and behaves the same.

### Verification
- `make build`
- Expected result: `build/game.ssd` is produced successfully and the demo program output remains unchanged at runtime.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The repo already contains the intended Phase 8 split, so this pass focuses on confirming the structure stays minimal and verifying the documented build path.

## Phase 9 - Milestone 1 Screen Foundation

### Goal
Move the startup program from a plain boot message to a predictable foundation screen that always selects a known mode and visibly clears the display.

### Constraints
- Keep the change focused on startup display state only.
- Avoid adding movement, input, or gameplay systems.
- Preserve the Make-based build and run workflow.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`
- `src/lib/os.asm`

### Plan
1. Pick a startup mode that keeps the current program simple while giving later milestones a better visual base.
2. Update the startup flow to force that mode, clear the screen, and print a small fixed foundation screen.
3. Mark milestone 1 as complete in the handoff doc and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the boot program now opens in the chosen mode with a cleared, intentional startup screen.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- Mode 1 is the planned baseline because it keeps a readable 40-column text display and leaves room to try simple colour in later milestones.

## Phase 10 - Milestone 2 Static Entity

### Goal
Prove the repo can render one game-like placeholder state by drawing a single fixed marker at a known screen position on the Mode 1 startup screen.

### Constraints
- Keep the change focused on one entity only.
- Avoid input, animation, movement, or game rules.
- Keep the placeholder state easy to inspect in the debugger.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`
- `src/lib/os.asm`

### Plan
1. Choose a simple fixed marker and a known text-cell position that stays readable in Mode 1.
2. Store that placeholder position in RAM and render it after the foundation text without introducing a game loop.
3. Mark milestone 2 as complete in the handoff doc and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the startup screen shows one fixed placeholder entity at a predictable location.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The placeholder uses a small `[P]` marker and RAM-backed `player_column` / `player_row` bytes so `b2 Debug` can inspect the state directly before input or movement exist.

## Phase 11 - Milestone 3 Keyboard Input

### Goal
Prove the repo can read a tiny, deliberate set of live keys by polling them in a simple frame loop and surfacing the result on screen and in RAM.

### Constraints
- Keep the change focused on input proof only.
- Avoid movement, animation, menus, or gameplay actions.
- Keep the input state easy to inspect in `b2 Debug`.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`
- `src/lib/os.asm`

### Plan
1. Pick a small key set that can later feed milestone 4 movement without introducing control-design debates now.
2. Add a tiny poll-and-redraw loop that scans those keys, stores simple RAM-backed state, and updates an in-place status display.
3. Mark milestone 3 as complete in the handoff doc and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the startup screen now shows live keyboard state changes for the chosen keys while the placeholder player remains fixed.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- `W`, `A`, `S`, and `D` are the chosen proof keys because they are easy to explain, easy to spot in RAM, and can carry forward directly into the next movement milestone.

## Phase 12 - Milestone 4 Simple Movement

### Goal
Connect the existing `W`, `A`, `S`, and `D` input proof to a small piece of mutable on-screen player state so the repo exercises a full display -> input -> update -> redraw loop.

### Constraints
- Keep movement intentionally basic and easy to inspect.
- Avoid physics, scrolling, collision, or enemy logic.
- Preserve the Make-based build and run workflow.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Add a tiny bounded movement area that stays readable in Mode 1 and does not overlap the existing status text.
2. Update the main loop to erase the old marker, apply simple `W`, `A`, `S`, and `D` movement within fixed bounds, and redraw only the player/status state.
3. Mark milestone 4 as complete in the handoff doc and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the placeholder player now moves in a small bounded area while the keyboard status remains visible.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The movement area should stay deliberately small and text-cell based so `b2 Debug` inspection remains straightforward and no rendering abstraction is needed yet.
- The implementation uses a boxed text play area and old-cell erase/new-cell redraw so movement remains visible without introducing a broader screen refresh system.

## Phase 13 - Milestone 5 Character Rendering Experiment

### Goal
Explore a more sprite-like rendering direction by keeping the existing movement loop but replacing the plain text marker with a tiny user-defined character experiment.

### Constraints
- Keep the change focused on rendering, not new game systems.
- Reuse the existing Mode 1 playfield, input loop, and RAM-backed player position.
- Avoid introducing a large asset pipeline or a general-purpose rendering engine.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Define a small custom-character player glyph that can be drawn through the current text-cell movement code.
2. Update the movement/render loop and on-screen text so the experiment clearly compares the new character-based direction to the earlier `[P]` placeholder.
3. Mark milestone 5 as complete in the handoff doc and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the movement demo now shows a user-defined player glyph with a simple step-frame change while the input HUD remains visible.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The experiment should stay intentionally small: a custom character is enough to learn whether a more graphic-looking player reads better than the old text marker without committing to a broader graphics system yet.
- The first follow-up to consider after this pass is a 2x2 metasprite experiment if one text cell is not expressive enough.
