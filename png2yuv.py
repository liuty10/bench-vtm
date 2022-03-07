import sys
import cv2
import numpy as np

bin_file = open(sys.argv[2], "wb")

img = cv2.imread(sys.argv[1])
yuv = cv2.cvtColor(img, cv2.COLOR_BGR2YUV)
y, u, v = cv2.split(yuv)
y_u_v = np.array([y,u,v])

np.save(bin_file, np.array(y_u_v))
bin_file.close
