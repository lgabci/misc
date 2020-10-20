#!/bin/sh

set -eu

PNAME=$(basename $0)

case $# in
  2)
    fname="$1"
    exists=""
    rights=""
    content="$2"
    ;;
  3)
    fname="$1"
    exists="$2"
    rights=""
    content="$3"
    ;;
  4)
    fname="$1"
    exists="$2"
    rights="$3"
    content="$4"
    ;;
  *)
    echo "Usage:" >&2
    echo "  $PNAME filename [exists [rights]] content" >&2
    echo "  filename: the file to be written" >&2
    echo "  exists:   a = append existing file, n = new file, empty or - = doesn't matter" >&2
    echo "  rights:   for chmod (empty or - = no chmod run)" >&2
    echo "  content:  content into the file" >&2
    exit 1
    ;;
esac

case "$rights" in
  ""|-|[0-7]|[0-7][0-7]|[0-7][0-7][0-7]|[0-7][0-7][0-7][0-7]|[-+][rwx]|[ugoa][-+][rwx])
    ;;
  *)
    echo "$PNAME: bad rigths value: \"$rights\"" >&2
    exit 1
    ;;
esac

case "$exists" in
  "a")
    if [ ! -e "$fname" ]; then
      echo "$PNAME: file not found: \"$fname\"" >&2
      exit 1
    fi
    echo -n "$content" >>"$fname"
    ;;
  "n")
    if [ -e "$fname" ]; then
      echo "$PNAME: file exists: \"$fname\"" >&2
      exit 1
    fi
    echo -n "$content" >"$fname"
    ;;
  ""|-)
    ;;
  *)
    echo "$PNAME: bad exists value: \"$exists\"" >&2
    exit 1
esac

if [ -n "$rights" ] && [ "$rights" != - ]; then
  chmod "$rights" "$fname"
fi

