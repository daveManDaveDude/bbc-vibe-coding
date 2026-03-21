# Next Steps

This repo is still an environment-first BBC Micro foundation, not a game-heavy starter.
The next milestones should prove out the display, input, and rendering loop in small steps that future Codex sessions can pick up safely.

Use this document as a planning handoff:

- take one milestone at a time
- keep placeholder visuals and test state over real game systems
- preserve the Make-based workflow and the BeebAsm + b2 Debug loop
- update `PLANS.md` before implementation if a milestone grows into a multi-step feature

## Ordered milestones

### 1. Clear screen / set mode

Status:
Complete. The current startup program now boots straight into Mode 1, clears the display, and shows a small fixed foundation screen.

Goal:
Establish a repeatable startup screen state and a known display mode for later experiments.

Why this comes first:
It turns the current boot proof into a predictable visual foundation and confirms the program can reliably take over the display.

Success looks like:
- booting the disc always enters the chosen screen mode
- old screen contents are cleared or overwritten in an obvious way
- the result still reads as a foundation check, not a game intro

Keep out of scope:
- movement
- input handling
- gameplay rules
- content-heavy presentation

### 2. Draw static player or enemy state

Status:
Complete. Startup now draws one fixed `[P]` player placeholder at a known Mode 1 text cell using RAM-backed coordinates, keeping the render step obvious and easy to inspect in the debugger.

Goal:
Show a single fixed on-screen entity or placeholder state at a known position.

Why this comes next:
It proves the repo can place visible game-like state on screen before any interactivity is added.

Success looks like:
- a clearly intentional player-like or enemy-like marker is visible after startup
- the visual is static and easy to reason about in the debugger
- the repo still feels like a minimal rendering test rather than a game system

Keep out of scope:
- animation
- multiple entities
- collision
- enemy behaviour

### 3. Keyboard input

Status:
Complete. The startup program now enters a tiny polling loop that scans `W`, `A`, `S`, and `D`, stores each key's live pressed state in RAM, and refreshes a small on-screen status display while the placeholder player stays fixed.

Goal:
Read a small, deliberate set of keys and surface that input in a controlled way.

Why this comes next:
It validates the input side of the loop before movement complicates state updates and rendering.

Success looks like:
- a defined set of keys can be detected consistently
- input is visible through a simple state change or debug-friendly status display
- the change stays focused on environment capability rather than control design

Keep out of scope:
- continuous movement tuning
- menus
- remapping
- gameplay actions beyond basic input proof

### 4. Simple movement

Status:
Complete. The main loop now applies `W`, `A`, `S`, and `D` to the placeholder player's RAM-backed text-cell position, erases the old marker, redraws it inside a small boxed area, and keeps the live input HUD visible.

Goal:
Connect input to a tiny piece of mutable on-screen state.

Why this comes next:
It completes the first end-to-end loop: display, input, update, and redraw.

Success looks like:
- the placeholder entity can move in a simple, bounded way
- movement rules stay intentionally basic and easy to inspect
- the code still favours clarity over flexibility

Keep out of scope:
- physics
- scrolling
- collision response
- enemy logic

### 5. Sprite-like or character-based rendering experiments

Status:
Complete. The movement demo now defines two user characters, renders the player as a single-cell sprite-like glyph instead of the plain `[P]` text marker, and flips between the two frames on each successful move so the repo can compare a character-based direction against the earlier baseline.

Goal:
Explore how the repo should represent moving visuals on BBC Micro hardware without committing to a full rendering engine.

Why this comes last:
It should be informed by what worked during the earlier mode, input, and movement steps instead of guesswork.

Success looks like:
- at least one rendering direction is explored against the current static approach
- the experiment is framed as a learning step for the foundation
- findings are documented clearly enough to guide the next iteration

