# Fake-Stream
Allows infinite streaming of a video as webcam output for different applications like Zoom, Skype etc.

## Setting up
* `pip install -r requirements.txt` -> Install dependencies
* `sudo apt-get install v4l2loopback-utils`
* `modprobe v4l2loopback devices=2` -> Create 2 webcam instance.
* `python fake_stream.py` -> Run fake stream.
* Choose a different video source from your respective video chat or stream app.