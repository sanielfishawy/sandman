import cv2
import numpy as np
from matplotlib import pyplot as plt

img = cv2.imread('blobsm.jpg',0)
ret,thresh = cv2.threshold(img,50,255,0)
cv2.imshow("p", thresh)
cv2.destroyAllWindows()


contours,hierarchy = cv2.findContours(thresh, 1, 2)

cnt = contours[0]
x,y,w,h = cv2.boundingRect(img)
cv2.rectangle(img,(x,y),(x+w,y+h),(0,255,0),2)

rect = cv2.minAreaRect(cnt)
box = cv2.boxPoints(rect)
box = np.int0(box)
im = cv2.drawContours(im,[box],0,(0,0,255),2)

plt.subplot(121),plt.imshow(img,cmap = 'gray')
plt.show()