Findings:
- A user-defined character keeps the current cursor-based movement code and RAM-backed player coordinates intact, so it is a low-risk upgrade from the original `[P]` marker.
- Two redefined frames are enough to suggest a simple step animation without adding a full redraw system or an asset pipeline.
- The next useful rendering experiment is a 2x2 metasprite built from multiple redefined characters if the project needs more detail than one text cell can provide.

Keep out of scope:
- a large asset pipeline
- a finished animation system
- genre-specific content production

## Session guidance for future Codex work

- prefer one milestone per session
- keep changes small and easy to review
- use `make build` as the default verification step
- use `make run` when emulator behaviour is part of the milestone
- only move helpers into `src/lib/` when reuse is obvious

## Next direction: Full graphics roadmap

The first five milestones proved the Mode 1 text-and-character path.
The next stretch should deliberately switch to a bitmap-screen foundation built around software sprites, a black background, and smoother motion.

### 6. Bitmap mode and black-screen baseline

Status:
Complete. Startup now boots directly into Mode 5, restores a known four-colour palette, hides the text cursor, and clears both text and graphics areas so the first graphics pass opens on an intentionally empty black bitmap screen.

Goal:
Boot straight into a full graphics mode, clear the display to black, and define the palette and coordinate system the sprite work will use.

Why this comes first:
The sprite format, movement rules, and memory layout all depend on the chosen graphics mode.

Success looks like:
- the program always opens in the chosen bitmap mode
- the visible screen starts as a clean black playfield
- the mode, palette, and pixel-coordinate conventions are written down clearly enough for later sessions

Chosen baseline:
- Mode 5 for a 160x256 bitmap with four logical colours and better RAM headroom than Mode 2
- logical colour 0 is the black background, with logical colours 1-3 reserved as red, yellow, and white sprite colours
- future software sprites should use top-left pixel coordinates with X increasing rightward from 0 to 159 and Y increasing downward from 0 to 255
- code should stay guarded below `&5800`, the Mode 5 screen base, while the program still loads at `&1900`

Keep out of scope:
- sprite movement
- animation
- debug-heavy HUD work

### 7. Static multicolour sprite

Status:
Complete. Startup now keeps the Mode 5 black-screen baseline and draws one fixed 12x14 multicolour sprite from packed Mode 5 row-byte data, keeping the software-sprite path direct enough to inspect while still leaving room for later movement and facing variants.

Goal:
Draw one fixed multicolour software sprite at a known pixel position on the black background.

Why this comes next:
It proves the sprite data format and blit path before movement and cleanup logic make the render loop harder to reason about.

Success looks like:
- one intentional sprite is visible on the bitmap screen
- the sprite uses multiple colours from the chosen palette
- the implementation stays small enough to inspect directly in the debugger

Chosen first sprite direction:
- keep the first sprite data compact and Mode 5-friendly so the renderer can write straight into screen memory without an extra abstraction layer
- store the sprite's top-left pixel position in RAM now so later erase, redraw, and movement passes can reuse the same state shape
- keep the background plain black so later erase, redraw, and movement passes can focus on sprite behaviour rather than scene restore complexity

Keep out of scope:
- input-driven movement
- animation timing
- multiple sprites

### 8. Clean erase and redraw

Status:
Complete. The Mode 5 demo now erases the previous image by clearing the covered screen bytes before rebuilding the sprite row data for the next draw, so the black playfield stays clean without falling back to the old `VDU 25` point-plot wipe.

Goal:
Add the minimum background-restore logic needed to remove the old sprite image cleanly before drawing the new one.

Why this comes next:
Smooth-looking software sprites depend on clean redraw behaviour before movement speed is tuned.

Success looks like:
- the sprite can be redrawn without obvious trails
- previous background data is restored in a controlled way
- the code path is still built around one sprite and one simple background

Chosen first restore direction:
- reuse the same screen-row walk for both draw and erase passes so the debugger still has one compact blit path to inspect
- restore the old image by zeroing the sprite's covered Mode 5 screen bytes, which is enough while the background remains a uniform black playfield
- keep the restore logic independent of any one movement pattern so milestone 9 can layer in real input and 1-pixel shifts later

