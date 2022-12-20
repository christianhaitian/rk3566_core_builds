#!/bin/bash

bton=$(sudo systemctl status bluetooth | grep "disabled")

if [ -z "$bton" ]
then
      sudo systemctl stop watchforbtaudio
      sudo systemctl disable watchforbtaudio
      sudo systemctl stop bluetooth
      sudo systemctl disable bluetooth
      sudo systemctl stop bluealsa
      sudo systemctl disable bluealsa
      sudo systemctl stop enable_bluetooth
      sudo systemctl disable enable_bluetooth
      sudo systemctl restart oga_events
      cp -f /home/ark/.asoundrcbak /home/ark/.asoundrc
else
      sudo systemctl start enable_bluetooth
      sudo systemctl enable enable_bluetooth
      sudo systemctl start bluetooth
      sudo systemctl enable bluetooth
      sudo systemctl start bluealsa
      sudo systemctl enable bluealsa
      sudo systemctl start watchforbtaudio
      sudo systemctl enable watchforbtaudio
      sudo systemctl restart oga_events
fi
