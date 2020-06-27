#!/bin/sh
# get/set volume level

case $# in
  0)
    doas /usr/bin/mixerctl outputs.master
    ;;
  1)
    if echo "$1" | grep -E ^[[:digit:]]+$ >/dev/null; then
      doas /usr/bin/mixerctl outputs.master="$1,$1"
    else
      echo "$1 is not a number" >&2
      exit 1
    fi
    ;;
  *)
    echo "$(basename $0) get/set master volume level" >&2
    echo "Usage: $(basename $0) [level]" >&2
    echo "  level: set volume level if is is specified, else show volume level" >&2
    exit 1
    ;;
esac
