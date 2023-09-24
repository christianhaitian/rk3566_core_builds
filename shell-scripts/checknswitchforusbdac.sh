#!/bin/bash

DAC="0"
DAC_EXIST=""

for (( ; ; ))
do

if [ ! -e "/dev/snd/controlC7" ] && [[ "$DAC_EXIST" != "None" ]]; then
  sed -i '/hw:[0-9]/s//hw:0/' /home/ark/.asoundrc /home/ark/.asoundrcbak
  sudo systemctl restart oga_events &
  DAC_EXIST="None"
elif [ -e "/dev/snd/controlC7" ] && [[ "$DAC" != "$DAC_EXIST" ]]; then
  DAC=$(ls -l /dev/snd/controlC7 | awk 'NR>=control {print $11;}' | cut -d 'C' -f2)
  readarray -t USB_DAC < <(amixer -q -c ${DAC} scontents | grep 'Simple mixer control ' | cut -d "'" -f2)
  for i in "${USB_DAC[@]}"
  do
    amixer -q -c ${DAC} sset "${i}" 100%
  done
  sed -i '/hw:[0-9]/s//hw:'$DAC'/' /home/ark/.asoundrc /home/ark/.asoundrcbak
  sudo systemctl restart oga_events &
  DAC_EXIST="$DAC"
fi
 sleep 1
done
