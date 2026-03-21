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

## Phase 14 - Full Graphics Mode Sprite Foundation

### Goal
Move the repo from the current text-cell rendering demo into a true bitmap-screen foundation: black background, one multicolour software sprite, and a movement loop that can grow into smoother sprite-like rendering.

### Constraints
- Keep the change focused on display and movement foundations, not gameplay systems.
- Preserve the Make-based build and run workflow.
- Assume software sprites, not hardware sprites, so the code must own erase, redraw, and frame pacing explicitly.
- Keep the first graphics pass to one sprite and a simple empty background.
- This implementation pass only covers milestone 7: one fixed multicolour software sprite on the Mode 5 baseline.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`
- `src/lib/os.asm`
- `src/lib/macros.asm`

### Plan
1. Keep the existing Mode 5 baseline and choose a tiny sprite format plus fixed pixel position that stay easy to inspect in the debugger.
2. Add a data-driven sprite blit routine that plots one static multicolour sprite onto the black playfield without introducing movement or animation.
3. Record milestone 7 as complete in `docs/next-steps.md` and leave erase/redraw, movement, and pacing work for later milestones.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the demo now boots into Mode 5 with one visible multicolour sprite drawn at a fixed pixel position on the black background.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- Mode 5 is the baseline choice for milestone 6 because it keeps the full 256-line bitmap height, gives four logical colours for an early multicolour sprite, and leaves more headroom than Mode 2 for code plus later sprite buffers.
- The mode 5 screen base is `&5800`, so the assembly guard should stay below that boundary while this repo still loads code at `&1900`.
- The sprite format should stay deliberately simple for milestone 7, even if that means using unpacked per-pixel logical colour bytes before any later optimisation.
- The first sprite should stay fixed on a plain black background so milestone 8 can focus on erase/redraw behaviour without also solving movement.
- Verification for this slice: `make build` passed after adding the static sprite blit path.

## Phase 15 - Milestone 8 Clean Erase And Redraw

### Goal
Add the smallest useful erase-and-redraw path for the Mode 5 sprite demo so the old sprite image is removed cleanly before the new one is drawn.

### Constraints
- Keep the change focused on one sprite and one simple background.
- Avoid input-driven movement, collisions, or scene art.
- Preserve the Make-based build workflow and stay below the Mode 5 screen guard.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Rework the current sprite blit code into reusable draw and erase passes that can target the sprite's previous and current positions.
2. Add a tiny scripted redraw proof so the sprite visibly moves between a couple of fixed positions without leaving trails, while still keeping milestone 9's real movement work separate.
3. Record milestone 8 as complete in `docs/next-steps.md` and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the Mode 5 demo alternates between fixed sprite positions while restoring the old black background cleanly.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- Because the current scene is a plain black playfield, the first restore path can redraw only the sprite's non-zero pixels using logical colour `0` instead of introducing a full background buffer yet.
- The redraw proof alternates between two fixed X anchors so the erase step is visible now without pulling full movement and pacing concerns forward from milestone 9.
- Verification for this slice: `make build` passed after adding the shared draw/erase blit path and scripted redraw loop.

## Phase 16 - Milestone 8 Redraw Refinement

### Goal
Replace the slow `VDU 25` point-plot redraw proof with a faster Mode 5 screen-memory blit so the sprite no longer shows an obvious wipe while moving between test anchors.

### Constraints
- Keep the demo focused on one sprite over a plain black background.
- Keep movement scripted and byte-aligned so this stays a redraw refinement, not a full controls pass.
- Preserve the documented Make workflow.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Pack the current sprite rows into Mode 5 screen-byte data and replace the `VDU 25` per-pixel blit with direct screen-memory writes.
2. Change the scripted redraw proof from one large jump into smaller aligned steps between the same anchors so the visual result is easier to judge.
3. Update the handoff docs to describe the faster blit path and verify with `make build`.

### Verification
- `make build`
- Optional: `make run`
- Expected result: the disc still builds and the sprite moves between the test anchors in smaller steps without the obvious wipe caused by OS point plotting.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The current all-pixel `GCOL` plus `VDU 25` path is useful as a first proof, but it is too slow for a moving sprite and exposes the row-by-row redraw order on real hardware and in emulation.
- For this refinement pass, keeping X positions aligned to 4-pixel screen bytes lets the code stay simple while still making the movement much less abrupt.
- The refined renderer writes the sprite as three packed Mode 5 bytes per row straight into screen memory and erases by zeroing those same row bytes on the black background.
- Verification for this slice: `make build` passed, and `make run` successfully rebuilt, launched `b2 Debug`, reset the `b2` window, and uploaded the latest disc image.

## Phase 17 - Milestones 9 And 10 Movement And Polish

### Goal
Finish the current graphics roadmap by replacing the scripted shuttle with frame-paced pixel movement and adding a tiny amount of facing and animation polish that still fits the foundation-first spirit of the repo.

### Constraints
- Keep the change focused on one sprite on a plain black background.
- Preserve the Mode 5 direct screen-memory blit path rather than falling back to OS point plotting.
- Keep the movement and animation rules small enough to inspect directly in the debugger.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Replace the scripted movement demo with frame-paced `W`, `A`, `S`, and `D` pixel movement using RAM-backed position state and clean erase/redraw.
2. Extend the sprite blit so it can handle 1-pixel X movement and add a minimal two-frame plus facing-state polish pass.
3. Mark milestones 9 and 10 complete in `docs/next-steps.md`, add a short handoff for what comes after the first ten milestones, and verify with `make build` plus `make run`.

### Verification
- `make build`
- `make run`
- Expected result: the disc still builds, the sprite now moves under `W`, `A`, `S`, and `D` in pixel space at a stable frame rhythm, and the character shows a small facing or step animation change while moving.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The current milestone 8 direct-memory blit is the right base to keep, but it needs sub-byte X placement support before the demo can honestly claim 1-pixel movement in Mode 5.
- The finished pass keeps literal per-pixel sprite frame data in source, mirrors it for left-facing movement at draw time, and rebuilds up to four Mode 5 row bytes per scanline when the sprite sits between byte boundaries.
- Verification for this slice: `make build` passed, and `make run` successfully rebuilt, launched `b2 Debug`, reset the `b2` window, and uploaded the latest disc image.

## Phase 18 - Sprite Flicker Reduction

### Goal
Reduce the remaining lower-body sprite flicker by cutting the amount of work done during each visible redraw.

### Constraints
- Keep the current Mode 5 direct screen-memory approach.
- Preserve 1-pixel movement, facing, and the tiny two-frame animation proof.
- Avoid adding a second screen buffer or a more complicated engine.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Replace the current per-row pixel rebuild path with precomputed packed sprite variants for each frame, facing, and 0-3 pixel X shift.
2. Keep the erase path simple while making the draw path just copy packed row bytes into screen memory.
3. Update the handoff docs to describe the faster sprite path and verify with `make build` plus `make run`.

### Verification
- `make build`
- `make run`
- Expected result: the disc still builds, the sprite keeps its current controls and small animation polish, and the remaining lower-body redraw flicker is reduced because the draw loop copies prepacked row data instead of rebuilding it live.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The visual symptom moving from whole-sprite wipe to lower-half and then lower-third shimmer strongly suggests the redraw is mostly fast enough already, but still not fast enough for the last few rows at the current sprite Y position.
- The fix keeps the same erase path but replaces the live row builder with prepacked frame, facing, and X-shift variants, so the visible draw loop now copies four bytes per row instead of rebuilding them pixel by pixel.
- Verification for this slice: `make build` passed, and `make run` successfully rebuilt, launched `b2 Debug`, reset the `b2` window, and uploaded the latest disc image.

## Phase 19 - Diagonal Bounce Stress Test

### Goal
Turn the current sprite demo into a deterministic 45-degree bounce loop so edge redraw behaviour is easier to inspect than with manual keyboard movement.

### Constraints
- Keep the current Mode 5 direct screen-memory sprite path.
- Preserve the existing erase/draw structure and left-right facing polish.
- Keep the change small enough to review in one pass and verify with the normal Make workflow.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Replace the live keyboard movement path with horizontal and vertical direction state that advances the sprite one pixel per step and flips when it reaches a screen edge.
2. Keep the current animation and facing behaviour tied to the horizontal component so the bounce path still exercises the packed left and right sprite variants.
3. Update the docs to describe the new autonomous motion test and verify with `make build` plus `make run`.

### Verification
- `make build`
- `make run`
- Expected result: the disc still builds, the sprite moves diagonally across the screen, and it bounces cleanly off all four visible edges while keeping the current packed-sprite redraw path.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- A deterministic bounce path is a better stress test for the current renderer than manual input because it reliably exercises the top edge, bottom edge, and both horizontal facings on every run.
- The final implementation reuses `sprite_facing` as the horizontal travel direction, adds one vertical-direction byte, and removes the now-unused keyboard polling path from the hot loop.
- Verification for this slice: `make build` passed, and `make run` successfully rebuilt, launched `b2 Debug`, reset the `b2` window, and uploaded the latest disc image. Timed screen captures showed the sprite changing position under the autonomous bounce loop.

## Phase 20 - Hybrid Bounce And Keyboard Steering

### Goal
Keep the deterministic diagonal bounce path, but restore keyboard polling so `W`, `A`, `S`, and `D` can shift the sprite while the autonomous movement continues.

### Constraints
- Keep the current packed Mode 5 sprite redraw path.
- Preserve edge bouncing on all four sides of the screen.
- Keep the implementation small and easy to inspect in the debugger.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Restore the keyboard polling path and RAM-backed key state bytes.
2. Apply manual key nudges after each autonomous bounce step, while clamping at the screen edges and flipping the stored movement direction when an edge is pushed.
3. Update the docs to describe the hybrid control scheme and verify with `make build` plus `make run`.

### Verification
- `make build`
- `make run`
- Expected result: the disc still builds, the sprite continues its 45-degree bounce loop, and `W`, `A`, `S`, and `D` can shift its position without breaking edge bouncing.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- Applying manual nudges after the autonomous step keeps the bounce path readable while still letting the keyboard bias the sprite's position.
- The hybrid pass restores RAM-backed `W`, `A`, `S`, and `D` state, then applies those nudges after the autonomous bounce step so the sprite keeps moving even while the user steers it.
- Verification for this slice: `make build` passed, and `make run` successfully rebuilt, launched `b2 Debug`, reset the `b2` window, and uploaded the latest disc image. I could not get a reliable scripted keypress into `b2 Debug`, so live keyboard steering still needs a quick manual check in the emulator.

## Phase 21 - Single-Pass Sprite Transition Fix

### Goal
Reduce the remaining top-edge flicker and bottom-edge corruption by replacing the current erase-then-draw update with a single-pass final-image write for the union of the old and new sprite bounds.

### Constraints
- Keep the current packed Mode 5 sprite data and direct screen-memory approach.
- Preserve the bounce loop and keyboard steering.
- Keep the change local to the sprite transition path rather than introducing full page flipping.

### Files likely to change
- `PLANS.md`
- `docs/next-steps.md`
- `src/game.asm`

### Plan
1. Replace the visible-screen erase plus redraw sequence with a transition compositor that writes the final row bytes for the old/new union rectangle.
2. Keep using the prepacked current-frame sprite rows, but stage each transition row through a tiny RAM buffer so each affected screen byte is written once.
3. Update the docs to mention the single-pass redraw fix and verify with `make build` plus `make run`.

### Verification
- `make build`
- `make run`
- Expected result: the disc still builds, the sprite keeps moving under the current hybrid controls, and the previous visible wipe/corruption is reduced because the transition path no longer clears the old image in a separate pass.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The persistent top flicker and bottom-edge corruption were both consistent with the beam catching a two-pass visible-screen update: the old image was being zeroed before the new image had finished drawing.
- The fix computes the union of the old and new sprite bounds, stages the final bytes for each transition row in a 5-byte RAM buffer, and writes those screen bytes once instead of erasing and redrawing them separately.
- An initial compositor bug left trails because it did not seed `current_scanline_in_band` before using the existing row-advance helper; fixing that restored correct row walking.
- Verification for this slice: `make build` passed, and `make run` successfully rebuilt, launched `b2 Debug`, reset the `b2` window, and uploaded the latest disc image. Timed emulator screenshots showed the sprite moving cleanly without the earlier trail artefacts from the broken compositor.

## Phase 22 - Packed Sprite Foot Cleanup

### Goal
Remove the remaining bounce-dependent shape distortion by fixing the packed sprite rows themselves, rather than trying to hide bad bottom-row data in the blitter.

### Constraints
- Keep the current packed Mode 5 renderer and single-pass transition compositor.
- Preserve the current 12x14 sprite footprint and two-frame stepping feel.
- Keep the change local to sprite art data so movement and redraw logic stay easy to compare.

### Files likely to change
- `PLANS.md`
- `src/game.asm`

### Plan
1. Decode the existing packed variants to confirm whether the stray lower pixels come from the data or the compositor.
2. Replace the broken lower-row bytes with regenerated packed variants that keep the feet attached and mirrored consistently across shifts and facings.
3. Verify with `make build`, `make run`, and a fresh frame-by-frame screenshot capture from `b2 Debug`.

### Verification
- `make build`
- `make run`
- Expected result: the disc still builds, the sprite keeps its current bounce path and stepping, and the lower edge no longer swaps detached pixels when the direction changes.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- Decoding the packed variant tables back into images showed that the detached bottom pixels were already present in the source data, so the compositor was faithfully drawing a bad shape.
- The refreshed packed rows keep frame 0 on a stable wide-stance silhouette and use a narrower, still-attached foot pattern for frame 1 so the step animation survives without the old side-swapping artefacts.
- Verification for this slice: `make build` passed, `make run` rebuilt and uploaded the latest disc image to `b2 Debug`, and a fresh four-frame screenshot capture showed the lower edge staying attached instead of swapping detached white foot pixels on each bounce.

## Phase 23 - Static Reference Sprite And Tighter Capture

### Goal
Make the remaining shape issue easier to inspect by keeping a static reference copy of the sprite on screen and producing tighter diagnostic captures around the emulator output.

### Constraints
- Keep the current packed Mode 5 renderer in place while debugging the art.
- Preserve the existing moving sprite behavior so comparisons stay meaningful.
- Avoid introducing a heavyweight workflow change unless the current `b2 Debug` tooling truly needs it.

### Files likely to change
- `PLANS.md`
- `src/game.asm`

### Plan
1. Add a persistent static reference sprite at the original start position and move the live sprite start point away from it so both are visible together.
2. Redraw that reference sprite each frame after the moving sprite update so the transition compositor cannot accidentally wipe it out.
3. Verify with `make build`, `make run`, and a fresh capture sequence cropped around both the static and moving sprites.

### Verification
- `make build`
- `make run`
- Expected result: the moving sprite still bounces and responds to nudges, while a static comparison sprite remains visible at the original start position in the same scene.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- Probing the local `b2 Debug` HTTP API with the same server used by `make run` showed `peek` working but screenshot-like routes returning `Unknown request type`, so screenshot capture does not appear to be exposed over the HTTP API in this build.
- The most reliable capture path on this machine was `System Events` frontmost control for the `b2` process followed by `screencapture`; activating `b2 Debug` by app name alone often left VS Code in front.
- The new comparison setup keeps a static reference sprite on the original spawn point and starts the moving sprite lower on the same X column. The resulting captures show the moving sprite present in the early frames, then disappearing later in the sampled sequence, which gives us a cleaner next debugging target than the previous desktop-wide captures.

## Phase 24 - Symmetric Ball Sprite On Red Background

### Goal
Replace the current distorted character-like sprite with a simple symmetric ball design and switch the playfield background from black to red.

### Constraints
- Keep the existing packed Mode 5 renderer and current movement/debug setup.
- Preserve strong contrast between the sprite and the new background.
- Keep the sprite horizontally symmetric so bounce direction no longer changes its silhouette.

### Files likely to change
- `PLANS.md`
- `src/game.asm`

### Plan
1. Remap the palette so logical colour 0 becomes red and the sprite colours remain distinct.
2. Replace the packed sprite variants with a new symmetric ball design, keeping both animation frames consistent.
3. Verify with `make build`, `make run`, and a fresh `b2` screenshot capture.

### Verification
- `make build`
- `make run`
- Expected result: the playfield clears red, the static and moving sprites render as the same symmetric ball, and their silhouette no longer changes with bounce direction.

### Progress log
- [x] Step 1
- [x] Step 2
- [x] Step 3

### Notes / decisions
- The most reliable way to keep the ball symmetric across bounce direction was to generate all packed variants from one canonical 12x14 design and reuse the same data for both animation frames.
- A live `b2` screenshot showed the two non-white sprite colours landing opposite to the initial offline preview, so the final fix was to swap the primary/secondary palette assignments rather than regenerate the sprite a second time.
- Verification for this slice: `make build` passed, `make run` rebuilt and uploaded the latest disc image to `b2 Debug`, and a frontmost-window capture confirmed a red playfield with the new symmetric ball sprite visible for both the static reference and the moving copy.
- Follow-up art tweak: the packed ball now leaves a small red ring inside the yellow shell, and the latest live capture is saved at `build/screenshots/phase24c-emulator.png`.
