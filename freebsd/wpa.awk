BEGIN {
  FS = "="
  inblk = 0
}

{
  gsub(" ", "", $1)

  # start of network block
  if ($1 == "network" && $2 == "{") {
    inblk = 1
    wpa = 0
    ssid = ""
  }
  # end of network block
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
    do {
      do {
        print("Passphrase for SSID \"" ssid "\"")
        getline passphrase <"-"
        len = length(passphrase)
        len_ok = len >= 8 && len <= 63
        if (! len_ok) {
          print("WPA passphrase must be 8..63 characters.")
        }
      } while (! len_ok)

      cmd = "wpa_passphrase " ssid " " passphrase "; echo $?"
      print("CMD: " cmd)  ####
      while (cmd | getline pass) {
        print(". " pass)  ####
        status = pass
      }
      close(cmd)
      print("Status: " status)  ####
    } while (status != 0)
  }
}
