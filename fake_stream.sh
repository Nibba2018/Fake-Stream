INPUT=$1

WEBCAMS=$(ls /dev/video*)
echo $WEBCAMS
read -p "Choose Webcam ID (last digit):" ID
WEBCAM=$(grep $ID <<< $WEBCAMS)

while [ true ]; do
   read -t 1 -n 1
   if [ $? = 0 ] ; then
      exit ;
   else
	ffmpeg -re -i $INPUT -map 0:v -f v4l2 $WEBCAM
   fi
done
