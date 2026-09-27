# Dudeney round-table solver design

Status: approved and implemented. Verification evidence is recorded in the execution ledger.

## Goal and rules

Build a PureBasic desktop application that generates one valid solution to Dudeney's problem 273 for each count from 3 to 21. Present solutions as aligned numerical rows in the author's style, with a circular diagram of the selected row.

A schedule has (n - 1)(n - 2) / 2 sittings. Every row contains each person exactly once, and the last and first entries are neighbours. Across the schedule, each person sits between every unordered pair of other people exactly once. Reversing the pair does not make it new.

Examples: 3 people require 1 sitting; 5 require 6; 13 require 66; 21 require 190. Labels identify people and run from 1 to n. One or two people cannot have two distinct neighbours and are outside this problem's range.

## Verified generation methods

Use the [feasibility report](../../references/solver-feasibility.md) as the algorithm and provenance reference. For the twelve counts it lists, construct a projective cycle over a finite field and expand affine images. For the remaining seven counts, expand the 49 attributed starting rows by their label cycles. Complete schedules are generated at runtime and verified before display.

This is a deliberate implementation choice: known compact construction seeds are part of the application. Finding new seeds through an unconstrained search is outside the initial scope. No runtime lookup table of complete schedules is needed.

## Window and output

Use one resizable native window, initially 1100 by 760 logical units, minimum 900 by 680. The top row has a labelled count input, Generate, Cancel, and a status message. Below it, use the left side for a scrollable monospaced list of seatings and the right side for a circular diagram and an explanation of the construction. Allocate at least 630 logical units to the row display at the initial size; allow horizontal scrolling at smaller sizes.

Start with 5 people and automatically generate the first solution. The Generate button and Enter use the same action. Accept decimal digit text with surrounding spaces and leading zeros; reject blank input, signs, decimals, letters, and out-of-range or overflowing values with “Enter a whole number from 3 to 21.” Editing input clears the previous result and cancels pending work.

In the main list, show all sittings as right-aligned two-character numbers. A heading shows the people and sitting counts. Group separators are non-seating items and cannot become diagram selections. Use them only for groups produced by the chosen construction. Explain that each row wraps around the table.

For cyclic-starting-row cases, offer a compact view showing the starting rows, fixed labels, and cycle instructions. Selecting a compact row shows that starting seating. Switching back selects its first expanded seating. In algebraic cases show the complete schedule and a plain explanation of the construction, without pretending that ordinary integer increments describe finite-field arithmetic.

The diagram follows the selected row clockwise, with the first listed person at the top. Highlight that person and label the marker as the start of the displayed row. It must not imply that this person is always a fixed repeater. All 21 markers must be legible and fit without overlap.

## Execution and correctness

Generate in small batches driven by the event loop so Cancel and window events remain responsive. Editing input, starting a new job, or closing the window invalidates the previous job. Only the current job can publish output. Completion includes independent verification of all rows and neighbour pairs. An error or cancellation must not leave partial rows labelled as a solution.

Use states Idle, Running, Verified, Cancelled, and Failed. The selected methods use bounded loops and no open-ended search, so no search-timeout setting is needed in this version. Display failures as construction or verification errors, not as proof of impossibility.

## Constraints and acceptance

- Delivered application in PureBasic using built-in GUI and drawing facilities.
- Support every integer count from 3 to 21.
- Ship attributed construction data; runtime requires no Python or network access.
- Keep generation, verification, and presentation separate.
- Verify on the current macOS arm64 installation with PureBasic 6.41 Free.
- Discuss any new dependency before adding it.

Acceptance requires all 19 counts to pass the independent verifier, readable expanded and applicable compact views, correct row selection and drawing, and cancellation without stale results. Test repeated generation in one process, including 21, 3, 17, and 5, to catch retained state. GUI checks include the smallest window size and the 190-row output.

The 21-person limit now bounds validated constructions rather than factorial arithmetic. Extending it requires more verified construction coverage.
