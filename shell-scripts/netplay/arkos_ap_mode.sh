#!/bin/bash

#Copyright 2023 Christian_Haitian
#
#Permission is hereby granted, free of charge, to any person 
#obtaining a copy of this software and associated documentation
#files (the “Software”), to deal in the Software without 
#restriction, including without limitation the rights to use,
#copy, modify, merge, publish, distribute, sublicense, and/or
#sell copies of the Software, and to permit persons to whom
#the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included 
#in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
#THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# AP mode for use with local netplay in ArkOS
#

function Enable {
  nmcli d disconnect wlan0 > /dev/null
  host_ap_masked=$(systemctl status hostapd.service | grep masked)
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
$cmd

exit 0
