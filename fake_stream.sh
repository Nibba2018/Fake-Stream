#!/bin/bash

if ! sudo modprobe v4l2loopback exclusive_caps=1; then
   echo "Unable to probe kernel module."
   exit ;
fi

WEBCAMS=$(ls /dev/video*)
echo $WEBCAMS
read -p "Choose Webcam ID (last digit):" ID
WEBCAM=$(grep $ID <<< $WEBCAMS)

while [ true ]; do
   read -t 1 -n 1
   if [ $? = 0 ] ; then
      # cleanup
      sudo modprobe -r v4l2loopback
      exit ;
   else
      ffmpeg -stream_loop -1 -re -i $1 -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 -vf hflip -c:a copy $WEBCAM
   fi
done
