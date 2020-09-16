#!/bin/sh

case $# in
  2)
    fname="$1"
    rights=""
    content="$2"
    ;;
  3)
    fname="$1"
    rights="$2"
    content="$3"
    ;;
  *)
    echo "Usage:" >&2
    echo "  $(basename $0) filename [rights] content" >&2
    echo "  filename: the file to be written" >&2
    echo "  rights:   for chmod" >&2
    echo "  content:  content into the file" >&2
    exit 1
    ;;
esac

