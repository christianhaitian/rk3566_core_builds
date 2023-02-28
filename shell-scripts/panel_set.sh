#!/bin/bash

##################################################################
# Created by Christian Haitian for use to set saturation, hue    #
# contrast, and brightness of panels for rk3566 devices          #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

function set_brightness() {
   sudo panel_drm_tool set /dev/dri/card0 133 brightness "$1"
}

function set_contrast() {
   sudo panel_drm_tool set /dev/dri/card0 133 contrast "$1"
}

function set_saturation() {
   sudo panel_drm_tool set /dev/dri/card0 133 saturation "$1"
}

function set_hue() {
   sudo panel_drm_tool set /dev/dri/card0 133 hue "$1"
}

function get_brightness() {
   panel_drm_tool list | grep -A 9 133 | grep brightness | awk -F 'brightness = ' '{print $2}'
}

function get_contrast() {
   panel_drm_tool list | grep -A 9 133 | grep contrast | awk -F 'contrast = ' '{print $2}'
}

function get_saturation() {
   panel_drm_tool list | grep -A 9 133 | grep saturation | awk -F 'saturation = ' '{print $2}'
}

function get_hue() {
   panel_drm_tool list | grep -A 9 133 | grep hue | awk -F 'hue = ' '{print $2}'
}

function SaveSettingsOnShutdown() {
  let xres=$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)
  if [ $xres -lt "1280" ]; then
    mapfile settings < /home/ark/.config/panel_settings.txt
    settings[0]="brightness: $(get_brightness)"
    settings[1]="contrast: $(get_contrast)"
    settings[2]="saturation: $(get_saturation)"
    settings[3]="hue: $(get_hue)"

    for j in "${settings[@]}"
    do
      echo $j
    done > /home/ark/.config/panel_settings.txt
  else
    echo " Device may be connected to hdmi.  Not saving any settings this time."
  fi

}

function RestoreSettings() {
  let xres=$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)
  if [ $xres -lt "1280" ]; then
     mapfile settings < /home/ark/.config/panel_settings.txt
     if [ "$(echo ${settings[1]} | awk '{print $2}')" -lt "10" ] || [ -z "$(echo ${settings[1]} | awk '{print $2}')" ];then
       settings[1]="$(echo ${settings[1]} | awk '{print $1}') 50"
     fi
     set_brightness "$(echo ${settings[0]} | awk '{print $2}')"
     set_contrast "$(echo ${settings[1]} | awk '{print $2}')"
     set_saturation "$(echo ${settings[2]} | awk '{print $2}')"
     set_hue "$(echo ${settings[3]} | awk '{print $2}')"
  else
    echo " Device may be connected to hdmi.  Not restoring any settings this time."
  fi
}

if [ ! -f "/home/ark/.config/panel_settings.txt" ]; then
  touch /home/ark/.config/panel_settings.txt
  echo "brightness: 50" >> /home/ark/.config/panel_settings.txt
  echo "contrast: 50" >> /home/ark/.config/panel_settings.txt
  echo "saturation: 50" >> /home/ark/.config/panel_settings.txt
  echo "hue: 50" >> /home/ark/.config/panel_settings.txt
fi

cmd=${1}
shift
$cmd "$1"

exit 0
