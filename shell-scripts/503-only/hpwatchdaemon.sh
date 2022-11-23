#!/bin/bash

if [ ! -z "$(dmesg | grep 'headset status is out')" ]; then
  amixer -q sset 'Playback Path' SPK
  sudo dmesg -c
elif [ ! -z "$(dmesg | grep 'headset status is in')" ]; then
  amixer -q sset 'Playback Path' HP
  sudo dmesg -c
fi

for (( ; ; ))
do
 if [ ! -z "$(dmesg | grep 'headset status is out')" ]; then
   amixer -q sset 'Playback Path' SPK
   sudo dmesg -c
 elif [ ! -z "$(dmesg | grep 'headset status is in')" ]; then
   amixer -q sset 'Playback Path' HP
   sudo dmesg -c
 fi
 sleep 1
done

