#!/bin/bash

#Copyright 2023 Christian_Haitian
#
#Permission is hereby granted, free of charge, to any person
#obtaining a copy of this software and associated documentation
#files (the “Software”), to deal in the Software without
#restriction, including without limitation the rights to use,
#copy, modify, merge, publish, distribute, sublicense, and/or
#sell copies of the Software, and to permit persons to whom
#the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included
#in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
#THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# Local NetPlay Setup
#

sudo chmod 666 /dev/tty0
printf "\033c" > /dev/tty0

# hide cursor
#printf "\e[?25l" > /dev/tty0
dialog --clear 2>&1 > /dev/tty0

height="15"
width="55"

if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"
then
  height="20"
  width="60"
fi

ExitCode="0"

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  sudo setfont /usr/share/consolefonts/Lat7-TerminusBold20x10.psf.gz
fi

pgrep -f gptokeyb | sudo xargs kill -9
pgrep -f osk.py | sudo xargs kill -9
printf "\033c" > /dev/tty0
printf "Starting Local Netplay Session Manager.  Please wait..." 2>&1 > /dev/tty0
old_ifs="$IFS"

ExitMenu() {
  printf "\033c" > /dev/tty0
  if [[ ! -z $(pgrep -f gptokeyb) ]]; then
    pgrep -f gptokeyb | sudo xargs kill -9
  fi
  if [[ ! -z $(pgrep -f gptokeyb) ]]; then
    pgrep -f gptokeyb | sudo xargs kill -9
  fi
  if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  fi
  if [ ! -z "$samegame" ]; then
    if [[ "$ExitCode" != "250" ]]; then
      /opt/retroarch/bin/${emulator} -c /home/ark/.config/${emulator}/retroarch.cfg --connect=192.168.1.1 --nick=ArkOS_Client_"${core}"_Session_"$(cat /sys/class/net/wlan0/address | awk -F':' '{ print $4$5$6}')" -L /home/ark/.config/${emulator}/cores/${core}_libretro.so "$game"
      ExitCode="231"
      exit ${ExitCode}
    else
      /opt/retroarch/bin/retroarch -c /home/ark/.config/retroarch/retroarch.cfg -H --nick=ArkOS_Host_"${core}"_Session_"$(cat /sys/class/net/wlan0/address | awk -F':' '{ print $4$5$6}')" -L /home/ark/.config/${emulator}/cores/${core}_libretro.so "$game"
      ExitCode="231"
      exit ${ExitCode}
    fi
  else
    exit ${ExitCode}
  fi
}

