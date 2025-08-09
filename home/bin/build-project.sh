#!/bin/sh

set -eu

basename=$(basename $0)

if tdir=$(git rev-parse --show-toplevel 2>/dev/null); then
  comp="$tdir/compile.sh"
  if [ -x "$comp" ]; then
    "$comp" $@
  else
    echo "$basename: No executable compile.sh found in git top level directory." >&2
    exit 1
  fi
else
  echo "$basename: Not in a git working tree." >&2
  exit 1
fi
