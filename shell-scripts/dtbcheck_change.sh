#!/bin/bash

CURRENT_DTB="$(grep FDT /boot/extlinux/extlinux.conf | cut -c 8-)"
if [ -f "/home/ark/.config/.BRIGHTDTB" ]; then
  BASE_DTB_NAME="rk3566-OC.dtb.bright"
else
  BASE_DTB_NAME="rk3566-OC.dtb"
fi

MAX_VOLTAGE="$(hexdump -C /proc/device-tree/cpu0-opp-table/opp-1800000000/opp-microvolt | cut -c 11-21)"

function check() {
  if [[ "$MAX_VOLTAGE" == *"00 10 05 90"* ]]; then
    echo "STOCK"
  elif [[ "$MAX_VOLTAGE" == *"00 0e 7e f0"* ]]; then
    echo "LIGHT"
  elif [[ "$MAX_VOLTAGE" == *"00 0e 1d 48"* ]]; then
    echo "MEDIUM"
  elif [[ "$MAX_VOLTAGE" == *"00 0d 59 f8"* ]]; then
    echo "MAXIMUM"
  else
    echo "UNKNOWN"
  fi
}

function set() {
  if [[ "$1" == "STOCK" ]]; then
    sudo sed -i "/  FDT \/$CURRENT_DTB/c\  FDT \/${BASE_DTB_NAME}" /boot/extlinux/extlinux.conf
  else
    if [ -f "/boot/overlays/undervolt.${1,,}.dtbo" ]; then
      sudo fdtoverlay -i /boot/${BASE_DTB_NAME} -o /boot/${BASE_DTB_NAME}.undervolt.${1,,} /boot/overlays/undervolt.${1,,}.dtbo
      sudo sed -i "/  FDT \/$CURRENT_DTB/c\  FDT \/${BASE_DTB_NAME}.undervolt.${1,,}" /boot/extlinux/extlinux.conf
    else
          echo "Set of $1 failed due to /boot/undervolt.${1,,}.dtbo overlay file not being found."
        fi
  fi
}

cmd=${1}
shift
$cmd "$@"

exit 0
