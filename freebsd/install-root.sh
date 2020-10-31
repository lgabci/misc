#!/bin/sh

set -eu

PNAME=$(basename $0)

# test root
if [ $(id -u) != 0 ]; then
  echo "$PNAME: must be run by root" >&2
  exit 1
fi

if false; then ###############################################
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
sysrc slim_enable=YES

# install packages
pkg install -y xorg icewm slim sudo vim bash bash-completion
fi ##########################################################

while read src trg mod; do
  case "$src" in
    *.append)
      src="$(basename "$src")"
      echo "APPEND $src --> $trg"
      ;;
    *)
      echo "new    $src --> $trg"
      ;;
  esac
done <files/root.txt



exit #######################################################

cap_mkdb /etc/login.conf
pw user mod root -L american
pw user mod gabci -L american

