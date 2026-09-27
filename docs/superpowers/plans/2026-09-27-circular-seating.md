# Dudeney Round-Table Solver Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans after production-plan review. Steps use checkbox syntax for tracking.

**Goal:** Generate and display a verified Dudeney schedule for every count from 3 to 21.

**Architecture:** Separate construction data and arithmetic from an independent verifier and native GUI. Each generation job owns its mutable state. The event loop advances a bounded batch, then returns to handling input.

**Tech stack:** PureBasic 6.41 Free, native gadgets, CanvasGadget and 2D drawing on macOS arm64.

**Spec:** [Updated design](../specs/2026-09-27-circular-seating-design.md).

## Global constraints

- Support every integer count from 3 to 21.
- Ship attributed construction data; runtime requires no Python or network access.
- Keep generation, verification, and presentation separate.
- Discuss any new dependency before adding it.
- All rows must satisfy the circular, unordered-neighbour-pair rule in the spec.

## Completed feasibility milestone

- [x] Locate the compiler and compile a console probe.
- [x] Research constructions and visually check source numerical data.
- [x] Build an independent verifier with valid and corrupted examples.
- [x] Generate and verify all 19 counts in Python and compiled PureBasic.
- [x] Measure five runs per count and preserve a verified 21-person output.
- [x] Select generation methods and write the production tasks below.
- [x] Review the production plan before implementing the application.

Evidence and provenance: [feasibility report](../../references/solver-feasibility.md). The selected methods use algebraic construction for twelve counts and attributed compact starting rows for seven counts. Local end-to-end medians were approximately 4.5-7.5 ms, including process startup and output.

## Review focus

1. Wraparound and unordered-pair equivalence: corrupt and reverse rows in Task 1.
2. Construction coverage: verify every supported count and repeated jobs in Task 2.
3. Cancellation and stale publication: exercise job replacement in Task 3.
4. Alignment, group selection, and density: inspect 21 people at minimum size in Task 4.
5. Input overflow and stale answers after edits: validate strings and edit during generation in Tasks 1 and 3.

## Files and interfaces

- `src/model.pbi`: `SeatingRow` (21 label slots and group ID), `Schedule` (people count, row count, up to 190 rows), `GenerationJob` (job ID, state, cursor, construction metadata, private result and arithmetic state).
- `src/verify.pbi`: `VerifySchedule.i(*schedule.Schedule)`, true only for complete valid results; independent of construction metadata.
- `src/input.pbi`: `ParsePeople.i(text.s)`, 3-21 on success or 0 for invalid input.
- `src/constructions.pbi`: attributed starting rows, label permutations, and finite-field definitions.
- `src/solver.pbi`: `BeginGeneration.i(people.i, jobId.i, *job.GenerationJob)`, `AdvanceGeneration.i(*job.GenerationJob, maxCandidates.i)`, `CancelGeneration(*job.GenerationJob)`; status returned by advance is Running, Verified, Cancelled, or Failed.
- `src/main.pb`: controls, event handling, rendering, selection and current job ownership; `DrawSeating(canvas.i, *row.SeatingRow, people.i)`.
- `tests/solver_tests.pb`: standalone executable, nonzero exit on failure.
- `README.md`, `scripts/build.sh`, `.gitignore`: reproducible local build and use.

Keep structures and signatures shared in `model.pbi`; avoid solver globals so successive jobs cannot inherit state.

## Task 1: Independent verification and input

- [x] Create model declarations and failing tests using Dudeney's literal 3-, 4-, and 5-person examples. Accept rotations and reversals; reject missing/extra rows, repeated people, out-of-range labels, and duplicate neighbour pairs, including wraparound collisions.
- [x] Add input cases: accept `3`, `21`, ` 5 ` and `005`; reject empty/whitespace, `2`, `22`, `-1`, `+5`, `3.5`, `3abc`, and 100 repeated nines.
- [x] Implement validation before numeric conversion. Implement the verifier using a fresh table indexed by person and sorted neighbour labels. Count distinct coverage independently of generator metadata.
- [x] Add `scripts/build.sh test`, using the installed compiler and required `PUREBASIC_HOME`, to compile and run the test executable. Require exit 0 and no failed assertions.

## Task 2: Verified PureBasic generation

- [x] Add tests requiring complete verified output for every count 3-21; pin sitting counts 1, 6, 66, and 190 for 3, 5, 13, and 21 respectively.
- [x] Add repeated-job tests for 21, 3, 17, 5 and 21 in one process. Require identical valid results regardless of prior jobs and reject invalid counts before writing rows.
- [x] Implement the tested projective construction: finite-field tables, a full fractional-linear cycle, all affine images, and elimination of reversed duplicates. Use the exact field definitions validated by the experimental probe; do not introduce a symbolic-math dependency.
- [x] Port the 49 attributed starting rows and their permutations into a static PureBasic include. Preserve provenance and source-to-application label conversion. Expand groups at runtime; test that each successor step matches its displayed cycle instructions.
- [x] Split expansion into `AdvanceGeneration` batches of at most 16 candidate rows. Record group and construction metadata for the GUI. Check bounds before storing rows, and run `VerifySchedule` before changing state to Verified.
- [x] Run `scripts/build.sh test`; independently check all resulting schedules with the existing experimental Python verifier during development. The installed application requires neither Python nor generated build-time data.

## Task 3: Responsive calculator window

- [x] Build the specified resizable layout with count input, Generate/Cancel, status, numerical list and canvas. Generate 5 on startup.
- [x] Drive generation from a short window timer; store the current job ID. Only publish a Verified result with that ID. Cancel on edit, replacement, or close, and clear the old display on edit.
- [x] Test cancellation before the first batch and after a partial batch, then start a replacement job and verify only its result can be published. Cancelled and failed jobs must expose no result as verified.
- [x] Wire Enter and Generate to the same action. Inspect invalid inputs, keyboard navigation, and cancelling while events remain responsive.

## Task 4: Author-style rows, drawing, and delivery

- [x] Render monospaced two-character label columns with genuine group separators and scrolling. Map selectable items to row indices rather than assuming every list item is a seating.
- [x] Add compact starting-row presentation for the seven cyclic constructions. Show repeaters and cycle rules from metadata. Test compact selection and return to its first expanded seating.
- [x] Draw the selected row clockwise with its first person at the top; highlight the displayed starting point and explain wraparound. Select a different row and verify the picture changes to that exact order.
- [x] Inspect 3, 5, 13 and 21 people, expanded and applicable compact views, all 190 rows, minimum window size, and two-digit labels. Capture screenshots for review.
- [x] Document build/run steps, rules, algorithm provenance, use of starting rows, and measured timings. Add `scripts/build.sh app` to produce the macOS application using native PureBasic facilities.
- [x] Run the complete calculation tests and GUI checks on the final build. Report any checks that could not be performed.

## Handoff

Production implementation, solver and GUI checks, and final code review are complete. The review's keyboard-navigation finding was reproduced, fixed, and verified. See README.md for build/run instructions and docs/references/solver-progress.md for verification evidence and implementation decisions.
