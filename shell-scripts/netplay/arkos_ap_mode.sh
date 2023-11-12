#!/bin/bash

# AP mode for use with local netplay in ArkOS

function Enable {
  nmcli d disconnect wlan0 > /dev/null
  host_ap_masked=$(systemctl status hostapd.service | grep masked)
  if [ ! -z $1 ]; then
    sudo sed -i "/ssid\=/c\ssid\=ArkOS_AP_$1" /etc/hostapd/hostapd.conf
  else
    sudo sed -i "/ssid\=/c\ssid\=ArkOS_AP" /etc/hostapd/hostapd.conf
  fi
  if [ ! -z ${host_ap_masked} ]; then
    sudo systemctl unmask hostapd.service
    sudo systemctl disable hostapd.service
    sudo systemctl disable dnsmasq.service
  fi
  sudo systemctl restart hostapd.service
  if [ $? != 0 ]; then
    echo "Failed setting up hostapd"
    Disable
    exit 1
  fi
  sudo systemctl restart dnsmasq.service
  if [ $? != 0 ]; then
    echo "Failed setting up dnsmasq"
    Disable
    exit 1
  fi
  sudo ifconfig wlan0 192.168.1.1 netmask 255.255.255.0
  if [ $? != 0 ]; then
    echo "Failed setting a static ip for wlan0"
    Disable
    exit 1
  fi
  echo "Success!"
}

function Disable {
  sudo systemctl stop hostapd.service
  sudo systemctl stop dnsmasq.service
  sudo ifconfig wlan0 0.0.0.0
  nmcli c delete "$(iw dev wlan0 info | grep ssid | cut -c 7-30)"
  nmcli d disconnect wlan0 > /dev/null
  nmcli d connect wlan0 > /dev/null &
  echo "Success!"
}

cmd=${1}
shift
if [[ -z ${cmd} ]]; then
  printf "\nNo valid argument provided such as Enable or Disable\n\n"
  exit 1
fi
$cmd $1

exit 0

