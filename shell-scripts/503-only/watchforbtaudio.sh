#!/bin/bash

# create a temporary named pipe to communicate with bluealsa-cli monitor
FIFO_PATH=$(mktemp -u)
mkfifo $FIFO_PATH
# attach it to unused file descriptor FIFO_FD
exec {FIFO_FD}<>$FIFO_PATH
# unlink the named pipe
rm $FIFO_PATH

# make sure the pipeline is shut down if this script interrupted
trap "kill %1; exec {FIFO_FD}>&-; ln -sf /dev/null ~/.asoundrc-default; exit 0" INT TERM

# start bluealsa-cli monitor in background
bluealsa-cli --quiet monitor >&$FIFO_FD &

if [ ! -f "/home/ark/.kodi/userdata/advancedsettings.xml.bak" ];then
  cp -f /home/ark/.kodi/userdata/advancedsettings.xml /home/ark/.kodi/userdata/advancedsettings.xml.bak
fi

until false; do
	if [[ $(bluealsa-cli --quiet list-pcms | grep -Ec '/a2dp(src|sink)/sink$') -gt 0 ]] ; then
		cp -f ~/.asoundrcbt ~/.asoundrc
		sudo systemctl restart oga_events
		if test -z "$(cat /home/ark/.kodi/userdata/advancedsettings.xml | grep "<audiooutput>" | tr -d '\0')"
		then
		  sed -i '/<advancedsettings>/s//<advancedsettings>\n        <audiooutput>\n                <audiodevice>ALSA:default<\/audiodevice>\n        <\/audiooutput>/' /home/ark/.kodi/userdata/advancedsettings.xml
		elif test -z "$(cat /home/ark/.kodi/userdata/advancedsettings.xml | grep "<audiodevice>" | tr -d '\0')"
                then
		  sed -i '/<audiooutput>/s//<audiooutput>\n                <audiodevice>ALSA:default<\/audiodevice>/' /home/ark/.kodi/userdata/advancedsettings.xml
		else
		  sed -i '/<audiodevice>/c\                <audiodevice>ALSA:default<\/audiodevice>' /home/ark/.kodi/userdata/advancedsettings.xml
		fi
	else
		cp -f ~/.asoundrcbak ~/.asoundrc
		sudo systemctl restart oga_events
		sed -i '/<audiodevice>/c\                <audiodevice><\/audiodevice>' /home/ark/.kodi/userdata/advancedsettings.xml
	fi
	read
done <&$FIFO_FD
