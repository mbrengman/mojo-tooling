#!/bin/bash
# env_builder.sh — set up Mojo runtime + CPython paths, then exec the binary
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
ENV="${PIXI_ENV_DIR:-$PROJECT_ROOT/.pixi/envs/default}"
PROJECT_NAME="${1:?usage: $0 <binary> [args...]}"
shift

# Detect the Python version from the environment's libpython
PYLIB="$(ls "$ENV"/lib/libpython3.*.so 2>/dev/null | head -n1)"
[ -n "$PYLIB" ] || { echo "No libpython found in $ENV/lib" >&2; exit 1; }
PYVER="$(basename "$PYLIB" .so)"; PYVER="${PYVER#lib}"

# CPython stdlib + site-packages (argparse, datetime, etc.)
export PYTHONPATH="$ENV/lib/$PYVER:$ENV/lib/$PYVER/lib-dynload:$ENV/lib/$PYVER/site-packages${PYTHONPATH:+:$PYTHONPATH}"

# Mojo runtime .so + libpython (RUNPATH covers most, this is belt-and-suspenders)
export LD_LIBRARY_PATH="$ENV/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Fallback if the binary can't find libpython on its own
export MOJO_PYTHON_LIBRARY="$PYLIB"

exec "$PROJECT_ROOT/$PROJECT_NAME" "$@"