Later refinement:
- the current renderer now updates sprite transitions in one pass across the union of the old and new bounds, staging each row in a tiny RAM buffer so the live screen no longer has to show a separate erase pass before the final image is written

Keep out of scope:
- scrolling backgrounds
- collisions
- content-heavy scene art

### 9. Pixel-based movement and frame pacing

Status:
Complete. The main loop now advances the sprite on a small VSYNC-based cadence, stores its top-left pixel coordinates in RAM, and drives the current demo through a 45-degree bounce path that still accepts live `W`, `A`, `S`, and `D` nudges, so movement happens in 1-pixel steps while edge redraw is exercised on every run.

Goal:
Move the sprite in pixel space with frame-paced updates and RAM-backed position state that can support smoother motion than text-cell stepping.

Why this comes next:
Once redraw is reliable, movement can become visually smoother without mixing in too many rendering unknowns at once.

Success looks like:
- movement is no longer locked to text cells
- the sprite updates at a stable frame rhythm
- position state is ready for fixed-point or sub-pixel expansion if needed

Chosen first movement direction:
- pace sprite updates on a tiny VSYNC counter so the sprite follows a stable, readable movement rhythm instead of max-speed redraw noise
- keep `sprite_x_pixels` and `sprite_y_pixels` as the live top-left position bytes, with reserved fraction bytes alongside them so later fixed-point expansion has an obvious home
- support 1-pixel horizontal steps by selecting prepacked 0-3 pixel shift variants, so the draw loop can copy row bytes instead of rebuilding them live
- use a deterministic diagonal bounce as the current proof because it stress-tests all four screen edges more reliably than manual input during renderer tuning
- keep `W`, `A`, `S`, and `D` polling active so the user can bias the sprite's position without turning off the bounce test

Keep out of scope:
- enemy behaviour
- scrolling maps
- physics beyond simple velocity-free movement

### 10. Animation and visual polish

Status:
Complete. The sprite now flips its source art horizontally as the bounce loop changes horizontal direction and alternates between two small step frames during travel, while the keyboard nudges can still bias its position, so the graphics foundation gets a modest facing read and walk-cycle hint without turning into a full animation system.

Goal:
Add a tiny amount of sprite animation or facing-state polish so the graphics-mode foundation reads as deliberate rather than purely technical.

Why this comes last:
It should build on a stable graphics mode, sprite format, and movement loop instead of masking weaker fundamentals.

Success looks like:
- the sprite has at least one extra frame or facing variation
- the palette and silhouette are readable on the black background
- the repo still feels like a rendering foundation rather than a game system

Findings:
- Mirrored left and right variants are enough to give movement a readable facing state without growing into a large art pipeline.
- A slowed two-frame step toggle adds just enough life to the sprite to prove the render loop can carry animation state, while still keeping the data easy to edit in raw assembly.
- Prepacking frame, facing, and shift variants is a worthwhile trade for this repo size, because it cuts visible redraw flicker without needing a second screen buffer.
- A single-pass transition compositor improves this further because it writes the final row bytes directly, instead of first clearing the old sprite and then drawing the new one on the visible screen.
- The next meaningful polish step is background-aware sprite restore or a second entity, not a larger animation set.

Keep out of scope:
- a large asset pipeline
- level art
- production-ready animation systems

## After milestone 10

The first ten milestones in this handoff are now complete.
The repo has a black-screen Mode 5 foundation, direct screen-memory sprite redraw, frame-paced pixel movement, and a tiny facing plus step-animation proof. The current demo now exercises that movement through a diagonal bounce loop while still polling `W`, `A`, `S`, and `D` so edge redraw behaviour is easy to inspect without losing live control.

Useful next directions from here:

- background-aware restore for non-black playfields or simple scene dressing
- a second sprite or collision probe so the current blit path is exercised beyond one entity
- a small room or camera-boundary experiment that still preserves the current one-screen foundation
