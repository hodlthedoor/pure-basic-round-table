"""Independent acceptance checks for the experimental schedule verifier."""
import unittest

from verify import verify
from generate import generate


FIVE = [
    [1, 2, 3, 4, 5], [1, 2, 4, 5, 3], [1, 2, 5, 3, 4],
    [1, 3, 2, 5, 4], [1, 4, 2, 3, 5], [1, 5, 2, 4, 3],
]


class VerificationTests(unittest.TestCase):
    def test_accepts_author_examples(self):
        self.assertTrue(verify(3, [[1, 2, 3]]))
        self.assertTrue(verify(4, [[1, 2, 3, 4], [1, 3, 4, 2], [1, 4, 2, 3]]))
        self.assertTrue(verify(5, FIVE))

    def test_accepts_rotated_and_reversed_rows(self):
        self.assertTrue(verify(5, [list(reversed(row[2:] + row[:2])) for row in FIVE]))

    def test_rejects_missing_or_extra_sitting(self):
        self.assertFalse(verify(5, FIVE[:-1]))
        self.assertFalse(verify(5, FIVE + [FIVE[0]]))

    def test_rejects_duplicate_sitting_even_when_reversed(self):
        self.assertFalse(verify(5, FIVE[:-1] + [list(reversed(FIVE[0]))]))

    def test_rejects_invalid_person_and_duplicate_person(self):
        for bad_row in ([1, 2, 3, 4, 6], [1, 2, 3, 4, 4], [1, 2, 3, 4]):
            with self.subTest(row=bad_row):
                self.assertFalse(verify(5, [bad_row] + FIVE[1:]))

    def test_rejects_boundary_neighbour_collision(self):
        # Each row has unique interior centred triples; wraparound causes clashes.
        self.assertFalse(verify(4, [[1, 2, 3, 4], [1, 2, 4, 3], [2, 1, 3, 4]]))

    def test_rejects_counts_outside_scope(self):
        self.assertFalse(verify(2, []))
        self.assertFalse(verify(22, []))


class GenerationTests(unittest.TestCase):
    def test_generates_complete_schedule_for_every_supported_count(self):
        sitting_counts = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66,
                          78, 91, 105, 120, 136, 153, 171, 190]
        for n, count in zip(range(3, 22), sitting_counts):
            with self.subTest(n=n):
                rows = generate(n)
                self.assertEqual(len(rows), count)
                self.assertTrue(verify(n, rows))

    def test_rejects_counts_without_two_distinct_neighbours_or_above_limit(self):
        for n in (-1, 0, 1, 2, 22):
            with self.subTest(n=n), self.assertRaises(ValueError):
                generate(n)


if __name__ == '__main__':
    unittest.main()
