# PLANS.md

Use this file for bigger features, refactors, or emulator/debug workflow work.
Keep it short and keep it current.

## Template

### Goal
One paragraph on the change and why it matters.

### Constraints
- Keep Make as the main command surface.
- Keep BeebAsm + b2 Debug as the default path.
- Avoid breaking the simple edit -> build -> run loop.

### Files likely to change
- List exact files.

### Plan
1. Inspect current files and command flow.
2. Make the smallest useful change.
3. Verify with the relevant Make targets.
4. Update docs if behaviour changed.

### Verification
- Commands to run.
- Expected result.

### Progress log
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

### Notes / decisions
- Record assumptions and tradeoffs.
