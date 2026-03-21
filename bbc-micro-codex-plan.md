# BBC Micro Model B Assembly Dev Environment on macOS

## Purpose

Turn the research into a practical repo and VS Code workflow that Codex can build iteratively on your Mac mini, with a tight loop similar to your C64 repo:

- edit assembly
- build a bootable DFS disc image
- run or re-run it in an emulator
- debug with breakpoints, stepping, memory and disassembly views
- keep the repo simple enough for Codex to evolve safely

---

## Recommended stack

Use this as the default baseline:

- **Assembler:** BeebAsm
- **Primary emulator/debugger:** b2 Debug
- **Build orchestration:** Make + shell scripts + `curl`
- **Editor integration:** VS Code tasks
- **Optional secondary debugger:** MAME
- **Optional future alternative emulator:** b-em

### Why this stack

BeebAsm and b2 Debug are the right core choices for the first version of the repo because they match the workflow you already like on C64:

- BeebAsm is BBC-specific rather than a generic 6502 assembler.
- BeebAsm can build directly to a **DFS disc image**.
- BeebAsm can create a `!Boot` flow so the emulator boots the latest build automatically.
- b2 Debug gives you the VICE-style features that matter most: breakpoints, stepping, disassembly, memory inspection, and machine-specific visibility.
- b2 Debug also gives you a **local HTTP API**, which is the key to making the repo automation feel modern and Codex-friendly.

### Default target assumptions

Unless you later decide otherwise, the repo should target:

- **BBC Micro Model B**
- **DFS disc-image workflow**
- **single-disc bootable build output**
- **cross-development from macOS**

That keeps the first iteration simple and broadly compatible.

---

## What the repo should do

The repo should support four core workflows.

### 1. Build

Given `src/game.asm`, produce:

- a bootable DFS disc image in `build/`
- a main executable file on the disc, for example `GAME`
- a boot path so the emulator starts the latest build without manual loading

### 2. Run

A single command should:

- build the project
- ask b2 Debug to reset
- mount/run the new disc image
- leave the emulator open for inspection

### 3. Debug

The environment should make it easy to:

- set breakpoints in b2 Debug
- re-run the latest build quickly
- inspect CPU state, memory and disassembly
- optionally trap using `BRK` in assembly during development

### 4. Iterate with Codex

Codex should be able to understand the repo with minimal explanation and safely perform changes using a predictable set of commands:

- `make build`
- `make run`
- `make clean`

---

## Repo design

Use this repo shape.

```text
beeb-vibe-coding/
  .codex/
    config.toml
  .vscode/
    tasks.json
    launch.json
  build/
  docs/
    toolchain.md
    workflow.md
  scripts/
    bootstrap_macos.sh
    build.sh
    run_b2_http.sh
    launch_b2.sh
    verify_toolchain.sh
  src/
    game.asm
    lib/
      os.asm
      macros.asm
  Makefile
  README.md
```

### Notes on structure

- `build/` is generated output only.
- `src/game.asm` is the entry point for the first program.
- `src/lib/` is where reusable BBC assembly helpers should go once the repo grows.
- `scripts/` contains all OS/tool glue so the Makefile stays readable.
- `docs/` explains the toolchain and the intended workflow for both you and Codex.

---

## Implementation plan for Codex

This is the sequence I would feed into Codex. Each step is small, testable, and leaves the repo in a working state.

---

## Phase 1 — Bootstrap the repo skeleton

### Goal

Create the basic repo structure, placeholder files, and a README that explains the intended workflow.

### What Codex should do

1. Create the directory structure shown above.
2. Add a `README.md` describing the purpose of the repo.
3. Add `docs/toolchain.md` explaining the chosen stack:
   - BeebAsm
   - b2 Debug
   - Make
   - shell scripts
   - VS Code tasks
4. Add `docs/workflow.md` describing the edit → build → run → debug loop.
5. Add a `.gitignore` that excludes `build/`, temporary files, and macOS junk files.

### Acceptance criteria

- Repo tree exists.
- README explains how the project is meant to work.
- Generated files are ignored.

### Codex prompt

```text
Create the initial repo skeleton for a BBC Micro Model B assembly game development environment on macOS.

Requirements:
- Create folders: .codex, .vscode, build, docs, scripts, src, src/lib
- Create README.md, docs/toolchain.md, docs/workflow.md, .gitignore, Makefile
- README should explain that the repo uses BeebAsm + b2 Debug + Make + VS Code tasks
- docs/toolchain.md should explain why those tools were chosen
- docs/workflow.md should describe the edit/build/run/debug loop
- .gitignore should ignore build output, .DS_Store, and common temp files
- Do not add game logic yet
- Keep the content concise and practical
```

