#!/bin/bash

function check() {
  sudo rm -f /var/local/btautoreconnect.state
  if [ ! -z $(pidof rtk_hciattach) ]; then
    bluetoothctl paired-devices | cut -f2 -d' '|
    while read -r uuid
    do
        info=`bluetoothctl info $uuid`
        if echo "$info" | grep -q "Connected: yes"; then
           echo "$info" | grep "Device" | cut -f2 -d' ' >> /var/local/btautoreconnect.state
        fi
    done
    exit 0
  else
    echo "Bluetooth seems to be off."
    exit 0
  fi
}

function reconnect() {
  if [ -f "/var/local/btautoreconnect.state" ]; then
    MACS=`cat /var/local/btautoreconnect.state`
  else
    echo "No btautoreconnect.state file found in the /var/local folder"
    exit 1
  fi

  for MAC in $MACS; do
    sleep 1
    if [[ "${MAC}" =~ ^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$ ]]; then
      if [[ "$(echo "info ${MAC}" | bluetoothctl | grep "Connected" | cut -d " " -f 2)" == "no" ]]; then
        echo "connect ${MAC}" | bluetoothctl
        sleep 5
      else
        echo "${MAC} is already connected."
      fi
    else
      echo "Invalid entry found and has been skipped"
    fi
  done
}

cmd=${1}
shift
$cmd "$@"

exit 0
