#!/bin/sh

set -eu

PNAME=$(basename $0)

case $# in
  0)
    echo "Usage:" >&2
    echo "  $PNAME filename" >&2
    echo "  filename: the file content to be asked" >&2
    exit 1
    ;;
  *)
    fname="$1"
    shift
    ;;
esac

case "$fname" in

  "/etc/rc.conf")
    echo 'wlans_ath0="'"$1"'"
ifconfig_'"$1"'="DHCP WPA"
create_args_wlan0="country HU regdomain ETSI"'
    ;;

  "/etc/rc.conf-2")
    echo 'defaultroute_delay="15"'
    ;;

  "/boot/loader.conf")
    echo 'autoboot_delay=2
kern.vty="vt"'
    ;;

    /etc/login.conf
american|American Users Accounts:\
	:charset=UTF-8:\
	:lang=en_US.UTF-8:\
	:tc=default:

  *)
    echo "$PNAME: bad fname value: \"$fname\"" >&2
    exit 1
    ;;
esac

