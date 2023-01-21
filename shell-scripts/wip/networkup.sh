#!/bin/bash

## This script is designed to just reconnect to a wireless network if the existing connection stops working since networkmanager is usually not running
## which can impact the ability for a device to reconnect on it's own.

address="your ssid"
bak_ap="backup ssid"

for (( ; ; ))
do
  if test ! -z "$(sudo ifconfig | grep wlan | tr -d '\0')"
  then
    sudo ping -c 1 "$address"
    if [ $? -ne 0 ]; then
          sudo systemctl stop networkwatchdaemon
          sudo systemctl start NetworkManager
          cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
          nmcli con down "$cur_ap"
          nmcli con up "$cur_ap"
          if [ $? -ne 0 ]; then
            nmcli con up "$bak_ap"
            echo "Just finished connecting to $bak_ap" >> /home/ark/wlan_reconnection.log
          else
            echo "Just finished connecting to $cur_ap" >> /home/ark/wlan_reconnection.log
          fi
          sudo systemctl stop NetworkManager
          sudo systemctl start networkwatchdaemon
    else
      echo "networkup: We're still good with wireless network connectivity" > /dev/kmsg
      sleep 60
    fi
  else
    echo "networkup: Wireless lan adapter seems to be disabled.  Doing nothing for now" > /dev/kmsg
    sleep 30
  fi
done
