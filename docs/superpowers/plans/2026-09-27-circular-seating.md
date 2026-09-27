# Circular Seating Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task after review. Steps use checkbox syntax for tracking.

**Goal:** Build a PureBasic calculator that explains and illustrates circular seating counts for 1–21 people.

**Architecture:** A small calculation include supplies validation, exact counts, and worked text. A desktop entry point owns the window, event handling, and canvas drawing. Draw one example without generating permutations.

**Tech Stack:** PureBasic, native gadgets, CanvasGadget, built-in 2D drawing.

**Spec:** [Circular seating design](../specs/2026-09-27-circular-seating-design.md). Both documents are drafts for user review.

## Global constraints

- PureBasic with built-in GUI and drawing facilities; no added dependencies.
- Accept 1–21 people only; use signed 64-bit `.q` arithmetic for counts.
- Keep calculation independent of GUI and drawing.
- Target the current macOS workspace first; cross-platform verification is outside this initial scope.

## Files

- `src/seating.pbi`: input validation, counting, worked calculation text.
- `src/main.pb`: window, controls, event loop, table drawing.
- `tests/seating_tests.pb`: standalone checks of meaningful calculation and validation behavior.
- `README.md`: running instructions, rules, limit, and verification steps.

## Review focus

1. Large pasted input must be rejected without overflow or partial parsing — Task 1.
2. One person must produce 0! = 1 and a valid diagram — Tasks 1 and 3.
3. The maximum count must remain exact — Tasks 1 and 2.
4. Editing input must not leave a misleading old answer — Task 2.
5. All 21 labels and the long calculation must remain readable — Tasks 2 and 3.

## Task 1: Exact calculation and validation

**Files:** `src/seating.pbi`, `tests/seating_tests.pb`.

**Interfaces:** `ParsePeople.i(text.s)` returns 1–21 or 0 for invalid input; `CountArrangements.q(people.i)` returns the count or 0 outside the supported range; `BuildWorking.s(people.i)` returns the worked equation or an empty string for invalid input.

- [ ] Locate the installed PureBasic IDE/compiler and record its version and actual invocation. If absent, report the build prerequisite without claiming verification.
- [ ] Create standalone tests using built-in facilities. Pin counts: 1 → 1, 2 → 1, 3 → 2, 5 → 24, 21 → 2432902008176640000. Check invalid count arguments 0 and 22 return 0.
- [ ] Test parsing: accept `1`, `21`, ` 5 `, `005`; reject empty text, whitespace, `0`, `22`, `-1`, `+5`, `2.5`, `5abc`, and 100 repeated `9` characters. Check working text for 1 and 5 against the spec.
- [ ] Run tests before implementation to establish that required procedures are missing.
- [ ] Implement the three procedures with `EnableExplicit`. Validate digit text and range before conversion; compute factorial iteratively using `.q` throughout and format the result without floating-point conversion.
- [ ] Compile and run the test executable using the discovered compiler; require all checks to pass and a failing process exit status for any failed check.

## Task 2: Calculator window

**Files:** `src/main.pb`.

**Interfaces:** Consumes the three Task 1 procedures. Produces the desktop event loop; maintains the last valid submitted people count for drawing.

- [ ] Build the proposed 760 × 760 window, count input, Calculate button, result, wrapped working, explanatory text, and reserved canvas area. Use the spec's default of 5.
- [ ] Wire Calculate and Enter to the same calculation action. Clear the result and canvas on input edits; show the specified error on invalid submission.
- [ ] Compile and manually verify 1, 5, and 21, including the full exact maximum value and wrapped expansion. Check invalid submissions, editing after a valid result, keyboard navigation, and closing the window.

## Task 3: Seating illustration and delivery

**Files:** `src/main.pb`, `README.md`.

**Interfaces:** Add `DrawSeating(canvas.i, people.i)`, consuming only a canvas ID and a validated count; no counting logic inside drawing.

- [ ] Draw the table and evenly spaced numbered markers using canvas dimensions. Fix person 1 at the top; highlight and identify that person. Add “One example arrangement”.
- [ ] Connect drawing to successful submissions and initial display.
- [ ] Inspect the running window at 1, 2, 5, and 21 people. Require exact marker counts, legible labels, no overlap or clipping, and correct redraw after changing counts and uncovering the window. Capture representative screenshots for review.
- [ ] Write README instructions using the actual compiler/IDE setup, explaining rotation equivalence, the illustrative diagram, and the 21-person limit.
- [ ] Run the calculation checks and complete the GUI checks on the final version. Report results and any environment limitations; do not claim GUI verification from source inspection alone.

## Review and execution

Review the proposed defaults, layout, and input behavior before implementation. Direct implementation in this session is sufficient for this small program. No product code, compiler installation, or repository initialization is part of this planning change.
