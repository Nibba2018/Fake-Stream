INPUT=$1
DEVICE_VIDEO=$2

while [ true ]; do
   read -t 1 -n 1
   if [ $? = 0 ] ; then
      exit ;
   else
	ffmpeg -re -i $INPUT -map 0:v -f v4l2 $DEVICE_VIDEO
   fi
done