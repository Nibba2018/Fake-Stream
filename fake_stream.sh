#!/bin/bash

#Specify Color Schemes
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
BLINK='\033[5m'
UNDERLINE='\033[4m'

# function to start fake stream
startstream()
{
      echo -e "${GREEN}${BOLD}[+] Playing $VIDEO On The Stream Pointed By $WEBCAM"
      ffmpeg -stream_loop -1 -re -i /tmp/video -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 $WEBCAM
}

banner()
{

	#Just Some Cool ASCII ART
	echo -e """ ${GREEN}${BOLD}
	  █████▒▄▄▄       ██ ▄█▀▓█████      ██████ ▄▄▄█████▓ ██▀███  ▓█████ ▄▄▄       ███▄ ▄███▓
	▓██   ▒▒████▄     ██▄█▒ ▓█   ▀    ▒██    ▒ ▓  ██▒ ▓▒▓██ ▒ ██▒▓█   ▀▒████▄    ▓██▒▀█▀ ██▒
	▒████ ░▒██  ▀█▄  ▓███▄░ ▒███      ░ ▓██▄   ▒ ▓██░ ▒░▓██ ░▄█ ▒▒███  ▒██  ▀█▄  ▓██    ▓██░
	░▓█▒  ░░██▄▄▄▄██ ▓██ █▄ ▒▓█  ▄      ▒   ██▒░ ▓██▓ ░ ▒██▀▀█▄  ▒▓█  ▄░██▄▄▄▄██ ▒██    ▒██ 
	░▒█░    ▓█   ▓██▒▒██▒ █▄░▒████▒   ▒██████▒▒  ▒██▒ ░ ░██▓ ▒██▒░▒████▒▓█   ▓██▒▒██▒   ░██▒
	 ▒ ░    ▒▒   ▓▒█░▒ ▒▒ ▓▒░░ ▒░ ░   ▒ ▒▓▒ ▒ ░  ▒ ░░   ░ ▒▓ ░▒▓░░░ ▒░ ░▒▒   ▓▒█░░ ▒░   ░  ░
	 ░       ▒   ▒▒ ░░ ░▒ ▒░ ░ ░  ░   ░ ░▒  ░ ░    ░      ░▒ ░ ▒░ ░ ░  ░ ▒   ▒▒ ░░  ░      ░
	 ░ ░     ░   ▒   ░ ░░ ░    ░      ░  ░  ░    ░        ░░   ░    ░    ░   ▒   ░      ░   
	             ░  ░░  ░      ░  ░         ░              ░        ░  ░     ░  ░       ░   
	${NONE}"""                                                                                      

}


cleanup()
{
	clear
	#Display Banner
	banner
	rm -f /tmp/video	
	if [[ $# -eq 0 ]] ; then
	    echo -e "${RED}${BOLD}No argument supplied${NONE}"
	    exit 1;
	fi

}

# Initial Cleanup
cleanup $@


# Probing Kernel Modules
if ! sudo modprobe v4l2loopback exclusive_caps=1; then
   echo -e "${RED}[-] Unable to probe kernel module.${NONE}"
   exit ;
fi

VIDEO="$@"
ln -s $VIDEO /tmp/video

echo -e "${CYAN}[+] Available Video Devices : "

WEBCAMS=$(ls -1 /dev/video*)
echo -e "${PURPLE}$WEBCAMS${NONE}"

read -p "[+] Choose Webcam ID (last digit) : " ID
WEBCAM=$(grep $ID <<< $WEBCAMS)

while [ true ]; do
   read -t 1 -n 1
   if [ $? = 0 ] ; then
      # cleanup
      sudo modprobe -r v4l2loopback
      exit ;
   else
		startstream
   fi
done
