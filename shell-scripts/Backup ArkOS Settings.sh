#!/bin/bash
clear

. /usr/local/bin/buttonmon.sh

printf "\nAre you sure you want to create a backup of your ArkOS settings?\n"
printf "\nPress A to continue.  Press B to exit.\n"
while true
do
    Test_Button_A
    if [ "$?" -eq "10" ]; then
		LOG_FILE="/roms/backup/arkosbackup.log"
		printf "\033[0mCreating a backup.  Please wait...\n"
		sleep 2

		sudo chmod 666 /dev/tty1
		#tail -f $LOG_FILE >> /dev/tty1 &

		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo tar -zchvf /roms/backup/arkosbackup.tar.gz /home/ark/.config/panel_settings.txt /home/ark/.kodi/ /etc/localtime /etc/NetworkManager/system-connections /home/ark/.config/retroarch/retroarch.cfg /home/ark/.config/retroarch/config /home/ark/.config/retroarch/retroarch-core-options.cfg /home/ark/.config/retroarch32/retroarch.cfg /home/ark/.config/retroarch32/retroarch-core-options.cfg /home/ark/.config/retroarch32/config /home/ark/.emulationstation/collections /home/ark/.emulationstation/es_settings.cfg /opt/amiberry/savestates /opt/amiberry/whdboot /opt/mupen64plus/InputAutoCfg.ini /opt/drastic/config/drastic.cfg | tee -a "$LOG_FILE"
		else
		  sudo tar -zchvf /roms/backup/arkosbackup.tar.gz /home/ark/.kodi/ /etc/localtime /etc/NetworkManager/system-connections /home/ark/.config/retroarch/retroarch.cfg /home/ark/.config/retroarch/config /home/ark/.config/retroarch32/retroarch.cfg /home/ark/.config/retroarch32/config /home/ark/.emulationstation/collections /home/ark/.emulationstation/es_settings.cfg /opt/amiberry/savestates /opt/amiberry/whdboot /opt/mupen64plus/InputAutoCfg.ini /opt/drastic/config/drastic.cfg | tee -a "$LOG_FILE"
		fi

		if [ $? -eq 0 ]; then
		  if [ ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')" ]; then
			if [ ! -d "/roms2/backup/" ]; then
	          sudo mkdir -v /roms2/backup
			fi
			if [ -f "/roms2/backup/arkosbackup.tar.gz" ]; then
			  sudo rm /roms2/backup/arkosbackup.tar.gz
			fi
			sudo cp /roms/backup/arkosbackup.* /roms2/backup/.
		  fi
		  printf "\n\n\e[32mThe backup completed successfuly. \nYour settings backup is located in the backup folder on the easyroms partition and is named arkosbackup.tar.gz. \nKeep it somewhere safe! \n"  | tee -a "$LOG_FILE"
		  printf "\033[0m"  | tee -a "$LOG_FILE"
		  sleep 5
		else
		  printf "\n\n\e[31mThe backup did NOT complete successfully! \n\e[33mVerify you have at least 1GB of space available on your easyroms partition then try again.\n" | tee -a "$LOG_FILE"
		  printf "\033[0m" | tee -a "$LOG_FILE"
		  sleep 5
		fi
	    exit 0
	fi

    Test_Button_B
    if [ "$?" -eq "10" ]; then
	  printf "\nExiting without creating a backup."
	  sleep 1
      exit 0
	fi
done
