#!/bin/sh
set -eu

USERNAME=/home/gabci
USERHOME=/home/gabci
DATFILE=install.dat

rcctl enable apmd
rcctl set apmd flags -A
rcctl start apmd

pkg_add icewm vim git emacs-nox11 meson avr kicad firefox-esr


while read file path c owner rights; do
  if [ -n "$file" ]; then
    case "$c" in
      c)
        cp "$file" "$path"
        ;;
      t)
        cat "$file" >>"$path"
        ;;
      *)
        echo "Unknown command: $c"
	exit 1
        ;;
    esac
  fi
  if [ -n "$owner" ] && [ "$owner" != - ]; then
    chown "$owner" "$path"
  fi
  if [ -n "$rights" ]; then
    chmod "$rigths" "$path"
  fi
done <"$DATFILE"

for u in $USERS; do
  doas -u $u ssh-keygen
done
