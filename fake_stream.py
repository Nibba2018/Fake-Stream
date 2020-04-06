import os

video_file = input("Enter Video Path:")

permission = os.system("chmod +x script.sh")
if permission:
    print("Permission not granted")

print("Enter password for creating fake Webcam instance")
os.system('sudo modprobe v4l2loopback')

webcams = os.popen('ls /dev/video*').read().split()

print("Webcam IDs Available:")
for webcam in webcams:
    print(webcam[-1])

print("Incase you see red a Warning, kindly rerun with a different webcam ID...\n")
print("Press q to quit or ctrl + c \n")
webcamID = input("Choose a webcam ID:")

print('Initiating fake stream...')
os.system(f'./script.sh {video_file} {webcams[webcamID]}')
input("Press Enter to exit...")