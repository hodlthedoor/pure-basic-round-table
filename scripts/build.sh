#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
export PUREBASIC_HOME="${PUREBASIC_HOME:-/Applications/PureBasic.app/Contents/Resources}"
compiler="$PUREBASIC_HOME/compilers/pbcompiler"
if [[ ! -x "$compiler" ]]; then
  printf 'PureBasic compiler missing: %s\nSet PUREBASIC_HOME to its Resources directory.\n' "$compiler" >&2
  exit 1
fi
mkdir -p "$project_root/build"
case "${1:-test}" in
  test)
    "$compiler" "$project_root/tests/solver_tests.pb" --console --output "$project_root/build/solver_tests"
    "$project_root/build/solver_tests"
    ;;
  app)
    "$compiler" "$project_root/src/main.pb" --output "$project_root/build/The Round Table.app"
    ;;
  gui-test)
    mkdir -p "$project_root/artifacts"
    "$compiler" "$project_root/tests/gui_tests.pb" --output "$project_root/build/Round Table QA.app"
    "$project_root/build/Round Table QA.app/Contents/MacOS/Round Table QA" "$project_root/artifacts"
    cat "$project_root/artifacts/gui-checks.log"
    ;;
  *) printf 'Usage: %s {test|app|gui-test}\n' "$0" >&2; exit 1 ;;
esac
