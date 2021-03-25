#!/bin/bash

# Capture SIGINT and exit gracefully
trap exitgracefully SIGINT

#Specify Color Schemes
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
BLUE='\033[01;34m'
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
-h --help : Show This Menu 
--source  : Stream Desktop

FILENAME: Path to Video/Image
	"""
}


askYesNo()
{
        QUESTION=$1
        DEFAULT=$2
        if [ "$DEFAULT" = true ]; then
                OPTIONS="[Y/n]"
                DEFAULT="y"
            else
                OPTIONS="[y/N]"
                DEFAULT="n"
        fi
        read -p "$QUESTION $OPTIONS " -n 1 -s -r INPUT
        INPUT=${INPUT:-${DEFAULT}}
        echo ${INPUT}
        if [[ "$INPUT" =~ ^[yY]$ ]]; then
            ANSWER=true
        else
            ANSWER=false
        fi
}

# function to start fake stream
streamvideo()
{
      echo -e "${GREEN}${BOLD}[+] Playing $VIDEO On The Stream Pointed By $WEBCAM"
      ffmpeg -stream_loop -1 -re -i /tmp/video -vcodec rawvideo -threads 0 -f v4l2 $WEBCAM
      # ffmpeg : The program which would enable us to stream our video as the webcam feed
      # -stream_loop -1 : This dictates how many times the video should be looped. Assigning it the negative value of -1 makes it loop infinitely so that it keeps on playing till we close our program.
      # -re : This specifies the program to read input at native frame rate
      # -i : Specifies the input file name. It is followed by the path to the video file we want to stream
      # -vcodec : This specifies the video codec, aka the stream handling.
      # rawvideo : This tell ffmpeg to use the Raw video demuxer. This demuxer allows one to read raw video data.
      # -threads : The number of threads to be used. Usually setting it to 0 is considered be optimal.
      # -f : This flag is used force the format of input/output file. In our case, we are forcing output to v4l2 format
      # $WEBCAM : It specifies the functioning video devices as selected by the user.
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
	rm -f /tmp/video 2>/dev/null
	if [[ $# -eq 0 ]] ; then
	    echo -e "${RED}${BOLD}No argument supplied${NONE}"
	    help
	    exit 1;
	fi

}

exitgracefully()
{
	echo -e "${RED}${BOLD}[-] Received SIGINT"
	echo -e "${PURPLE}${BOLD}[+] Cleaning Up"
	while [ true ]; do
		echo -e "${CYAN}[-] Turn Off Video First !${NONE}${BOLD}"
		askYesNo "[-] Did You Turn Off Video ? " true
		DOIT=$ANSWER
		if [ "$DOIT" = true ]; then
		    out=$(sudo modprobe -r v4l2loopback 2>&1 >/dev/null)
		    if [[ ! -z "$out" ]];then
		    	echo -e "${BOLD}${YELLOW}[-] Your Video Stream Might Freeze As The Module Was Still In Use When Removed "
		    	echo -e "${BLUE}${BOLD}[+] Restarting Your Video Should Fix It !"
		    fi
		    rm -f /tmp/video
			echo -e "${GREEN}${BOLD}[+] Clean Up Done !"
			exit
		else
			echo -e "${BOLD}${RED}${UNDERLINE}[+] Turn Off Your Video Feed First !"
		fi
		
	done
}

# Initial Cleanup
cleanup $@

if [ "$@" = "-h" ]||[ "$@" = "--help" ]; then
 	help
 	exit
fi

# Probing Kernel Modules
if ! sudo modprobe v4l2loopback card_label="My Fake Webcam" exclusive_caps=1; then
   echo -e "${RED}[-] Unable to probe kernel module.${NONE}"
   exit ;
fi

# Clear Screen
clear

# Display Banner
banner

# Select Video Device
echo -e "${CYAN}[+] Available Video Devices : "
WEBCAMS=$(ls -1 /dev/video*)
echo -e "${PURPLE}$WEBCAMS${NONE}"
read -p "[+] Choose Webcam ID (last digit) : " ID
WEBCAM=$(grep $ID <<< $WEBCAMS)

# Created A Soft Link To The Video File
VIDEO="$@"
PWD=$(pwd)/$VIDEO
ln -s $PWD /tmp/video

while [ true ]; do
	if [ "$VIDEO" = "--source" ]; then
   		streamdesktop
   else	
		streamvideo
   fi
done
