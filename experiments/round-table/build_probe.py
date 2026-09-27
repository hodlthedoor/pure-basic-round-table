"""Build the isolated PureBasic feasibility probe; installs nothing."""
import os
import subprocess
from pathlib import Path

from starters import RAW, construction

ROOT = Path(__file__).resolve().parent
PB_HOME = Path('/Applications/PureBasic.app/Contents/Resources')

lines = ['; Generated from attributed numerical construction data in starters.py.',
         'DataSection', '  StarterData:']
for n in sorted(RAW):
    rows, cycles = construction(n)
    successor = list(range(n + 1))
    for cycle in cycles:
        for i, person in enumerate(cycle):
            successor[person] = cycle[(i + 1) % len(cycle)]
    lines.append('  Data.i ' + ', '.join(map(str, (n, len(rows), len(cycles[0])))))
    lines.append('  Data.i ' + ', '.join(map(str, successor[1:])))
    for row in rows:
        lines.append('  Data.i ' + ', '.join(map(str, row)))
lines += ['  Data.i 0', 'EndDataSection']
(ROOT / 'build').mkdir(exist_ok=True)
(ROOT / 'build' / 'starter_data.pbi').write_text('\n'.join(lines) + '\n')
env = dict(os.environ, PUREBASIC_HOME=str(PB_HOME))
subprocess.run([str(PB_HOME / 'compilers' / 'pbcompiler'),
                str(ROOT / 'generate_probe.pb'), '--console',
                '--output', str(ROOT / 'build' / 'generate_probe')],
               env=env, check=True)
