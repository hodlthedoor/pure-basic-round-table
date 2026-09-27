# Round-table feasibility probe

This directory contains experimental code for the approved feasibility milestone. The delivered application will be implemented separately after production-plan review.

Build and verify from the project root:

```sh
python3 experiments/round-table/build_probe.py
python3 -m unittest discover -s experiments/round-table -p 'test_*.py'
python3 experiments/round-table/benchmark.py
```

The build script uses PureBasic 6.41 at `/Applications/PureBasic.app/Contents/Resources` and sets `PUREBASIC_HOME` for the compiler. Python requires no third-party packages.

Generate a schedule directly:

```sh
experiments/round-table/build/generate_probe 21
```

The output contains one circular seating per line with labels 1 through n. Invalid input returns exit code 1; construction failure returns 2. Independent verification happens in the Python tests and benchmark, not inside this experimental executable.

- `generate_probe.pb`: experimental PureBasic generator.
- `generate.py`: independent implementation of the same mathematical constructions in Python.
- `verify.py`: verifier which uses only the problem's requirements, not generator metadata.
- `starters.py`: attributed compact starting rows and cycle definitions for seven counts.
- `results/`: measured timings and a verified sample output.
- `cyclic_search.cpp`: unsuccessful exploratory search, excluded from the selected design.

See the [feasibility report](../../docs/references/solver-feasibility.md) for sources and limitations.
