import sys
import cv2
import numpy as np

yuv = np.load(sys.argv[1])

#yuv = y_u_v.reshape(1080,1920,3)

png = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR)
cv2.imwrite(sys.argv[2], png)

