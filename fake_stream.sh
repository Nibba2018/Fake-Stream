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

help()
{
	echo """[+] Usage :
$0 [OPTIONS/FILENAME]

OPTIONS :
--source : Stream Desktop

FILENAME: Path to Video/Image
	"""
}
# function to start fake stream
streamvideo()
{
      echo -e "${GREEN}${BOLD}[+] Playing $VIDEO On The Stream Pointed By $WEBCAM"
      ffmpeg -stream_loop -1 -re -i /tmp/video -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 $WEBCAM
}

streamdesktop()
{
	echo -e "${GREEN}${BOLD}[+] Sharing Desktop On The Stream Pointed By $WEBCAM"	
	ffmpeg -f x11grab -r 15 -s 1280x720 -i :0.0+0,0 -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 $WEBCAM
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
	rm -f /tmp/video 2>/dev/null
	if [[ $# -eq 0 ]] ; then
	    echo -e "${RED}${BOLD}No argument supplied${NONE}"
	    help
	    exit 1;
	fi

}

# Initial Cleanup
cleanup $@

# Probing Kernel Modules
if ! sudo modprobe v4l2loopback card_label="My Fake Webcam" exclusive_caps=1; then
   echo -e "${RED}[-] Unable to probe kernel module.${NONE}"
   exit ;
fi

echo -e "${CYAN}[+] Available Video Devices : "

WEBCAMS=$(ls -1 /dev/video*)
echo -e "${PURPLE}$WEBCAMS${NONE}"

read -p "[+] Choose Webcam ID (last digit) : " ID
WEBCAM=$(grep $ID <<< $WEBCAMS)

VIDEO="$@"
PWD=$(pwd)/$VIDEO
echo $PWD
ln -s $PWD /tmp/video

while [ true ]; do
   read -t 1 -n 1
   if [ $? = 0 ] ; then
      # cleanup
      sudo modprobe --remove v4l2loopback
      exit ;
   elif [ "$VIDEO" = "--source" ]; then
   		streamdesktop
   else	
		streamvideo
   fi
done
