import numpy as np
import cv2
img = cv2.imread('tblsmall.jpg', 0)
cv2.namedWindow('image', cv2.WINDOW_NORMAL)
cv2.imshow('image',img)
a = raw_input("Please enter something...")
print "you entered", a
cv2.destroyAllWindows()