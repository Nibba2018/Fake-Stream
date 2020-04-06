import time
import pyfakewebcam as fw
import cv2

if __name__ == "__main__":

    filename = input("Enter Video File path:")
    # Enter webcam ID accordingly:
    print("Initiating Webcam...")
    fake_cam = fw.FakeWebcam('/dev/video1', 640, 480)

    try:
        while True:
            cap = cv2.VideoCapture(filename)
            print("Playing Video...")
            while cap.isOpened():

                ret, frame = cap.read()

                if ret:
                    fake_cam.schedule_frame(frame)
                    time.sleep(1/30.0)

    except KeyboardInterrupt:
        print("Exiting....")
