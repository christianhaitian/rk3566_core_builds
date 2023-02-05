#!/bin/bash

# This script is designed to just reconnect to a wireless network if the existing connection stops working since networkmanager is usually not running
# which can impact the ability for a device to reconnect on it's own.

address="ip or dns name that should be reachable"
pri_ap="your main ssid"
bak_ap="you backup ssid if you have one"
LOG="/home/ark/wlan_reconnection.log"

for (( ; ; ))
do
  #Keep the log size in check
  if [ -f "$LOG" ]; then
    logsizecheck=$(stat -c %s "$LOG")
    if [ $logsizecheck -gt "1500000" ]; then
      sudo mv -f "$LOG" "$LOG".$(date +'%H_%M_%m%d%Y').bak
    fi
  fi
  #Now we check how our wireless network connection is doing
  if test ! -z "$(sudo ifconfig | grep wlan | tr -d '\0')" 
  then
    sudo ping -q -c 1 "$address" > /dev/null
    if [ $? -ne 0 ]; then
          sudo systemctl stop networkwatchdaemon
	  sudo systemctl start NetworkManager
	  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
	  nmcli con down "$cur_ap"
	  nmcli con up "$cur_ap"
	  if [ $? -ne 0 ]; then
	    nmcli con up "$pri_ap"
            if [ $? -ne 0 ]; then
              nmcli con up "$bak_ap"
              if [ $? -ne 0 ]; then
                echo "Couldn't successfully connect to any ap as of $(date +'%r on %A, %B %d, %Y').  Will try again in 10 seconds" >> "$LOG"
              else
                echo "Just finished connecting to $bak_ap as of $(date +'%r on %A, %B %d, %Y')" >> "$LOG"
              fi
            else
	      echo "Just finished connecting to $pri_ap as of $(date +'%r on %A, %B %d, %Y')" >> "$LOG"
            fi
          else
            echo "Just finished connecting to $cur_ap as of $(date +'%r on %A, %B %d, %Y')" >> "$LOG"
          fi
          sudo systemctl stop NetworkManager
          sudo systemctl start networkwatchdaemon
          sleep 10
    else
      echo "networkup: We're still good with wireless network connectivity" > /dev/kmsg
      sleep 60
    fi
  else
    echo "networkup: Wireless lan adapter seems to be disabled.  Doing nothing for now" > /dev/kmsg
    sleep 30
  fi
done
