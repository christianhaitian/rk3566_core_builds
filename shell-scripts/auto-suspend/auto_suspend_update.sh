#!/bin/bash

if [ ! -z $(grep Off /home/ark/.config/.TIMEOUT | tr -d '\0') ]; then
  sudo systemctl stop autosuspend &
  sudo systemctl disable autosuspend &
  echo "Disabled Auto Suspend daemon" | sudo tee /dev/kmsg
else
  sudo systemctl restart autosuspend &
  sudo systemctl enable autosuspend &
  echo "Enabled Auto Suspend daemon for $(cat /home/ark/.config/.TIMEOUT) minutes" | sudo tee /dev/kmsg
fi
