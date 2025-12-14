#!/bin/sh

set -eu

basename=$(basename $0)
build="build.sh"

if tdir=$(git rev-parse --show-toplevel 2>/dev/null); then
  fullbuild="$tdir/$build"
  if [ -x "$fullbuild" ]; then
    "$fullbuild" $@
  else
    echo "$basename: No executable $build found in git top level directory." >&2
    exit 1
  fi
else
  echo "$basename: Not in a git working tree." >&2
  exit 1
fi
