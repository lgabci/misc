#!/bin/sh

set -eu

DIR=files

find "$DIR/" -type f | while read src; do
  trg=/${src#$DIR/}

  case "$trg" in
    /home/*.append)
      trg=${trg%.append}
      trg=$HOME/${trg#/home/}
      lines=$(wc -l <"$src")
      if [ -e "$trg" ]; then
        if ! tail -n "$lines" "$trg" | diff "$src" - >/dev/null; then
          echo "APPEND $src -> $trg"  ######
          cat "$src" >>"$trg"
        fi
      else
        echo "File not found: $trg" >&2
	exit 1
      fi
      ;;
    /home/*)
      trg=$HOME/${trg#/home/}
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

giturl="git@github.com:lgabci/misc.git"
git remote -v show | \
  while read name url type; do
    if [ "$name" = origin ] && [ "$url" != "$giturl" ]; then
      type=${type#(}
      type=${type%)}
      unset t
      case "$type" in
        push)
          t=--push
          ;;
      esac
      git remote set-url ${t:-} "$name" "$giturl"
    fi
  done
