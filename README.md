# Fake-Stream
Allows infinite streaming of a video as webcam output for different applications like Zoom, Skype etc.

## Setting up
* Dependencies:
  * v4l2loopback-utils/v4l2loopback-dkms
  * ffmpeg
* Installation:
  * Ubuntu/Debian based distros
    * `sudo apt-get install v4l2loopback-utils ffmpeg`
  * Manjaro/Arch based distros
    * `sudo pacman -S v4l2loopback-dkms ffmpeg linux-headers`
    * For linux headers, choose the one which corresponds to your linux kernel version. For e.g choose `linu58-headers` for kernel 5.8.* . Run `uname -a` to determine your kernel version.
* Creating fake webcam instance & giving permission:
  * `sudo modprobe v4l2loopback`
  * `sudo chmod +x fake_stream.sh`
* Running script:
  * `fake_stream.sh <path to video>`
* Testing:
  * `ffplay /dev/video<WebcamID you chose>`
*  Open Zoom or Skype and select a different video source.

Cheers!!