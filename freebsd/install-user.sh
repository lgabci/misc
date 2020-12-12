#!/bin/sh

set -eu

DIR=$(dirname "$0")/files

# install files
find "$DIR/" -type f | while read src; do
  trg=/${src#$DIR/}

  case "$trg" in
    /home/*.append)
      trg=$HOME/${trg#/home/}
      trg=${trg%.append}
      lines=$(wc -l <"$src")
      if [ -e "$trg" ]; then
        if ! tail -n "$lines" "$trg" | diff "$src" - >/dev/null; then
          echo "APPEND $src -> $trg"
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
        echo "NEW    $src -> $trg"
        cp "$src" "$trg"
      fi
      ;;
  esac
done

# set up SSH keys
if [ ! -e "$HOME/.ssh" ]; then
  ssh-keygen </dev/zero
fi

# set localization settings
conf="$HOME/.login_conf.db"
confdb="$HOME/.login_conf.db"
if [ ! -e "$conf" ] ||
  [ "$confdb" -ot "$conf" ] ; then
  echo cap_mkdb $conf ...
  cap_mkdb $conf
fi

# set Git URL-s
giturl="git@github.com:lgabci/misc.git"
gitpath=$(dirname "$0")/..
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
      echo "Git set $type URL to $giturl ..."
      git -C "$gitpath" remote set-url ${t:-} "$name" "$giturl"
    fi
  done
