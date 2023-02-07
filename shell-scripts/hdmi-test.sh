#!/bin/bash

# The purpose of this script is to permanently set the resolution
# output for hdmi when connected.

xres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)"

# drm_tool source available at https://github.com/christianhaitian/drm_tool.git

mode="$(sudo drm_tool list | grep '1280x720 60' | head -1 | cut -d : -f 1)"

mode2="$(sudo drm_tool list | grep '1920x1080 60' | head -1 | cut -d : -f 1)"

# Now we tell drm what the hdmi mode is by writing to /var/run/drmMode
# This will get picked up by SDL2 as long as it's been patched with the batocera
# drm resolution patch.  This patch can be found at
# https://github.com/christianhaitian/rk3566_core_builds/raw/master/patches/sdl2-patch-0003-drm-resolution.patch

if [ $xres -eq "1280" ]; then
  echo $mode | sudo tee /var/run/drmMode
elif [ $xres -eq "1920" ]; then
  echo $mode2 | sudo tee /var/run/drmMode
else
  echo 0 | sudo tee /var/run/drmMode
fi
