try:
    import cv2
    ver = cv2.__version__
    print("OpenCV installed successfully!")
    print("Version: %s" % ver)
except:
    print("OpenCV installation was not verified!")
    print("Please check output for errors.. :(")
