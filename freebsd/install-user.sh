#!/bin/sh

set -eu

DIR=files

find "$DIR/" -type f | while read src; do
  trg=/${src#$DIR/}

  case "$trg" in
    /home/*)
      trg="$HOME/${trg#/home/}"
      dir=$(dirname "$trg")
      if [ ! -e "$trg" ]; then
        if [ ! -e "$dir" ]; then
          mkdir -p "$dir"
        fi
        echo "NEW    $src -> $trg ${mod:-}"  ######
        cp "$src" "$trg"
      fi
      ;;
  esac
done

if [ ! -e "$HOME/.login_conf.db" ]; then
  echo cap_mkdb $HOME/.login_conf ... #####
  cap_mkdb $HOME/.login_conf
fi

## git remote set-url origin git@github.com:lgabci/misc.git
