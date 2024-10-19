#!/bin/sh

set -eu

if tdir=$(git rev-parse --show-toplevel); then
  comp="$tdir/compile.sh"
  if [ -x "$comp" ]; then
    "$tdir/compile.sh" $@
  else
    echo "No executable compile.sh found in git top level directory." >&2
    exit 1
  fi
else
  echo "Not in a git working tree." >&2
  exit 1
fi
