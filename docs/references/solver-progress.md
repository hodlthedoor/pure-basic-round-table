# Execution ledger — plan: docs/superpowers/plans/2026-09-27-circular-seating.md

- Approved scope: milestone 1 feasibility, then detailed production plan review.
- Work branch: `round-table-feasibility`; preserves the already modified design documents.
- Compiler located: `/Applications/PureBasic.app/Contents/Resources/compilers/pbcompiler`, version 6.41, C backend, macOS arm64, Free edition.
- Ruling: work on a dedicated branch in the current workspace rather than moving the user's uncommitted planning documents to a worktree; no shared codebase exists yet. Cost: experimental changes are visible in this workspace.
- Ruling: keep the milestone ledger here rather than use git-oriented task scripts designed for a completed production plan. This approved plan is explicitly a research milestone. Cost: manually maintained progress tracking.
- Pre-flight: generator output is a list of circular permutations of labels 1–n; independent verifier consumes only n and those rows. Construction metadata must not influence correctness checking.
- Research: prime-power constructions and cyclic starting rows are candidate methods, not yet verified implementations.

## Milestone 1 results

- Compiler invocation verified with `PUREBASIC_HOME` set to the app's Resources directory. Built and ran both a small console program and the full generation probe.
- Independent Python verifier: tests initially failed on valid source examples, then passed after implementation. Covers circular boundary pairs, unordered neighbours, missing/extra sittings, invalid people and repeated sittings.
- Python generator: all 19 supported-count cases failed against an empty implementation, then passed with projective finite-field generation and attributed cyclic starters.
- PureBasic generator: 26 generation/input cases failed against an empty executable, then passed after implementation. A comma-separated array declaration caused a compile error; local PureBasic documentation confirmed separate Dim declarations were required.
- Final mathematical coverage: every n from 3 through 21 verified in both implementations. No constructor metadata enters the verifier.
- Ruling: select deterministic algebraic construction for 12 counts and documented compact starters for 7 counts. This follows the approved allowance for reusable construction seeds, after generic cyclic search timed out. Cost: those seven cases depend on published starting rows; finding new seeds independently remains future work.
- PureBasic timings: five runs per count, each independently verified; medians 4.472-7.455 ms including process launch and text output. Output and measurements saved under `experiments/round-table/results/`.
- Production plan now specifies the exact construction families, files, interfaces, incremental generation, independent verification and GUI behavior. Waiting for its planned review before application implementation.
- Research state in the earlier setup notes is historical; the selected methods above are now experimentally verified.
- Independent final review: no blocking findings. Reviewer ran all 11 tests, independently enumerated expected neighbour pairs across five compiled-probe runs per count, compared Python/PureBasic output, and checked the saved 21-person schedule. Source-page transcription was checked by the implementer, not repeated by the reviewer.
- No deferred code-review findings. GUI, cancellation and repeated jobs in one process remain explicitly assigned to production tasks rather than claimed as implemented.

## Production implementation

- Production plan approved by the user. Continued on the existing feature branch without moving their work.
- Task 1 complete: production verifier and input parsing. Initial stubs failed 9 of 22 checks; implementations passed all 22. Whitespace and overflow are handled before conversion.
- Task 2 complete: per-job PureBasic construction state, static attributed starter data, independent verification before publication, batches capped at 16 candidates, and cancellation. Empty implementation failed 47 checks; all supported counts and repeated-job checks now pass. A separate compiled exporter was checked by the experimental Python verifier for all 19 counts.
- Task 3 complete: native window and event loop, job identity checks, native Generate/Cancel buttons, Enter/Escape actions, input invalidation and close handling. Native GUI driver checks events without accessibility permissions.
- Task 4 complete: aligned rows, genuine group separators, compact view and cycle descriptions, selection-to-diagram mapping, scrolling and minimum-size layout. Presentation tests failed against stubs before implementation.
- Visual QA found white controls on the paper background under system dark mode. An appearance check reproduced this and passed after assigning the window a native Aqua appearance.
- GUI driver waits for current-job publication, rather than an old job's Verified state; native button delivery is asynchronous. Image checks allow a small ColorSync tolerance and verify the table in actual captured windows.
- Current verification: 10,716 solver assertions and 50 GUI checks pass. Screenshots cover 3, 5, 13 and 21 people, compact view, minimum window size, and horizontal scrolling.
- Ruling: split the planned `main.pb` presentation work into `app.pbi`, `presentation.pbi` and `drawing.pbi`, retaining a small entry point. This lets the GUI test executable use the actual controls and handlers without product automation hooks. Cost: three additional focused source files.
- Ruling: apply the paper design's light appearance to the entire window, so native controls remain legible when macOS uses dark mode. Cost: this initial application does not follow system dark appearance.
- Build outputs and visual QA artifacts stay ignored under `build/` and `artifacts/`. No added dependencies or external publication.
- Final review found arrow navigation could stop at group separators. A new GUI check reproduced the failure; selection now skips separators in either direction. The reviewer confirmed the fix with no further findings.
- Final verification after the fix: 10,716 solver assertions and 51 GUI checks passed; production app rebuilt successfully and `git diff --check` passed. All planned work is complete.
