#!/bin/bash

#######################################################################
# Created by Christian Haitian for use to get display panel           #
# info for Anbernic RG353 devices.  Panel information is              #
# added during boot by checking dmesg                                 #
# ex. @reboot dmesg | grep 'panel id' > /home/ark/.config/.panel_info #
# See the LICENSE.md file at the top-level directory of this          #
# repository.                                                         #
#######################################################################

function version() {
   screen_version=$(grep "panel id" ~/.config/.panel_info)

   if [[ "$screen_version" == *"30 52"* ]]; then
     echo "1"
   elif [[ "$screen_version" == *"38 21"* ]]; then
     echo "2"
   else
     echo "Unknown"
   fi
}

function id() {
   screen_id=$(grep "panel id" ~/.config/.panel_info | awk -F 'panel id: ' '{print $2}')

   if [[ ! -z ${screen_id} ]]; then
     echo "$screen_id"
   else
     echo "Unknown"
   fi
}

if test ! -z ${1}
then
  cmd=${1}
  shift
  $cmd "$1"
fi

exit 0
