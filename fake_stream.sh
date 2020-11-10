if ! sudo modprobe v4l2loopback; then
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
	   ffmpeg -re -i $1 -map 0:v -f v4l2 $WEBCAM
   fi
done
