#!/bin/bash

xres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)"
if [ $xres -eq "1280" ]; then
  echo 6 | sudo tee /var/run/drmMode
elif [ $xres -eq "1920" ]; then
  echo 0 | sudo tee /var/run/drmMode
fi