Select() {
  if [[ "$1" != "ArkOS_AP" ]]; then
    pgrep -f gptokeyb | sudo xargs kill -9
  fi

  if [[ "$1" == *"ArkOS_"* ]]; then
   PASS="Ark0s11o52o23"
  fi

  dialog --infobox "\nConnecting to local network named $1..." 5 $width 2>&1 > /dev/tty0
  clist2=`sleep 1 && sudo nmcli dev wifi rescan && sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
  if [ -z "$(echo $clist2 | grep ArkOS_)" ]; then
    sleep 5
    clist2=`sudo nmcli dev wifi rescan && sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
  fi

  output=`nmcli device wifi connect "$1" password "$PASS"`
  success=`echo "$output" | grep successfully`

  if [ -z "$success" ]; then
    output="Could not find and connect to $1 ..."
    sudo rm -f /etc/NetworkManager/system-connections/"$1".nmconnection
    if [[ "$1" != "ArkOS_AP" ]]; then
      MainMenu
    fi

    . /usr/local/bin/buttonmon.sh

    dialog --infobox "Trying to connect to Host...\nPress and hold B to stop waiting and cancel receiving game file" 6 $width 2>&1 > /dev/tty0
    while true
    do
      Test_Button_B
      if [ "$?" -ne "10" ]; then
        clist2=`sleep 1 && sudo nmcli dev wifi rescan && sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
        output=`nmcli device wifi connect "$1" password "$PASS"`
        success=`echo "$output" | grep successfully`
        if [ ! -z "$success" ]; then
          output="Device successfully connected to $1 ..."
          break
        fi
      else
        break
      fi
   done
  else
    output="Device successfully activated and connected to $1 ..."
    sudo rm -f /etc/NetworkManager/system-connections/"$1".nmconnection
  fi

  dialog --infobox "\n$output" 6 $width 2>&1 > /dev/tty0
  sleep 3

  if [ ! -z "$2" ]; then
    continue
  elif [[ "$1" != "ArkOS_AP" ]]; then
    ExitCode="138"
    ExitMenu
  fi
}

Host() {

  dialog --infobox "\nSetting up local netplay session ..." 5 $width 2>&1 > /dev/tty0

  sleep 1

  output=`arkos_ap_mode.sh Enable $core`

  success=`echo "$output" | grep Success`

  if [ -z "$success" ]; then
    output="Failed setting up hosting for the local netplay session."
    dialog --infobox "\n$output" 6 $width 2>&1 > /dev/tty0
    sleep 3
    MainMenu
  else
    output="Host setup for local netplay session is now ready!"
    dialog --infobox "\n$output" 6 $width 2>&1 > /dev/tty0
    sleep 3
    ExitCode="250"
    ExitMenu
  fi
}

Client() {

. /usr/local/bin/buttonmon.sh

dialog --infobox "\nLooking for $core ArkOS NetPlay session ...\n \
Press and hold B to cancel this attempt to connect to the $core ArkOS NetPlay session." 6 $width 2>&1 > /dev/tty0
while true
do
  Test_Button_B
  if [ "$?" -ne "10" ]; then
    clist=`sleep 1 && sudo nmcli dev wifi rescan && sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
    if [ -z "$clist" ]; then
      clist=`sleep 1 && sudo nmcli dev wifi rescan && sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
    fi

    if [ ! -z "$1" ] && [ ! -z "$(echo $clist | grep $core)" ]; then
      Select ArkOS_AP_"$core" "$1"
      break
    elif [ ! -z "$(echo $clist | grep $core)" ]; then
      Select ArkOS_AP_"$core"
      break
    fi
  else
    break
  fi
done
}

LessBusyChannel() {
  if [[ ! -z $(cat /etc/hostapd/hostapd.conf | grep "hw_mode=g") ]]; then
    AvailChannels=( "2412" "2437" "2462" )
    Channels=( "Channel1" "Channel6" "Channel11" )
    AreaChannels=`timeout --kill-after=1s 6s sudo iw dev wlan0 scan | grep -E '24(12|37|62)'`
    if [[ "$AreaChannels" == "Terminated" ]]; then
      AreaChannels=`timeout --kill-after=1s 6s sudo iw dev wlan0 scan | grep -E '24(12|37|62)'`
    fi
    i=0
    # Loop through channel list and get the count of them found
    for ChannelCheck in ${AvailChannels[@]}
    do
       Channels[$i]=$(echo "$AreaChannels" | grep -o "$ChannelCheck" | wc -l)
       let i++
    done

    # Find the channel number with the lowest number of occurrence
    Position=$(echo "${Channels[@]}" | tr -s ' ' '\n' | awk '{print($0" "NR)}' | sort -g -k1,1 | head -1 | cut -f2 -d' ')
    case $Position in
       1) BestChannel=1
       ;;
       2) BestChannel=6
       ;;
       3) BestChannel=11
       ;;
       *) BestChannel=6
       ;;
    esac
  else
    AvailChannels=( "5180" "5200" "5220" "5240" "5745" "5765" "5785" "5805" )
    Channels=( "Channel36" "Channel40" "Channel44" "Channel48" "Channel149" "Channel153" "Channel157" "Channel161" )
    AreaChannels=`timeout --kill-after=1s 6s sudo iw dev wlan0 scan | grep -E '5(180|200|220|240|745|765|785|805)'`
    if [[ "$AreaChannels" == "Terminated" ]]; then
      AreaChannels=`timeout --kill-after=1s 6s sudo iw dev wlan0 scan | grep -E '5(180|200|220|240|745|765|785|805)'`
    fi
    i=0
    # Loop through channel list and get the count of them found
    for ChannelCheck in ${AvailChannels[@]}
    do
       Channels[$i]=$(echo "$AreaChannels" | grep -o "$ChannelCheck" | wc -l)
       let i++
    done

    # Find the channel number with the lowest number of occurrence
    Position=$(echo "${Channels[@]}" | tr -s ' ' '\n' | awk '{print($0" "NR)}' | sort -g -k1,1 | head -1 | cut -f2 -d' ')
    case $Position in
       1) BestChannel=36
       ;;
       2) BestChannel=40
       ;;
       3) BestChannel=44
       ;;
       4) BestChannel=48
       ;;
       5) BestChannel=149
       ;;
       6) BestChannel=153
       ;;
       7) BestChannel=157
       ;;
       8) BestChannel=161
       ;;
       *) BestChannel=44
       ;;
    esac
  fi
}

ShareCurrentGame() {

echo "" | sudo tee /var/lib/misc/dnsmasq.leases
output=`arkos_ap_mode.sh Enable`

success=`echo "$output" | grep Success`

if [ -z "$success" ]; then
  output="Failed setting up ArkOS_AP for client connection."
  dialog --infobox "\n$output" 6 $width 2>&1 > /dev/tty0
  sleep 3
  GameShare
else
  output="ArkOS_AP is ready for a client connection"
  dialog --infobox "\n$output" 6 $width 2>&1 > /dev/tty0
  AP_ON="On"
  sleep 3
fi

. /usr/local/bin/buttonmon.sh

dialog --infobox "\nWaiting for client to connect to share $(echo $game | awk -F '/' '{print $NF}')\n \
Press B to stop waiting and cancel sharing $(echo $game | awk -F '/' '{print $NF}')" 6 $width 2>&1 > /dev/tty0
while true
do
  Test_Button_B
  if [ "$?" -ne "10" ]; then
    LastClientIP="$(tail -1 /var/lib/misc/dnsmasq.leases | awk -F ' ' '{print $3}')"
    if [ ! -z "$LastClientIP" ]; then
      LastClientName="$(tail -1 /var/lib/misc/dnsmasq.leases | awk -F ' ' '{print $4}')"

      sudo ping -c 1 -W 5 $LastClientIP > /dev/null

      if [ $? -eq 0 ]; then

        roms2="$(sshpass -p "ark" ssh -o StrictHostKeyChecking=no -l ark $LastClientIP "lsblk | grep roms2")"

        if [ -z "$roms2" ]; then
          DIR="roms"
        elif [ ! -z "$roms2" ]; then
          if [[ "$roms2" == *"roms2"* ]]; then
            DIR="roms2"
          else
            sleep 5
            sshpass -p "ark" ssh -o StrictHostKeyChecking=no -l ark $LastClientIP "lsblk | grep roms2"
            if [ -z "$roms2" ]; then
              DIR="roms"
            else
              DIR="roms2"
            fi
          fi
        fi

        IFS=$'\n'    ## set IFS to break on newline
        game_array=( $(ls "${game%.*}".*) ) ## get list of game files that start with this game name in case it is multiple files like cd games
        IFS="$old_ifs"  ## restore original IFS

        for g in "${game_array[@]}"
        do
          Dest="$(echo $g | sed "/$(echo $g |  awk -F '/' '{print $2}')/s//$DIR/")"
          echo "${emulator}" > /dev/shm/gameshare.info
          echo "${core}" >> /dev/shm/gameshare.info
          echo "${Dest}" >> /dev/shm/gameshare.info
          sshpass -p "ark" rsync -P -r -v --progress -e ssh "$g" ark@"$LastClientIP":"\"$Dest\"" | \
          stdbuf -i0 -o0 -e0 tr '\r' '\n' | stdbuf -i0 -o0 -e0  awk -W interactive '/^ / { print int(+$2) ; fflush() ;  next } $0 { print "# " $0  }' | \
          dialog --title "Sharing" --gauge "Copying $(echo $g | awk -F '/' '{print $NF}') to $LastClientName ($LastClientIP)\n\nPlease Wait..." $height $width 2>&1 > /dev/tty0
          sshpass -p "ark" rsync -P -r -v --progress -e ssh "/dev/shm/gameshare.info" ark@"$LastClientIP":"/dev/shm/gameshare.info" | \
          stdbuf -i0 -o0 -e0 tr '\r' '\n' | stdbuf -i0 -o0 -e0  awk -W interactive '/^ / { print int(+$2) ; fflush() ;  next } $0 { print "# " $0  }' | \
          dialog --title "Sharing" --gauge "Copying gameshare.info to $LastClientName ($LastClientIP)\n\nPlease Wait..." $height $width 2>&1 > /dev/tty0
        done
        rm -f /dev/shm/gameshare.info
        if [ $? -eq 0 ]; then
          dialog --infobox "\nTransfer of ${game%.*} to $LastClientName ($LastClientIP) has completed successfully" 6 $width 2>&1 > /dev/tty0
          sleep 5
        else
          dialog --infobox "\nTransfer of ${game%.*} to $LastClientName ($LastClientIP) has failed" 6 $width 2>&1 > /dev/tty0
          sleep 5
        fi
      else
        dialog --infobox "\nCouldn't connect to $LastClientName at IP: $LastClientIP" 6 $width 2>&1 > /dev/tty0
        sleep 3
      fi
      break
    fi
  else
   break
  fi
done
}

GameShare() {

  if [[ ! -z $AP_Support ]]; then
    local gameshareoptions=( 2 "Receive game from Host" 3 "Go Back" )
  else
    local gameshareoptions=( 1 "Share current game to Client" 2 "Receive game from Host" 3 "Go Back" )
  fi

  while true; do
    gameshareselection=(dialog \
    --backtitle "Game Share Mode: Connected to: $(iw dev wlan0 info | grep ssid | cut -c 7-30)" \
    --title "[ Game Share Menu: Receive Game from Host mode: $(systemctl is-active ssh) ]" \
    --no-collapse \
    --clear \
    --cancel-label "Select + Start to Exit" \
    --menu "What do you want to do?" $height $width 15)

    gamesharechoices=$("${gameshareselection[@]}" "${gameshareoptions[@]}" 2>&1 > /dev/tty0) || TopLevel

    for choice in $gamesharechoices; do
      case $choice in
        1)ShareCurrentGame
          GameShare
        ;;
        2)sudo systemctl start ssh &
          Select ArkOS_AP
          if [ "$success" ]; then
            success=""
            systemctl is-active --quiet ssh.service
            if [ "$?" -ne "3" ]; then
              sudo systemctl start ssh &
              SSH_ON="On"
            fi
            #dialog --infobox "\nReady to receive game file now" 6 $width 2>&1 > /dev/tty0
            dialog --infobox "Waiting for transfer to complete then start the netplay session with the game...\nPress and hold B to stop waiting and cancel receiving game file" 6 $width 2>&1 > /dev/tty0
            . /usr/local/bin/buttonmon.sh
            while true
            do
              Test_Button_B
              if [ "$?" -ne "10" ] && [ -f /dev/shm/gameshare.info ]; then
                emulator="$(sed '1q;d' /dev/shm/gameshare.info)"
                core="$(sed '2q;d' /dev/shm/gameshare.info)"
                game="$(sed '3q;d' /dev/shm/gameshare.info)"
                if [ ! -z "$SSH_ON" ]; then
                  sudo systemctl stop ssh &
                fi
                Client "gameshare"
                Test_Button_B
                if [ "$?" -ne "10" ]; then
                  dialog --clear 2>&1 > /dev/tty0
                  printf "\033c" > /dev/tty0
                  /opt/retroarch/bin/${emulator} -c /home/ark/.config/${emulator}/retroarch.cfg --connect=192.168.1.1 --nick=ArkOS_Client_"${core}"_Session_"$(cat /sys/class/net/wlan0/address | awk -F':' '{ print $4$5$6}')" -L /home/ark/.config/${emulator}/cores/${core}_libretro.so "$game"
                  rm -f /dev/shm/gameshare.info
                  ExitCode="231"
                  ExitMenu
                else
                  samegame="N"
                  rm -f /dev/shm/gameshare.info
                  GameShare
                fi
              fi
            done
          else
            dialog --infobox "\nNot ready to receive game file now as Host could not be found" 6 $width 2>&1 > /dev/tty0
          fi
          sleep 3
          GameShare
        ;;
        3)if [ ! -z "$AP_ON" ]; then
            arkos_ap_mode.sh Disable
          fi
          if [ ! -z "$SSH_ON" ]; then
      	    sudo systemctl stop ssh
          fi
          MainMenu
        ;;
        esac
      done
    done
}

Settings() {
  if [[ ! -z $(cat /etc/hostapd/hostapd.conf | grep "hw_mode=a") ]]; then
    local curapmodecfg="Switch to 2.4Ghz AP Mode"
    local curapmode="5"
  else
    local curapmodecfg="Switch to 5Ghz AP Mode"
    local curapmode="2.4"
  fi


  if [[ -z $(iw list | grep "Band 2") ]]; then
    local settingsoptions=( 2 "Set less busy channel for AP Mode" 3 "Go Back" )
  else
    local settingsoptions=( 1 "$curapmodecfg" 2 "Set less busy channel for AP Mode" 3 "Go Back" )
  fi

  while true; do
    settingsselection=(dialog \
    --backtitle "NetPlay Session: Current AP Mode: ${curapmode}Ghz | CH: $(cat /etc/hostapd/hostapd.conf | grep -oP "(?<=channel=).*")" \
    --title "[ Settings Menu ]" \
    --no-collapse \
    --clear \
    --cancel-label "Select + Start to Exit" \
    --menu "What do you want to do?" $height $width 15)

  settingschoices=$("${settingsselection[@]}" "${settingsoptions[@]}" 2>&1 > /dev/tty0) || TopLevel

    for choice in $settingschoices; do
      case $choice in
        1) if [[ $curapmodecfg == "Switch to 2.4Ghz AP Mode" ]]; then
             sudo sed -i "/hw_mode\=/c\hw_mode\=g" /etc/hostapd/hostapd.conf
             dialog --infobox "\nSwitching to 2.4Ghz AP Mode..." 5 $width 2>&1 > /dev/tty0
             LessBusyChannel
             sudo sed -i "/channel\=/c\channel\=$BestChannel" /etc/hostapd/hostapd.conf
             systemctl is-active --quiet hostapd.service && sudo systemctl restart hostapd.service
             dialog --clear --backtitle "AP Mode has been set to 2.4Ghz" --title "[ Settings Menu ]" --clear --msgbox "\n\nAP Mode has been set to 2.4Ghz" $height $width 2>&1 > ${CUR_TTY}
           else
             sudo sed -i "/hw_mode\=/c\hw_mode\=a" /etc/hostapd/hostapd.conf
             dialog --infobox "\nSwitching to 5Ghz AP Mode..." 5 $width 2>&1 > /dev/tty0
             LessBusyChannel
             sudo sed -i "/channel\=/c\channel\=$BestChannel" /etc/hostapd/hostapd.conf
             systemctl is-active --quiet hostapd.service && sudo systemctl restart hostapd.service
             dialog --clear --backtitle "AP Mode has been set to 5Ghz" --title "[ Settings Menu ]" --clear --msgbox "\n\nAP Mode has been set to 5Ghz" $height $width 2>&1 > ${CUR_TTY}
           fi
           Settings
        ;;
        2)dialog --infobox "\nFinding a less busy wireless channel in your current area..." 5 $width 2>&1 > /dev/tty0
          LessBusyChannel
          sudo sed -i "/channel\=/c\channel\=$BestChannel" /etc/hostapd/hostapd.conf
          dialog --infobox "\nAP Mode channel has now been set to $BestChannel" 5 $width 2>&1 > /dev/tty0
          sleep 3
          Settings
        ;;
        3) MainMenu
        ;;
        esac
      done
    done
}

MainMenu() {
  if [[ -z $AP_Support ]]; then
    mainoptions=( 1 "Host a local Netplay Session" 2 "Connect to a local Netplay Session" 3 "Game Share Mode" 4 "Start without NetPlay" 5 "Settings" 6 "Exit" )
  else
    mainoptions=( 2 "Connect to a local Netplay Session" 3 "Game Share Mode" 4 "Start without NetPlay" 5 "Settings" 6 "Exit" )
  fi
  IFS="$old_ifs"
  while true; do
    mainselection=(dialog \
   	--backtitle "Netplay Session: $core" \
   	--title "Main Menu" \
   	--no-collapse \
   	--clear \
	--cancel-label "Select + Start to Exit" \
	--menu "Please make your selection" $height $width 15)

	mainchoices=$("${mainselection[@]}" "${mainoptions[@]}" 2>&1 > /dev/tty0)

    for mchoice in $mainchoices; do
      case $mchoice in
	1) Host ;;
	2) Client ;;
	3) GameShare ;;
	4) ExitCode="230"
	   ExitMenu ;;
	5) Settings ;;
	6) ExitMenu ;;
      esac
    done
  done
}

#
# Joystick controls
#
# only one instance

sudo chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
if [[ ! -z $(pgrep -f gptokeyb) ]]; then
  pgrep -f gptokeyb | sudo xargs kill -9
fi
/opt/inttools/gptokeyb -1 "netplay.sh" -c "/opt/inttools/keys.gptk" &
printf "\033c" > /dev/tty0
dialog --clear

if [[ -z $(ifconfig | grep wlan0 | tr -d '\0') ]]; then
  dialog --infobox "\nYou currently do not have a compatible wireless adapter connected or enabled.  Exiting..." 5 $width 2>&1 > /dev/tty0
  sleep 5
  ExitCode="0"
  ExitMenu
fi

if [[ -z $(iw list | grep "* AP" | tr -d '\0') ]]; then
  AP_Support="No"
fi

core="$1"
game="$2"
emulator="$3"

if [[ -z $(iw list | grep "Band 2") ]]; then
  if [[ ! -z $(cat /etc/hostapd/hostapd.conf | grep "hw_mode=a") ]]; then
    sudo sed -i "/hw_mode\=/c\hw_mode\=g" /etc/hostapd/hostapd.conf
    sudo sed -i "/channel\=/c\channel\=6" /etc/hostapd/hostapd.conf
  fi
fi

MainMenu
