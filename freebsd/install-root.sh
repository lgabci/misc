#!/bin/sh

set -eu

PNAME=$(basename $0)
DIR=$(dirname "$0")/files

# test root
if [ $(id -u) != 0 ]; then
  echo "$PNAME: must be run by root" >&2
  exit 1
fi

if false; then ########################
# update FreeBSD system
freebsd-update fetch
freebsd-update install || q=$?
if [ ${q:-0} != 2 ]; then
  poweroff
fi
unset q

# install packages
pkg update
pkg upgrade -y
pkg install -y nss_mdns xorg icewm xdm sudo vim bash bash-completion emacs firefox

# set rc.conf
sysrc avahi_daemon_enable=YES
sysrc avahi_dnsconfd_enable=YES
sysrc local_unbound_enable=YES
sysrc sshd_enable=YES
sysrc ntpdate_enable=YES
sysrc powerd_enable=YES
sysrc dbus_enable=YES
sysrc hald_enable=YES
sysrc hdnostop_enable=YES
fi ###################################

# install files
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
    *.sed)
      trg=${trg%.sed}
      tmp=$(mktemp)
      sed -f "$src" "$trg" >"$tmp"
      if ! diff "$tmp" "$trg" >/dev/null; then
        echo "SED    $trg"
        cat "$tmp" >"$trg"
      fi
      rm "$tmp"
      ;;
    *.append)
      trg=${trg%.append}
      lines=$(wc -l <"$src")
      if ! tail -n "$lines" "$trg" | diff "$src" - >/dev/null; then
        echo "APPEND $src -> $trg ${mod:-}"
        cat "$src" >>"$trg"
      fi
      ;;
    *)
      if [ ! -e "$trg" ]; then
        echo "NEW    $src -> $trg ${mod:-}"
        cp "$src" "$trg"
        if [ -n "$mod" ]; then
          chmod "$mod" "$trg"
        fi
      fi
      ;;
  esac
done

# set up xdm to start at boot
f="/etc/ttys"
if grep '^ttyv[[:digit:]]\+[[:space:]]\+"/.*/xdm[ "].*\boff\b' "$f" >/dev/null
then
  echo "Set up xdm ..."
  sed -e '/^tty.*xdm/s/\<off\>/onifexists/' "$f" >"$f.2"
  cat "$f.2" >"$f"
  rm "$f.2"
fi

# set up WPA networking
f="/etc/wpa_supplicant.conf"
outf=/tmp/wpa_supplicant.conf
if awk -v outfile="$outf" -f wpa.awk "$f"; then
  if ! diff -q "$outf" "$f" >/dev/null; then
    cat "$outf" >"$f"
  fi
fi
rm "$outf"

# set up user
username=gabci
if ! id "$username" >/dev/null 2>&1; then
  echo "Add user $username ..."
  pw useradd -n "$username" -s /usr/local/bin/bash -G wheel -m
fi
