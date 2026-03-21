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
