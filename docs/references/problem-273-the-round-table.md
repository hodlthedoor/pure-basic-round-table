# Problem 273 — The Round Table

Henry Ernest Dudeney, *Amusements in Mathematics* (1917).

Source: [Project Gutenberg ebook 16713](https://www.gutenberg.org/ebooks/16713).
Downloaded 2026-09-27 from https://www.gutenberg.org/ebooks/16713.txt.utf-8.
The complete downloaded text, including its license, is saved alongside this file as `amusements-in-mathematics.txt`.
The original book is public domain. The excerpts below preserve the downloaded plain text, including its historical claims and notation.

## Relationship to our proposed application

This puzzle asks for a schedule of (n - 1)(n - 2) / 2 circular seatings, such that each person sits between every unordered pair of other people exactly once. It is a different task from counting all circular permutations using (n - 1)!.

For 5 people, the schedule has 6 seatings; the circular-permutation count is 24. A solver for this puzzle must construct and verify the schedule. The existing application plan has not been changed.

The published solution gives cases through 12 people, with cycling instructions to expand compact schedules. Its discussion of the 13-person case describes the author's historical position, not a verified statement about current mathematical knowledge.

## Original problem

```text
273.--THE ROUND TABLE.

Seat the same n persons at a round table on

    (n - 1)(n - 2)
    --------------
           2

occasions so that no person shall ever have the same two neighbours
twice. This is, of course, equivalent to saying that every person must
sit once, and once only, between every possible pair.
```

## Published solution

```text
273.--THE ROUND TABLE.

The history of this problem will be found in _The Canterbury Puzzles_
(No. 90). Since the publication of that book in 1907, so far as I know,
nobody has succeeded in solving the case for that unlucky number of
persons, 13, seated at a table on 66 occasions. A solution is possible
for any number of persons, and I have recorded schedules for every
number up to 25 persons inclusive and for 33. But as I know a good many
mathematicians are still considering the case of 13, I will not at this
stage rob them of the pleasure of solving it by showing the answer. But
I will now display the solutions for all the cases up to 12 persons
inclusive. Some of these solutions are now published for the first time,
and they may afford useful clues to investigators.

The solution for the case of 3 persons seated on 1 occasion needs no
remark.

A solution for the case of 4 persons on 3 occasions is as follows:--

    1 2 3 4
    1 3 4 2
    1 4 2 3

Each line represents the order for a sitting, and the person represented
by the last number in a line must, of course, be regarded as sitting
next to the first person in the same line, when placed at the round
table.

The case of 5 persons on 6 occasions may be solved as follows:--

    1 2 3 4 5
    1 2 4 5 3
    1 2 5 3 4
    ---------
    1 3 2 5 4
    1 4 2 3 5
    1 5 2 4 3

The case for 6 persons on 10 occasions is solved thus:--

    1 2 3 6 4 5
    1 3 4 2 5 6
    1 4 5 3 6 2
    1 5 6 4 2 3
    1 6 2 5 3 4
    -----------
    1 2 4 5 6 3
    1 3 5 6 2 4
    1 4 6 2 3 5
    1 5 2 3 4 6
    1 6 3 4 5 2

It will now no longer be necessary to give the solutions in full, for
reasons that I will explain. It will be seen in the examples above that
the 1 (and, in the case of 5 persons, also the 2) is repeated down the
column. Such a number I call a "repeater." The other numbers descend in
cyclical order. Thus, for 6 persons we get the cycle, 2, 3, 4, 5, 6, 2,
and so on, in every column. So it is only necessary to give the two
lines 1 2 3 6 4 5 and 1 2 4 5 6 3, and denote the cycle and repeaters,
to enable any one to write out the full solution straight away. The
reader may wonder why I do not start the last solution with the numbers
in their natural order, 1 2 3 4 5 6. If I did so the numbers in the
descending cycle would not be in their natural order, and it is more
convenient to have a regular cycle than to consider the order in the
first line.

The difficult case of 7 persons on 15 occasions is solved as follows,
and was given by me in _The Canterbury Puzzles_:--

    1 2 3 4 5 7 6
    1 6 2 7 5 3 4
    1 3 5 2 6 7 4
    1 5 7 4 3 6 2
    1 5 2 7 3 4 6

In this case the 1 is a repeater, and there are _two_ separate cycles,
2, 3, 4, 2, and 5, 6, 7, 5. We thus get five groups of three lines each,
for a fourth line in any group will merely repeat the first line.

A solution for 8 persons on 21 occasions is as follows:--

    1 8 6 3 4 5 2 7
    1 8 4 5 7 2 3 6
    1 8 2 7 3 6 4 5

The 1 is here a repeater, and the cycle 2, 3, 4, 5, 6, 7, 8. Every one
of the 3 groups will give 7 lines.

Here is my solution for 9 persons on 28 occasions:--

    2 1 9 7 4 5 6 3 8
    2 9 5 1 6 8 3 4 7
    2 9 3 1 8 4 7 5 6
    2 9 1 5 6 4 7 8 3

There are here two repeaters, 1 and 2, and the cycle is 3, 4, 5, 6, 7,
8, 9. We thus get 4 groups of 7 lines each.

The case of 10 persons on 36 occasions is solved as follows:--

    1 10 8 3 6 5 4 7 2 9
    1 10 6 5 2 9 7 4 3 8
    1 10 2 9 3 8 6 5 7 4
    1 10 7 4 8 3 2 9 5 6

The repeater is 1, and the cycle, 2, 3, 4, 5, 6, 7, 8, 9, 10. We here
have 4 groups of 9 lines each.

My solution for 11 persons on 45 occasions is as follows:--

    2 11  9  4 7 6  5 1 8 3 10
    2  1 11  7 6 3 10 8 5 4  9
    2 11 10  3 9 4  8 5 1 7  6
    2 11  5  8 1 3 10 6 7 9  4
    2 11  1 10 3 4  9 6 7 5  8

There are two repeaters, 1 and 2, and the cycle is, 3, 4, 5,... 11. We
thus get 5 groups of 9 lines each.

The case of 12 persons on 55 occasions is solved thus:--

    1 2 3 12  4 11  5 10  6  9  7  8
    1 2 4 11  6  9  8  7 10  5 12  3
    1 2 5 10  8  7 11  4  3 12  6  9
    1 2 6  9 10  5  3 12  7  8 11  4
    1 2 7  8 12  3  6  9 11  4  5 10

Here 1 is a repeater, and the cycle is 2, 3, 4, 5,... 12. We thus get 5
groups of 11 lines each.
```
