#!/bin/bash

if [ -e "/home/ark/.config/.SWAPVOLUMEBUTTONS" ] && [[ "${1}" != *"%"* ]]; then
  if [[ "${1}" == *"+"* ]]; then
    value="$(sed '/+/s//-/' <<< $1)"
  else
    value="$(sed '/-/s//+/' <<< $1)"
  fi
else
  value="${1}"
fi

if test ! -z "$(cat /home/ark/.asoundrc | grep softvol)"
then
  amixer -q sset Master ${value}
else
  pcms=$(bluealsa-cli list-pcms)

  for pcm in $pcms; do
    curVol=$(bluealsa-cli volume ${pcm} | awk 'NR==1' | cut -d " " -f3)
  done

  for pcm in $pcms; do
    if [[ "${value}" == *"-"* ]]; then
      newVol=$(( $curVol - 1 ))
      if (( $newVol >= 0 )); then
        bluealsa-cli volume ${pcm} ${newVol}
      else
        echo "Minimum volume reached"
      fi
    elif [[ "${value}" == *"+"* ]]; then
      newVol=$(( $curVol + 1 ))
      if (( $newVol <= 127 )); then
        bluealsa-cli volume ${pcm} ${newVol}
      else
        echo "Maximum volume reached"
      fi
    else
      echo "No operand specified.  Please specify + for volume increase or - for volume decrease"
      exit 1
    fi
    echo ${newVol}
  done
fi
exit 0
