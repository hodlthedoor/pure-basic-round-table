# Circular seating calculator design

Status: draft for review; implementation has not started.

## Agreed scope

Create a PureBasic desktop calculator for 1–21 distinct people around a round table. Show the exact number of arrangements, the calculation, and one illustrative seating diagram. Rotations count as the same arrangement; reflected orders count as different when not equivalent by rotation. No seating constraints or enumeration of all arrangements.

## Proposed interaction

Use one fixed-size window, initially 760 × 760 logical units, with a labelled people-count input, Calculate button, result, worked explanation, and table drawing. Start with 5 people and its calculated result. Support Calculate by mouse and Enter by keyboard.

Accept whole-number text from 1 through 21, allowing surrounding spaces and leading zeros. Reject empty input, signs, decimals, letters, and out-of-range numbers with “Enter a whole number from 1 to 21.” Validate before numeric conversion, including very long pasted input. Editing the input clears the previous result and diagram so they cannot be mistaken for the new input's answer.

For 5 people, show “24 arrangements” and “(5 - 1)! = 4 × 3 × 2 × 1 = 24”. Explain: “Fix person 1's position, then arrange the remaining people.” For 1 person, show “(1 - 1)! = 0! = 1” and explain that there is one arrangement. Wrap the working so the full expansion for 21 people remains readable. Display exact decimal integers, never scientific notation.

Draw a round table with people numbered 1 through n, evenly spaced clockwise. Place person 1 at the top, highlight their marker, and label them as the fixed person. Caption: “One example arrangement”. All 21 markers must fit without overlapping or clipped labels. Number labels identify people, not numbered seats.

## Implementation constraints

- PureBasic with built-in GUI and drawing facilities; no added dependencies.
- Accept 1–21 people only; use signed 64-bit `.q` arithmetic for counts.
- Keep calculation independent of GUI and drawing.
- Target the current macOS workspace first; cross-platform verification is outside this initial scope.

Compute (n - 1)! by integer multiplication. The maximum result is 20! = 2432902008176640000. Future support above 21 will require a larger integer representation and reconsideration of diagram density; no arbitrary-precision implementation is included now.

## Acceptance

Correct counts for 1, 2, 3, 5, and 21 people; clear rejection of invalid input; readable drawing at both ends of the range; calculation and picture consistently reflect the submitted input. The application opens, responds to keyboard and mouse, and closes normally.

## Environment and references

The workspace was empty when planning began. `pbcompiler` was not found on PATH; locate an installed PureBasic compiler or IDE before implementation verification. No compiler version has been confirmed.

Official references: [PureBasic numeric types](https://www.purebasic.com/documentation/reference/variables.html) and [CanvasGadget](https://www.purebasic.com/documentation/gadget/canvasgadget.html).