---

## Phase 2 — Add macOS bootstrap and tool verification

### Goal

Make it easy to prepare a Mac mini for the repo.

### What Codex should do

1. Create `scripts/bootstrap_macos.sh`.
2. The script should:
   - check for Homebrew
   - print install guidance for missing tools
   - verify Xcode Command Line Tools are available
   - verify `curl`, `make`, and `git`
3. Create `scripts/verify_toolchain.sh`.
4. The verification script should:
   - check whether `beebasm` is on PATH
   - check whether b2 Debug is installed in `/Applications`
   - optionally check for `mame`
   - print a readable status summary
5. Document how to install BeebAsm from source if it is not already on PATH.

### Acceptance criteria

- Running the verify script clearly tells you what is present and what is missing.
- No hard dependency on MAME.

### Codex prompt

```text
Add macOS setup scripts for the BBC Micro repo.

Requirements:
- Create scripts/bootstrap_macos.sh and scripts/verify_toolchain.sh
- Scripts must be bash with strict mode enabled
- verify_toolchain.sh must check for: beebasm, make, curl, git, and b2 Debug in /Applications
- MAME should be optional and reported as optional
- Output should be human-readable with pass/warn/fail style messages
- Do not auto-install BeebAsm from the internet; just verify and print next steps
- Add usage notes to README.md
```

---

## Phase 3 — Add the first BeebAsm build pipeline

### Goal

Build a bootable DFS disc image from a minimal assembly source.

### What Codex should do

1. Create `src/game.asm` as a very small BBC Micro assembly program.
2. Add a `Makefile` with:
   - `build`
   - `run`
   - `clean`
   - `verify`
3. Add `scripts/build.sh` that:
   - creates `build/`
   - runs BeebAsm against `src/game.asm`
   - outputs a disc image such as `build/game.ssd`
4. Ensure the assembled output is written onto the DFS image as `GAME`.
5. Ensure the build is bootable so it runs automatically when mounted/reset.
6. Make build errors easy to read.

### Acceptance criteria

- `make build` produces `build/game.ssd`.
- The disc image contains the program and boot path.
- A failed assembly exits non-zero and prints useful output.

### Codex prompt

```text
Add the first working BeebAsm build pipeline.

Requirements:
- Create src/game.asm as a minimal BBC Micro assembly program that visibly proves execution, such as setting a mode and printing a message
- Create scripts/build.sh to assemble src/game.asm with BeebAsm
- Output must be build/game.ssd
- The disc image must contain a runnable GAME file and boot automatically into it
- Update the Makefile to expose make build, make clean, and make verify
- Keep the pipeline simple and well commented
- Update README.md with exact build instructions
```

---

## Phase 4 — Add b2 Debug run integration

### Goal

Re-run the latest build from the command line without manually reloading the disc in the emulator.

### What Codex should do

1. Create `scripts/run_b2_http.sh`.
2. The script should:
   - fail clearly if the disc image is missing
   - call the b2 Debug local HTTP API
   - reset the current machine
   - upload/run `build/game.ssd`
3. Create `scripts/launch_b2.sh`.
4. The launcher script should:
   - attempt to open b2 Debug on macOS using `open`
   - print guidance if the app is missing
5. Wire `make run` so it:
   - builds first
   - launches b2 Debug if needed
   - calls the HTTP run script

### Acceptance criteria

- `make run` rebuilds and re-runs the current disc image.
- The workflow works when b2 Debug is already open.
- Error messages are clear if b2 Debug is unavailable.

### Codex prompt

```text
Integrate b2 Debug into the repo run workflow.

Requirements:
- Create scripts/run_b2_http.sh and scripts/launch_b2.sh
- run_b2_http.sh must call b2 Debug's local HTTP API to reset and run build/game.ssd
- launch_b2.sh must try to open b2 Debug from /Applications on macOS
- Update Makefile so make run performs build then launch then HTTP run
- All scripts must fail cleanly with helpful messages
- Update README.md and docs/workflow.md with the new flow
```

---

## Phase 5 — Add VS Code task integration

### Goal

Give you a one-key build/run workflow inside VS Code.

### What Codex should do

1. Create `.vscode/tasks.json` with tasks for:
   - verify
   - build
   - run
   - clean
2. Add `.vscode/launch.json` only if useful for task launching or compounds.
3. Mark the default build task.
4. Make task labels obvious and BBC-specific.
5. Document the keyboard flow in the README.

### Acceptance criteria

