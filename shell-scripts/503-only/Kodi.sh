#!/bin/bash

if [ -z "$(grep importlib_metadata /home/ark/.kodi/addons/script.module.urllib3/lib/urllib3/http2/__init__.py | tr -d '\0')" ]; then
  sed -i '/from importlib.metadata import version/c\try:\n  from importlib.metadata import version\nexcept:\n  from importlib_metadata import version' /home/ark/.kodi/addons/script.module.urllib3/lib/urllib3/http2/__init__.py
fi

export KODI_HOME=/opt/kodi/share/kodi
#export PYTHONHOME=/opt/kodi/lib/kodi/kodi-gbm
export PYTHONPATH=/lib/python3.7/

#Set interactive governor to keep kodi performance smooth
sudo perfmax kodi

# Fix wasting RAM due to fragmentation
export MALLOC_MMAP_THRESHOLD_=131072

# Change owner of volume keys or Kodi will grab them
#if [ "$(cat ~/.config/.DEVICE)" != "RG503" ]; then
  if [[ -e "/dev/input/by-path/platform-fe5b0000.i2c-event" ]]; then
    sudo chown root:root /dev/input/event3
  else
    sudo chown root:root /dev/input/event2
  fi
  sudo chown root:root /dev/input/event0
#else
 #sudo chown root:root /dev/input/event1
#fi

printf "\n\n\e[32mStarting Kodi.  Please wait..."
export LD_LIBRARY_PATH=/opt/kodi/libs/:/opt/kodi/libs/samba

cd /opt/kodi
sudo /opt/quitter/oga_controls kodi-gbm rg503 &

if [[ ! -d "/home/ark/.kodi" ]]; then
  mkdir /home/ark/.kodi
  cp -R /opt/kodi/userdata/ /home/ark/.kodi/
fi

/opt/kodi/lib/kodi/kodi-gbm

# Make sure quitter is killed if exiting Kodi through the menu
# or ES navigation will be wonky.
if [[ ! -z $(pidof oga_controls) ]]; then
  sudo kill -9 $(pidof oga_controls)
fi

#Set ondemand governor to preserve battery life
sudo perfnorm

# Restart global hotkey deamon just in case it was impacted by the quitter
sudo systemctl restart oga_events &

# Clean up screen when done
printf "\033c" >> /dev/tty1
