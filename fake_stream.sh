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

#Set Dimensions For Whiptail
declare -i L=10
declare -i W=30

#Global Variables
VIDEO_STREAM=""
VIDEO=""
SOURCE_FLAG=""

#Print Center Banner
center()
{
	local terminal_width=$(tput cols)     # query the Terminfo database: number of columns
	local text="${1:?}"                   # text to center
	local glyph="${2:-=}"                 # glyph to compose the border
	local padding="${3:-2}"               # spacing around the text

	local text_width=${#text}

	local border_width=$(( (terminal_width - (padding * 2) - text_width) / 2 ))

	local border=                         # shape of the border

	# create the border (left side or right side)
	for ((i=0; i<border_width; i++))
	do
		border+="${glyph}"
	done

	# a side of the border may be longer (e.g. the right border)
	if (( ( terminal_width - ( padding * 2 ) - text_width ) % 2 == 0 ))
	then
		# the left and right borders have the same width
		local left_border=$border
		local right_border=$left_border
	else
		# the right border has one more character than the left border
		# the text is aligned leftmost
		local left_border=$border
		local right_border="${border}${glyph}"
	fi

	# space between the text and borders
	local spacing=

	for ((i=0; i<$padding; i++))
	do
		spacing+=" "
	done

	# displays the text in the center of the screen, surrounded by borders.
	printf "${bcolor}${left_border}${spacing}${CYAN}${text}${NONE}${spacing}${right_border}\n"
}

help()
{
	echo -e """[$CYAN>$NONE] Usage: $GREEN./fake_stream.sh $NONE[OPTIONS]

OPTIONS :
-h, --help            Show This Menu
-s, --source          Stream Desktop
-v, --video$CYAN FILENAME$NONE  Path to Video/Image
"""
exit
}

streamvideo()
{
	ffmpeg -stream_loop -1 -re -i "$VIDEO" -vcodec rawvideo -threads 0 -f v4l2 $VIDEO_STREAM
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
	ffmpeg -f x11grab -r 15 -s 1280x720 -i :0.0+0,0 -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 $VIDEO_STREAM
}

#Check if command exists
check_command()
{
	if ! command -v $1 &> /dev/null
	then
    	echo -e "[$RED-$NONE] ${RED}$1${NONE} could not be found in$PURPLE PATH$NONE($CYAN$PATH$NONE)"
		exit
	else
		echo -e "[$GREEN+$NONE] ${GREEN}$1${NONE} was found in$PURPLE PATH$NONE"
	fi
}

parse_args()
{
	POSITIONAL=()
	while [[ $# -gt 0 ]]; do
	  key="$1"

	  case $key in
	    -v|--video)
	      vid="$2"
		  VIDEO=$(printf %q "$2")
	      shift # past argument
	      shift # past value
	      ;;
	    -s|--source)
	      SOURCE_FLAG=YES
	      shift # past argument
	      ;;
		-h|--help)
	      help
	      shift # past argument
	      ;;
	    *)    # unknown option
	      POSITIONAL+=("$1") # save it in an array for later
	      shift # past argument
	      ;;
	  esac
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters

	if [ -z "$VIDEO" ] && [ -z "$SOURCE_FLAG" ]
	then
		help
	fi

	if [[ -n "$VIDEO" ]] && [[ -n "$SOURCE_FLAG" ]]
	then
		echo -e "[$RED-$NONE] Both Flags Cannot Be Used Together!"
		help
	fi
}

init()
{
	#Show Banner
	center "Starting Fake Stream"

	#Check if program is being run as root
	if [[ $EUID -ne 0 ]]; then
		echo -e "[$RED-$NONE] This script must be run as ${RED}ROOT${NONE}!" 1>&2
		exit -1
	fi

	#Check if Command exists
	check_command ffmpeg

	# Probing Kernel Modules
	echo -e "[${YELLOW}~${NONE}] Trying To Probe ${CYAN}v4l2loopback${NONE}"
	if ! sudo modprobe v4l2loopback card_label="My Fake Webcam" exclusive_caps=1; then
		echo -e "[${RED}-${NONE}] Unable to probe ${RED}v4l2loopback${NONE} kernel module.${NONE}"
		exit ;
	fi

}

stream()
{
	#Executing Mode According To Flag
	if [[ -n "$VIDEO" ]]
	then
		echo -e "[$GREEN+$NONE] Streaming:$GREEN $VIDEO $NONE"
		center "Starting Stream"
		streamvideo
	else
		echo -e "[$GREEN+$NONE] Streaming Screen"
		center "Starting Stream"
		streamdesktop
	fi
}

# Exit Routine
exitgracefully()
{
	center "Cleaning Up"
	echo -e "[$RED-$NONE] Received$RED SIGINT$NONE"
	whiptail --msgbox "Hit Enter After Closing Video Device" $L $W 2>/dev/null
	echo -e "[$YELLOW~$NONE] Trying To Remove$CYAN v4l2loopback$NONE Kernel Module"
	out=$(modprobe -r v4l2loopback 2>&1 >/dev/null)
	if [[ ! -z "$out" ]];then
		echo -e "[$RED-$NONE] Your Video Stream Might Freeze As The Module Was Still In Use When Removed "
		echo -e "[$YELLOW~$NONE] Restarting Your Video Should Fix It!"
	fi
	echo -e "[$GREEN+$NONE] Clean Up Done!"
}

availablestreams()
{
	#declare variables
	declare -a streams=($(ls /dev/video*))
	declare -a choice
	declare -i size=${#streams[@]}

	#Create array for whiptail
	for stream in ${streams[@]}
	do
	choice=(${choice[@]} $stream $stream)
	done

	#Show Menu
	VIDEO_STREAM=$(whiptail --notags --title "Video Devices" --menu "Available Devices" $(( $L + 3 )) $(( $W + 7 )) $size ${choice[@]} 3>&1 1>&2 2>&3)
}

parse_args "$@"
init
availablestreams
echo -e "[$GREEN+$NONE] Using Device:$PURPLE $VIDEO_STREAM $NONE"
stream