- VS Code shows build and run tasks.
- Running the build task performs `make build`.
- Running the run task performs `make run`.

### Codex prompt

```text
Add VS Code integration for the BBC Micro repo.

Requirements:
- Create .vscode/tasks.json with tasks: Beeb verify, Beeb build, Beeb run, Beeb clean
- The build task should be the default build task
- Use shell tasks that call make targets
- Add launch.json only if it adds practical value
- Update README.md with how to trigger the tasks in VS Code
- Keep the configuration minimal and readable
```

---

## Phase 6 — Make the repo Codex-friendly

### Goal

Reduce ambiguity so Codex can work on the repo repeatedly without drift.

### What Codex should do

1. Create `.codex/config.toml`.
2. Add a short section to `README.md` called something like `Working with Codex`.
3. Define the three commands Codex should prefer:
   - `make verify`
   - `make build`
   - `make run`
4. Add a small troubleshooting section.
5. Add a rule in the docs that all future automation should go through Make targets or scripts, not random one-off shell commands.

### Acceptance criteria

- A new Codex session can understand how to operate the repo from the README alone.
- The repo exposes a small stable command surface.

### Codex prompt

```text
Make the repo Codex-friendly.

Requirements:
- Create .codex/config.toml with a conservative approval policy
- Add a 'Working with Codex' section to README.md
- Document that the preferred commands are make verify, make build, and make run
- Add a short troubleshooting section for missing BeebAsm, missing b2 Debug, and HTTP API issues
- Keep the guidance practical and opinionated
```

---

## Phase 7 — Add first debugging conventions

### Goal

Make the debugger workflow explicit rather than tribal knowledge.

### What Codex should do

1. Add `docs/debugging.md`.
2. Document:
   - how to set breakpoints in b2 Debug
   - how to re-run the latest build
   - how to use `BRK` during development
   - where the output disc image lives
3. Add optional Make targets if useful:
   - `make launch`
   - `make debug-help`
4. Keep the first version simple.

### Acceptance criteria

- The repo teaches the debugging loop.
- The instructions are short enough to be usable while coding.

### Codex prompt

```text
Add debugging guidance to the BBC repo.

Requirements:
- Create docs/debugging.md
- Explain the intended b2 Debug workflow: set breakpoint, run build, run latest image, inspect memory/disassembly, repeat
- Mention BRK as an optional development trap mechanism
- Add any tiny convenience Make targets only if they improve usability
- Do not overcomplicate the docs
```

---

## Phase 8 — Add a reusable assembly foundation

### Goal

Prepare the repo for real game work instead of a one-file demo.

### What Codex should do

1. Add `src/lib/os.asm` for OS entry points and BBC constants.
2. Add `src/lib/macros.asm` for common helpers and future macros.
3. Refactor `src/game.asm` to include those files.
4. Keep the program behaviour the same.
5. Avoid premature abstraction.

### Acceptance criteria

- The project still builds and runs exactly as before.
- Shared constants move out of the main file.

### Codex prompt

```text
Refactor the initial BBC Micro assembly project into a slightly more maintainable structure.

Requirements:
- Add src/lib/os.asm for common OS call addresses and BBC-related constants
- Add src/lib/macros.asm for small reusable helpers if appropriate
- Update src/game.asm to include the shared files
- Preserve the same build output and runtime behaviour
- Do not introduce game systems yet
```

---

## Phase 9 — Add quality-of-life validation

### Goal

Catch common mistakes early and make the repo robust.

### What Codex should do

1. Improve `make verify` so it validates:
   - BeebAsm present
   - b2 Debug presence or at least expected app path
   - required scripts executable
   - build directory writable
2. Add a small status summary after successful build.
3. Ensure scripts use strict bash mode.
4. Standardise exit codes and error text.

### Acceptance criteria

- You can diagnose environment problems quickly.
- Codex gets clear failure signals.

### Codex prompt

```text
Harden the BBC Micro repo workflow.

Requirements:
- Improve make verify and the verification script so it checks tool availability, app presence, executable script permissions, and writable build output
- Standardise shell scripts on strict mode
- Print concise but informative status messages
- Keep the implementation simple and maintainable
```

---

## Phase 10 — Prepare for actual game development

### Goal

Finish the environment work and set the repo up for the first real gameplay milestones.

### What Codex should do

1. Add a `docs/next-steps.md` file.
2. Outline the first game-facing milestones:
   - clear screen / set mode
   - draw static player or enemy state
   - keyboard input
   - simple movement
   - sprite-like or character-based rendering experiments
3. Keep it as a plan, not implementation.

### Acceptance criteria

