from time import clock as clock
tstart =  clock()
import cv2
import numpy as np

# from matplotlib import pyplot as plt
# import matplotlib.cm as cm

# ===========
# = Globals =
# ===========
cap = cv2.VideoCapture(0)

VIDEO_PARAM_NAMES = (
"CV_CAP_PROP_POS_MSEC",      # Current position of the video file in milliseconds.
"CV_CAP_PROP_POS_FRAMES",    # 0-based index of the frame to be decoded/captured next.
"CV_CAP_PROP_POS_AVI_RATIO", # Relative position of the video file: 0 - start of the film, 1 - end of the film.
"CV_CAP_PROP_FRAME_WIDTH",   # Width of the frames in the video stream.
"CV_CAP_PROP_FRAME_HEIGHT",  # Height of the frames in the video stream.
"CV_CAP_PROP_FPS",           # Frame rate.
"CV_CAP_PROP_FOURCC",        # 4-character code of codec.
"CV_CAP_PROP_FRAME_COUNT",   # Number of frames in the video file.
"CV_CAP_PROP_FORMAT",        # Format of the Mat objects returned by retrieve() .
"CV_CAP_PROP_MODE",          # Backend-specific value indicating the current capture mode.
"CV_CAP_PROP_BRIGHTNESS",    # Brightness of the image (only for cameras).
"CV_CAP_PROP_CONTRAST",      # Contrast of the image (only for cameras).
"CV_CAP_PROP_SATURATION",    # Saturation of the image (only for cameras).
"CV_CAP_PROP_HUE",           # Hue of the image (only for cameras).
"CV_CAP_PROP_GAIN",          # Gain of the image (only for cameras).
"CV_CAP_PROP_EXPOSURE",      # Exposure (only for cameras).
"CV_CAP_PROP_CONVERT_RGB",   # Boolean flags indicating whether images should be converted to RGB.
"CV_CAP_PROP_WHITE_BALANCE", # Currently unsupported
"CV_CAP_PROP_RECTIFICATION", # Rectification flag for stereo cameras (note: only supported by DC1394 v 2.x backend currently)
)

VIDEO_PARAMS = {}
for i,name in list(enumerate(VIDEO_PARAM_NAMES)): VIDEO_PARAMS[name] = i


# ===========
# = Methods =
# ===========
def initialize():
  set_res(544,288)
  
def snap():
  # capture an image
  ret, frame = cap.read()
  return frame

save_n = 0
def snap_and_save():
  for i in range(1,10):
    snap()
  global save_n
  print save_n
  f = snap()
  cv2.imwrite("../images/pic" + str(save_n) + ".jpg", f)
  save_n += 1
  
def set_res(w,h):
  cap.set(VIDEO_PARAMS["CV_CAP_PROP_FRAME_WIDTH"], w)
  cap.set(VIDEO_PARAMS["CV_CAP_PROP_FRAME_HEIGHT"], h)
  
def process(img):
  # process an image
  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
  ret, thresh = cv2.threshold(gray, 50, 255, cv2.THRESH_BINARY)
  thresh_inv = cv2.bitwise_not(thresh)
  canny = cv2.Canny(thresh, 100,200)
  return (img, gray, thresh, thresh_inv, canny)

def canny():
  can = process(snap())[-2]
  contours, hierarchy = cv2.findContours(can,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
  longest = None
  longest_len = 0
  for cont in contours:
    l = cv2.arcLength(cont,True)
    if l > longest_len:
      longest = cont
      longest_len = l
  hull = cv2.convexHull(longest) 
  approx = cv2.approxPolyDP(longest,0.01*cv2.arcLength(longest,True),True)
  rect = cv2.minAreaRect(longest)
  box = cv2.cv.BoxPoints(rect)
  box = np.int0(box)
  ellipse = cv2.fitEllipse(longest)
  print ellipse
  orig = snap()
  cv2.ellipse(orig,ellipse,(0,255,0),2)
  # cv2.drawContours(orig,[box],-1,(0,0,255),2)
  # cv2.drawContours(orig, [longest], -1, (0,0,255), 2)
  # cv2.drawContours(orig, [hull], -1, (0,255,0), 2)
  # cv2.drawContours(orig, [approx], -1, (255,0,0), 2)
  cv2.imshow("l", orig)
  raw_input("t")
  cv2.destroyAllWindows()
  
def canny2():
  can = process(snap())[-2]
  contours, hierarchy = cv2.findContours(can,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
  for cont in contours:
    orig = snap()
    cv2.drawContours(orig, [cont], -1, (0,255,0), 1)
    cv2.imshow("l", orig)
    raw_input("b")
    cv2.destroyAllWindows()
 
def display(imgs):
  # display imgs
  for i,img in tuple(enumerate(imgs)):
    cmap = cm.summer if i == 0 else cm.gray
  #   plt.subplot(1, len(imgs), i).imshow(img, cmap=cmap)
  # plt.show()

def spd():
  # cv2.destroyAllWindows()
  # plt.close()
  img = snap()
  imgs = process(img)
  display(imgs)

def sw():
  img = snap()
  
def hello(params):
  return {"params_i_got": params, "my_response": "Eyes on the world"}
  
initialize()


  
  
  