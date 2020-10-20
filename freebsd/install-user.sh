#!/bin/sh

set -eu

if ! [ -e ~/.xinitrc ]; then
  echo "xset -b
setxkbmap hu
exec icewm-session " >~/.xinitrc
fi




git config --global user.email "gl12qw@gmail.com"
git config --global user.name "lgabci"
git config --global pull.rebase false

git remote set-url origin git@github.com:lgabci/misc.git
