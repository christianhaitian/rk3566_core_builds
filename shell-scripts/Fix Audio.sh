#!/bin/bash

clear

DEVICE=""

if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz
else
  sudo setfont /usr/share/consolefonts/Lat7-Terminus16.psf.gz
fi

if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
  if [ "$(cat ~/.config/.DEVICE)" == "RG353M" ]; then
    DEVICE="rg503"
  elif [ "$(cat ~/.config/.DEVICE)" == "RG353V" ]; then
    DEVICE="rg353v"
  elif [ "$(cat ~/.config/.DEVICE)" == "RGB20PRO" ]; then
    DEVICE="rg353v"
  elif [ "$(cat ~/.config/.DEVICE)" == "RK2023" ]; then
    DEVICE="rg503"
  elif [ "$(cat ~/.config/.DEVICE)" == "RGB30" ]; then
    DEVICE="rg503"
  elif [ "$(cat ~/.config/.DEVICE)" == "RG503" ]; then
    DEVICE="rg503"
  else
    echo "This device is not compatible with this process."
	echo "Exiting..."
	sleep 3
    if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
      sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
    fi

    printf "\033c" > /dev/tty1
	exit 1
  fi
else
    echo "This device is not compatible with this process."
	echo "Exiting..."
	sleep 3
    if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
      sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
    fi

    printf "\033c" > /dev/tty1
	exit 1
fi

. /usr/local/bin/buttonmon.sh

echo "The purpose of this tool to fix no sound"
echo "issues if related to a software configuration"
echo "issue in this ArkOS installation."
echo ""
echo "Are you sure you want to fix Audio? Be aware"
echo "that this will reset audio to come out from"
echo "this device's speakers and any currently"
echo "connected headphones will need to be"
echo "disconnected and reconnected upon"
echo "completion of this process."
echo ""
echo "Press A to continue.  Press B to exit."
while true
do
    Test_Button_A
    if [ "$?" -eq "10" ]; then
      sudo chown ark:ark /home/ark/.asoundrc*
      cp -f /usr/local/bin/.asoundbackup/.asoundrcbak.${DEVICE} /home/ark/.asoundrcbak
      cp -f /usr/local/bin/.asoundbackup/.asoundrcbak.${DEVICE} /home/ark/.asoundrc
      sudo chown ark:ark /home/ark/.asoundrc*
      if [ "$(cat ~/.config/.DEVICE)" == "RGB30" ] || [ "$(cat ~/.config/.DEVICE)" == "RK2023" ] ; then
        amixer -q sset 'Playback Path' HP
      else
        amixer -q sset 'Playback Path' SPK
      fi
      amixer -q sset Master 127
      printf "\nFix audio process completed.\n"
      printf "\nPress A to test sound.  Press B to continue\n"
      printf "with restarting Emulationstation.\n"
      while true
      do
          Test_Button_A
          if [ "$?" -eq "10" ]; then
            printf "Playing a sound now.\n"
            aplay -q /usr/local/bin/round_end.wav
            #ffplay -autoexit -t 2 -hide_banner -loglevel error /usr/local/bin/round_end.wav
            clear
            printf "Press A to test sound again.  Press B to\n"
            printf "continue with restarting Emulationstation.\n"
		  fi
          Test_Button_B
          if [ "$?" -eq "10" ]; then
            break
		  fi
      done
      printf "\nEmulationstation will now be restarted.."
      sleep 3
      if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
        sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
      fi

      printf "\033c" > /dev/tty1
      sudo systemctl restart emulationstation
      exit 0
    fi

    Test_Button_B
    if [ "$?" -eq "10" ]; then
      printf "\nExiting without fixing audio"
	  sleep 1
      if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
        sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
      fi

      printf "\033c" > /dev/tty1
	  exit 0
	fi
done

if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
fi

printf "\033c" > /dev/tty1
