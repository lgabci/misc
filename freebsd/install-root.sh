#!/bin/sh

set -eu

PNAME=$(basename $0)
DIR=files

if false; then ################################################################
# test root
if [ $(id -u) != 0 ]; then
  echo "$PNAME: must be run by root" >&2
  exit 1
fi

# update FreeBSD system
freebsd-update fetch
freebsd-update install || q=$?
if [ ${q:-0} != 2 ]; then
  poweroff
fi
unset q

# set rc.conf
sysrc local_unbound_enable=YES
sysrc sshd_enable=YES
sysrc ntpdate_enable=YES
sysrc powerd_enable=YES
sysrc dbus_enable=YES
sysrc hald_enable=YES
sysrc hdnostop_enable=YES

# install packages
pkg update
pkg upgrade -y
pkg install -y xorg icewm xdm sudo vim bash bash-completion emacs
fi ############################################################################

find "$DIR/" -type f | while read src; do
  unset mod
  trg=/${src#$DIR/}

  case "$src" in
    *.[[:digit:]][[:digit:]][[:digit:]])
      mod=${src##*.}
      trg=${trg%.*}
      ;;
  esac

  case "$trg" in
    /home/*)
      ;;
    *.append)
      trg=${trg%.append}
      lines=$(wc -l <"$src")
      if ! tail -n "$lines" "$trg" | diff "$src" - >/dev/null; then
        echo "APPEND $src -> $trg ${mod:-}"  ######
        cat "$src" >>"$trg"
      fi
      ;;
    *)
      if [ ! -e "$trg" ]; then
        echo "NEW    $src -> $trg ${mod:-}"  ######
        cp "$src" "$trg"
        if [ -n "$mod" ]; then
          chmod "$mod" "$trg"
        fi
      fi
      ;;
  esac
done

f="/etc/wpa_supplicant.conf"
if grep 'psk="\*\*\*\*\*"' "$f" >/dev/null; then
  ssid=$(awk -F = '/ssid=/{gsub("^\"|\"$","",$2);print $2;exit}' "$f")
  if [ -z "$ssid" ]; then
    echo "Can not found SSID in $f." >&2
    exit 1
  fi
  while true; do
    while true; do
      read -p "WiFi password for $ssid: " passphr
      if [ -n "$passphr" ]; then
        break
      fi
    done
    psk=$(wpa_passphrase "$ssid" "$passphr" |
      awk -v ORS='\\n' '/psk/{sub("^\t*", "  ");print}')
    if [ -z "$psk" ]; then
      echo "Can not generate PSK." >&2
    else
      awk -v psk="$psk" '/psk/{print psk;next}{print}' "$f" >"$f.2"
      cat "$f.2" >"$f"
      rm "$f.2"
      unset ssid passphr
      break
    fi
  done
fi

f="/etc/ttys"
if grep '^tty.*xdm.*\boff\b' "$f" >/dev/null; then
  sed -e '/^tty.*xdm/s/\<off\>/onifexists/' "$f" >"$f.2"
  cat "$f.2" >"$f"
  rm "$f.2"
fi
