#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "$(basename "$0"): this script requires root privileges." >&2
  exit 1
fi

du -sh /var/log

find /var/log -depth -type f -regextype sed -regex '.*\.[0-9]\+\(\.gz\)\?' \
  -exec rm {} \+

journalctl --vacuum-time=2h

du -sh /var/log
