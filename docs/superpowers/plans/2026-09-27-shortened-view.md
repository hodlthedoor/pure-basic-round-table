# Shortened and Extended View Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Offer Shortened and Extended presentations for every supported count, opening in Shortened.

**Architecture:** Preserve the independently verified generator. Regroup its algebraic schedules into equal-length orbits of one label permutation, recording starting rows and successor cycles in the existing metadata. Keep the seven existing published cyclic constructions. Replace the checkbox with a labelled native selector and preserve the choice across generation, editing and cancellation.

**Tech Stack:** PureBasic, existing native macOS controls and test tools; no dependencies.

**Spec:** User-approved design in this conversation: explicit Shortened / Extended selector, both available throughout, Shortened by default, starting rows with repeaters and cycle instructions.

## Constraints and review focus

- Support 3–21; no full schedule lookups or changes to neighbour coverage.
- Shortened rows must expand exactly to the displayed extended schedule, including wraparound and reversal equivalence when matching generated rows.
- Three people require one sitting in either view; explain this honestly.
- Preserve selection-to-circle mapping across views and the chosen view across input changes.
- Keep instructions legible at minimum window size, including multiple simultaneous cycles.
- Cancellation and stale-job protections continue to apply.

## Task 1: Compact metadata for all counts

Files: src/model.pbi, src/constructions.pbi, src/solver.pbi, tests/solver_tests.pb.

- [x] Add failing tests requiring cyclic metadata for all 19 counts, complete independent expansion from starters, correct mapping and finite cycle closure.
- [x] Add `CompactProjective(*job.GenerationJob)` returning success. For fields of even order use multiplication by a primitive element (fix zero and infinity); for odd order use addition by one (fix infinity). Enumerate orbits against the generated schedule, matching either orientation with infinity first. Reject missing/reused rows, early closure or capacity overflow. Reorder rows in cycle order and record metadata. Increase starter capacity to 12 (the 10-person case has twelve 3-sitting groups).
- [x] Invoke regrouping after algebraic generation, before final independent verification and publication. Existing published constructions retain their rows and metadata.
- [x] Run solver tests and independently verify all exported schedules.

## Task 2: Explicit selector and documentation

Files: src/app.pbi, src/presentation.pbi, tests/gui_tests.pb, README.md.

- [x] Replace checkbox with a labelled native Shortened / Extended selector. Default to Shortened and retain choice during input changes. Enable for every verified schedule.
- [x] Show starting-row counts versus total sittings, fixed labels (repeaters), cycles and expansion period. Explain the single-sitting case. Maintain compact-to-extended selection mapping.
- [x] Extend native GUI checks: default five-person two-row view, switch to all six rows and back; all 19 counts in both views; preference retention, diagram selection, 21-person groups, cancellation and minimum layout.
- [x] Run solver and GUI checks, inspect screenshots including algebraic cycles, build and reopen the app. Update README with view behavior and construction details.
- [x] Request final read-only review and resolve actionable findings.

## Execution

The user explicitly requested planning followed by implementation in this turn; proceed inline after saving this plan. No additional approval checkpoint or dependency installation is needed.

## Completion

Implemented and reviewed with no outstanding findings. Verification: 45,378 solver assertions, 189 GUI checks, all 19 schedules independently checked by Python, and successful native app build. Reopened the updated application.
