#!/bin/sh

set -eu

PNAME=$(basename $0)
DIR=files

get_wpa_supplicant ( )
{
  ssid=$(awk -F = '/ssid=/{gsub("^\"|\"$","",$2);print $2;exit}' "$src")
  if [ -z "$ssid" ]; then
    echo "Can not found SSID in $src." >&2
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
      awk -v psk="$psk" '/psk/{print psk;next}{print}' "$src" >"$trg"
      unset ssid passphr
      break
    fi
  done
}

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

while read src trg mod <&3; do
  src="$DIR/$src"
  case "$src" in
    *.append)
      lines=$(wc -l <"$src")
      if ! tail -n "$lines" "$trg" | diff "$src" - >/dev/null; then
        echo "APPEND $trg"
        cat "$src" >>"$trg"
      fi
      ;;
    *)
      if [ ! -e "$trg" ]; then
        echo "NEW    $trg $mod"
        case "$src" in
          */wpa_supplicant.conf)
            get_wpa_supplicant
            ;;
          *)
            cp "$src" "$trg"
            ;;
        esac
        if [ -n "$mod" ]; then
          chmod "$mod" "$trg"
        fi
      fi
      ;;
  esac

done 3<"$DIR"/root.txt


#cap_mkdb /etc/login.conf
#pw user mod root -L american
#pw user mod gabci -L american