- The repo is now clearly an environment repo with a path into game work.
- Nothing game-heavy is built prematurely.

### Codex prompt

```text
Add a next-steps planning document to the BBC Micro repo.

Requirements:
- Create docs/next-steps.md
- Outline these first gameplay-facing milestones in order:
  - clear screen / set mode
  - draw static player or enemy state
  - keyboard input
  - simple movement
  - sprite-like or character-based rendering experiments
- Keep it planning-only, not implementation
- Make it suitable for feeding into future Codex sessions
- Keep the repo framed as an environment-first foundation rather than a game-heavy starter
```

---

## Current repo status

At the time of this review, the environment plan is effectively complete through the main setup phases:

- Phases 1 to 9 are represented in the current repo structure, scripts, docs, and Make targets.
- The repo now also includes optional debug helpers beyond the original minimum surface: `make reset`, `make peek`, `make poke`, `make where`, and `make debug-help`.
- Phase 10 remains intentionally planning-only and can be added later as `docs/next-steps.md` when you want to pivot from environment setup into gameplay work.

---

## Suggested Make target surface

Keep the public command surface small.

```makefile
make verify
make build
make run
make clean
make launch
```

### Meaning

- `verify` — check the local environment
- `build` — assemble and create the DFS image
- `run` — build and re-run in b2 Debug
- `clean` — remove generated output
- `launch` — open b2 Debug without running a build

That is enough for the first version.

---

## Suggested VS Code experience

Aim for this exact editor behaviour:

- **Default build task:** `Beeb build`
- **Second task:** `Beeb run`
- **Optional task:** `Beeb verify`
- **Optional task:** `Beeb clean`

This gives you a friction-free loop while keeping the actual logic in Make and scripts, which is better for Codex and for future portability.

---

## What not to do in version 1

Avoid these until the base repo is working well:

- do not add multiple assemblers
- do not build a custom VS Code extension yet
- do not over-engineer source layout
- do not add MAME as a required path
- do not target real hardware deployment in the first pass
- do not try to solve every future game concern during environment setup

The first win is simple: **reliable build, reliable run, reliable debug, repeatable repo structure**.

---

## Recommended order to feed into Codex

Use the phases in this order:

1. Phase 1 — repo skeleton
2. Phase 2 — macOS verification
3. Phase 3 — BeebAsm build pipeline
4. Phase 4 — b2 Debug run integration
5. Phase 5 — VS Code tasks
6. Phase 6 — Codex friendliness
7. Phase 7 — debugging docs
8. Phase 8 — reusable assembly foundation
9. Phase 9 — hardening
10. Phase 10 — next-step planning

That sequence keeps each session bounded and testable.

---

## Final recommendation

Build the repo around **BeebAsm + b2 Debug first**, and treat everything else as optional.

That gives you the best balance of:

- BBC-specific assembly workflow
- macOS practicality
- emulator-driven debugging
- scriptable iteration
- Codex-friendly automation

In other words, it is the closest BBC Micro equivalent to the development style you already have with your C64 repo.

---

## One-shot master prompt for Codex

If you want a single larger prompt rather than phase-by-phase prompts, use this:

```text
Build a macOS-first BBC Micro Model B assembly game development repo.

Target workflow:
- BeebAsm assembles the project
- Output is a bootable DFS disc image in build/game.ssd
- b2 Debug is the primary emulator/debugger
- The repo must support a tight edit -> build -> run -> debug loop
- VS Code tasks should call Make targets
- Codex should be able to operate the repo mainly through make verify, make build, and make run

Please implement this in safe, incremental steps inside the repo:
1. Create the repo skeleton with docs, scripts, src, .vscode, and .codex
2. Add macOS verification scripts for toolchain readiness
3. Add a working BeebAsm build pipeline that creates build/game.ssd from src/game.asm and auto-boots the GAME program
4. Add b2 Debug integration using its local HTTP API so make run rebuilds and reruns the latest disc image
5. Add VS Code tasks for verify, build, run, and clean
6. Add concise documentation for workflow and debugging
7. Refactor shared constants into src/lib only after the initial build works
8. Keep all automation behind Make targets and scripts

Constraints:
- Keep the first version simple and maintainable
- Use bash scripts with strict mode
- Keep MAME optional only
- Do not create a custom VS Code extension
- Do not over-engineer the source layout
- Make all error messages practical and readable
- Update README.md as each capability is added

Success criteria:
- make verify reports tool readiness clearly
- make build creates build/game.ssd
- make run rebuilds and reruns the disc image in b2 Debug
- VS Code tasks work without needing custom extensions
- A new Codex session can understand the repo by reading the README
```
