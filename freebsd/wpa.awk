BEGIN {
  FS = "="
  inblk = 0
}

{
  gsub(" ", "", $1)
  if ($1 == "network" && $2 == "{") {
    inblk = 1
    wpa = 0
    ssid = ""
  }
  else if ($1 == "}") {
    inblk = 0
  }
  else if (inblk && $1 == "ssid" && $2) {
    ssid=$2
    gsub("^[ \t]*\"|\"[ \t]*$", "", ssid)
  }
  else if (inblk && \
    ( $1 == "proto" && ($2 == "RSN" || $2 == "WPA" || $2 == "WPA2") || \
      $1 == "key_mgmt" && $2 == "WPA-PSK" \
    )) {
    wpa=1
    gsub("^[ \t]*\"|\"[ \t]*$", "", ssid)
  }
  else if (inblk && ssid && wpa && $1 == "psk" && $2 ~ "\"\\*+\"") {
    print("Passphrase for SSID \"", ssid, "\"")
    getline passphrase <"-"
    cmd = "wpa_passphrase " ssid " " passphrase
    print("CMD: ", cmd)  ####
    while (cmd | getline pass) {
      print(". " pass)  ####
    }
    close(cmd)
  }
}
