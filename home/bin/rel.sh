#!/bin/bash

set -eu

# check parameters
if [ $# -ne 2 ]; then
  echo "usage:" >&2
  echo "$(basename $0) str_file secs" >&2
  echo "  str_file: .srt file to adjust time" >&2
  echo "  secs    : time seconds, it can be a negative" >&2
  exit 1
fi

FILE="$1"
SECS="$2"

# check if file exists
if ! [ -f "$FILE" ]; then
  echo "File not found ($FILE)" >&2
  exit 1
fi

# check if secs is a number
if ! [[ "$SECS" =~ ^-?[[:digit:]]{1,4}(\.[[:digit:]]{1,3})?$ ]]; then
  echo "$SECS is not a 0009.000 format number" >&2
  exit 1
fi

awk 'BEGIN {
       SECS='$SECS'
     }
       function addsec(p) {
         split(p, t, ":");
         sub(",", ".", t[3])
         s=(t[1] * 60 + t[2]) * 60 + t[3] + SECS

         sec=s % 60
         min=int(s / 60) % 60
         hr=int(s / 60 / 60) % 60

         ret=sprintf("%02d:%02d:%06.3f", hr, min, sec)
         sub("\\.", ",", ret)
         return ret
       }

     {
       if (NR == 1) {
         sub(/^\xef\xbb\xbf/,"",$0)
       }
       gsub("\r", "", $0);
       if ($0 ~ /^[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2},[[:digit:]]{3} +--> +[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2},[[:digit:]]{3}$/) {
         print(addsec($1), "-->", addsec($3))
       }
       else {
         print $0
       }
     }' "$FILE" > "$FILE.2"
mv "$FILE.2" "$FILE"
