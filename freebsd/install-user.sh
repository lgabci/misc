#!/bin/sh

set -eu

if ! [ -e ~/.xinitrc ]; then
  echo "xset -b
setxkbmap hu
exec icewm-session " >~/.xinitrc
fi

