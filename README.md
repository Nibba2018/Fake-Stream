# Fake-Stream
Allows infinite streaming of a video as webcam output for different applications like Zoom, Skype etc.

**Winter of Code 2020:** [Project Ideas](https://github.com/dsc-iem/WoC-Project-Ideas#fake-stream)

## Setting up
* Dependencies:
  * v4l2loopback-utils/v4l2loopback-dkms
  * ffmpeg
* Installation:
  * Ubuntu/Debian based distros
    * `sudo apt-get install v4l2loopback-utils ffmpeg`
  * Manjaro/Arch based distros
    * `sudo pacman -S v4l2loopback-dkms ffmpeg linux-headers`
    * For linux headers, choose the one which corresponds to your linux kernel version. For e.g choose `linux58-headers` for kernel 5.8.* . Run `uname -a` to determine your kernel version.
* Running script:
  * `fake_stream.sh <path to video>`
  * Press `q` twice in quick succession to stop streaming.
* Testing:
  * `ffplay /dev/video<WebcamID you chose>`
  * [Webcam Tests](https://webcamtests.com/) can also be used.
*  Open Zoom or Skype and select a different video source.

Cheers!!