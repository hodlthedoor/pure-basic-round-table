"""Integration checks against the compiled experimental PureBasic generator."""
import subprocess
import unittest
from pathlib import Path

from verify import verify

PROBE = Path(__file__).parent / 'build' / 'generate_probe'


class PureBasicTests(unittest.TestCase):
    def test_all_supported_counts(self):
        self.assertTrue(PROBE.is_file(), 'Build generate_probe.pb first')
        for n in range(3, 22):
            with self.subTest(n=n):
                run = subprocess.run([str(PROBE), str(n)], capture_output=True,
                                     text=True, timeout=5)
                self.assertEqual(run.returncode, 0, run.stderr + run.stdout)
                rows = [[int(v) for v in line.split()] for line in run.stdout.splitlines()]
                self.assertTrue(verify(n, rows), f'Invalid PureBasic schedule for {n}')

    def test_invalid_counts_fail_without_rows(self):
        self.assertTrue(PROBE.is_file(), 'Build generate_probe.pb first')
        for n in ('2', '22', 'abc', '3garbage', '3.5', '', '9' * 100):
            with self.subTest(n=n):
                run = subprocess.run([str(PROBE), n], capture_output=True,
                                     text=True, timeout=5)
                self.assertNotEqual(run.returncode, 0)
                self.assertEqual(run.stdout, '')
