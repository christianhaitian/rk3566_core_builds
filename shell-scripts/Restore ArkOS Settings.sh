#!/bin/bash
clear

. /usr/local/bin/buttonmon.sh

if [ ! -f "/roms/backup/arkosbackup.tar.gz" ]; then
  printf "\nNo arkosbackup.tar.gz file was found in the"
  printf "\n/roms/backup folder.\n"
  printf "Please place the arkosbackup.tar.gz file there\n"
  printf "and try again."
  sleep 7
  printf "\033[0m"
  exit 1
fi

printf "\nAre you sure you want to restore a backup of your ArkOS settings?\n"
printf "\nPress A to continue.  Press B to exit.\n"
while true
do
    Test_Button_A
    if [ "$?" -eq "10" ]; then
		LOG_FILE="/roms/backup/lastarkosrestore.log"

		printf "\033[0mRestoring a backup.  Please wait...\n"
		sleep 2

		sudo chmod 666 /dev/tty1

		sudo tar --same-owner -zxhvf /roms/backup/arkosbackup.tar.gz -C / | tee -a "$LOG_FILE"
		if [ $? -eq 0 ]; then
			printf "\n\n\e[32mThe restore completed successfuly. \nYou will need to reboot your system in order for your restored settings to take effect! \n" | tee -a "$LOG_FILE"
			printf "\033[0m" | tee -a "$LOG_FILE"
			sleep 1
			printf "\nDo you want to delete the backup file?\n"
			printf "\nPress A to delete the backup then exit.  Press B to keep the backup then exit.\n"
			while true
			do
				Test_Button_A
				if [ "$?" -eq "10" ]; then
					sudo rm -fv /roms/backup/arkosbackup.tar.gz | tee -a "$LOG_FILE"
					sleep 1
					printf "\n The arkosbackup.tar.gz file has been deleted from the /roms/backup folder.  Exiting..."
					sleep 3
					exit 0
				fi

				Test_Button_B
				if [ "$?" -eq "10" ]; then
					printf "\n Exiting without deleting the arkosbackup.tar.gz file from the /roms/backup folder." | tee -a "$LOG_FILE"
					printf "\033[0m" | tee -a "$LOG_FILE"
					sleep 3
					exit 0
				fi
			done
		else
			printf "\n\n\e[31mThe restore did NOT complete successfully! \n\e[33mVerify a valid arkosbackup.tar.gz exist in \nyour easyroms/backup folder then try again.\n" | tee -a "$LOG_FILE"
			printf "\033[0m" | tee -a "$LOG_FILE"
			sleep 10
			exit 0
		fi
	fi

    Test_Button_B
    if [ "$?" -eq "10" ]; then
	  printf "\nExiting without restoring a backup."
	  sleep 1
      exit 0
	fi
done
