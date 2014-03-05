import cv2
import numpy as np

cap = cv2.VideoCapture(0)

while(True):
    # Capture frame-by-frame
    ret, frame = cap.read()

    # Our operations on the frame come here
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Display the resulting frame
    cv2.imshow('frame', frame)
    
    k=rawInput("press ket")
    print k
    


    capture = cvCreateCameraCapture(0);

    cvSetCaptureProperty( capture, CV_CAP_PROP_FRAME_WIDTH, 640 );

    cvSetCaptureProperty( capture, CV_CAP_PROP_FRAME_HEIGHT, 480 );


    videoFrame = cvQueryFrame(capture);



for x in range(2,10):
  for n in range(2,x):
    if x%n == 0:
      print x, "equals", n, "times", x/n
      break
  else:
    print x, "is a prime number"
    
def fib(n):
  a=0
  b=1
  while a<n:
    print a, 
    a=b
    b=a+b
    
def t1(a=5, b=10):
  print "a", a
  print "b", b
  