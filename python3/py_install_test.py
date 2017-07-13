import cv2

try:
    ver = cv2.__version__
    print("OpenCV installed successfully!")
    print("Version: %s" % ver)
