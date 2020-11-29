"""
    STATUS: WORKING.
    Execution:
        python webcam_redirect.py | ffmpeg -f rawvideo -pixel_format bgr24 -video_size 640x480 -i - -vf format=yuv420p -f v4l2 /dev/video2

    Fake-Stream FPS: 17
    Original FPS: 17
"""
import cv2
import subprocess as sp
import sys

cap = cv2.VideoCapture(0)

cv2.namedWindow('result', cv2.WINDOW_AUTOSIZE)

while True:
    ret, frame = cap.read()

    # To display stream in a separate window:
    # cv2.imshow('result', frame)

    sys.stdout.buffer.write(frame.tostring())

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
