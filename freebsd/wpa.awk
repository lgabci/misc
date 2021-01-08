BEGIN {
  FS = "="
  inblk = 0
  if (! outfile) {
    print("Error: variable outfile is empty")
    exit 1
  }
  printf("") >outfile
}

{
  printstr = $0
  gsub("^[ \t]*|[ \t]*$", "", $1)

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
  # SSID
  else if (inblk && $1 == "ssid" && $2) {
    ssid=$2
    gsub("^[ \t]*\"|\"[ \t]*$", "", ssid)
  }
  # check for WPA2
  else if (inblk && \
    ( $1 == "proto" && ($2 == "RSN" || $2 == "WPA2") || \
      $1 == "key_mgmt" && $2 == "WPA-PSK" \
    )) {
    wpa=1
    gsub("^[ \t]*\"|\"[ \t]*$", "", ssid)
  }
  # check for psk="*****"
  else if (inblk && ssid && wpa && $1 == "psk" && $2 ~ "\"\\*+\"") {
    do {
      # get WPA passphrase
      do {
        print("Passphrase for SSID \"" ssid "\"")
        getline passphrase <"-"
        len = length(passphrase)
        len_ok = len >= 8 && len <= 63
        if (! len_ok) {
          print("WPA passphrase must be 8..63 characters.")
        }
      } while (! len_ok)

      # get psk line
      cmd = "wpa_passphrase " ssid " " passphrase "; echo $?"
      inblk2 = 0
      pskline = ""
      errline = ""
      while (cmd | getline pass) {
        errline = errline (errline ? "\n" : "") pass

        # start of network block
        if (pass ~ /^[ \t]*network={[ \t]*$/ ) {
          inblk2 = 1
        }
        # end of network block
        else if (inblk2 && pass ~ /^[ \t]*}[ \t]*$/) {
          inblk2 = 0
        }
        # psk and #psk lines
        else if (inblk2 && pass ~ /^[ \t]*#?psk[ \t]*=/) {
          pskline = pskline (pskline ? "\n" : "") pass
        }
      }
      close(cmd)
      status = pass

      # print error message
      if (status != "0") {
        sub(/\n[^\n]*$/, "", errline)
        print(errline)
      }
    } while (status != "0")
    printstr = pskline
  }

  print(printstr) >>outfile
}
