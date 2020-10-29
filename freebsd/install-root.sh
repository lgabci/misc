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

# install etc files
if ! [ -e /usr/local/etc/sudoers.d/wheel ]; then
  echo "# allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL

# allow member of group wheel to power off without password
%wheel ALL=(ALL) NOPASSWD: /sbin/shutdown, /sbin/reboot" \
    >/usr/local/etc/sudoers.d/wheel

  chmod 600 /usr/local/etc/sudoers.d/wheel
fi
fi ##########################################################

# wlan devices
wpa=n
wlandevs=$(sysctl -n net.wlan.devices)
for d in $wlandevs; do
  case "$d" in
    ath0)
      wpa=y
      a="$(./getcont.sh /etc/rc.conf "$d")"
      ./cf.sh /home/gabci/rc.conf a - "$a"
      unset a

      sysrc keymap=hu.102
      sysrc wlans_ath0="wlan0"
      sysrc ifconfig_wlan0="DHCP WPA"
      sysrc create_args_wlan0="country HU regdomain ETSI"
      ;;
  esac
done

a="$(./getcont.sh /etc/rc.conf-2 "$d")"
./cf.sh /home/gabci/rc.conf a - "$a"
unset a

exit ## -------------------------------

if [ "$wpa" = y ]; then
  if ! [ -e /etc/wpa_supplicant.conf ]; then
    echo "network={
  ssid="omega"
  priority=10
  proto=RSN
  key_mgmt=WPA-PSK
  pairwise=CCMP
  group=CCMP
  psk="password"
}" >/etc/wpa_supplicant.conf
    chmod 600 /etc/wpa_supplicant.conf
  fi
fi

    /etc/login.conf
cap_mkdb /etc/login.conf
pw user mod root -L american
pw user mod gabci -L american

