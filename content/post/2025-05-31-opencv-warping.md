---
layout: post
title: "OpenCV perspective warping: keystone effect and rotation around center"
comments: true
math: true
slug: opencv-warping
summary: "Two examples of performing perspective transformations with OpenCV using getPerspectiveTransform and warpPerspective"
date: "2025-05-31"
tags: [opencv, computervision, numpy, python]
---
In this blog post, I am going to show two examples of using OpenCV's functionality for **prespective warping** (`cv2.getPerspectiveTransform` and `cv2.warpPerspective`). We will apply perspective transformation to an image to (1) simulate a [keystone effect](https://en.wikipedia.org/wiki/Keystone_effect), i.e. a camera looking at an object from an angle, and (2) to simulate rotation of an object around its center (which will requre some additional rigid transformations). 

Let's start with the initial imports:


```python
import cv2
import numpy as np
import skimage
import itertools
from matplotlib import pyplot as plt

np.set_printoptions(formatter={"float_kind": "{: .3f}".format})
```

We are going to work with a synthetic image of a chessboard surrounded by a green background and a white rim:


```python
def create_base_image(w, h, rim, backgroud_color, top=50, left=100):

    im = np.ones((h, w, 3), dtype=np.uint8) * 255
    im[rim:h-rim, rim:w-rim] = backgroud_color
    cb = skimage.data.checkerboard()
    cb_w, cb_h = cb.shape

    for channel in range(3):
        im[top:top+cb_w, left:left+cb_h, channel] = cb

    return im
```

The image is 400 x 300 pixels, with the rim of 10 pixels on each side:


```python
w = 400
h = 300
rim = 10

im = create_base_image(w, h, rim, backgroud_color=(173, 255, 47))

plt.imshow(im, interpolation='none')
plt.show()
```


    
![png](/opencv-warping/figure_1.png)
    


[Perspective transformation](https://en.wikipedia.org/wiki/3D_projection#Perspective_projection) with OpenCV require a 3 by 3 matrix, which can be obtained from four `src` and four `dst` points (describing the same locations appearing in the original and the transformed image). 

For a keystone effect, we will select the cornes of the green rectangle as our `src` points, and a copy of those with the two top points moved closer together as `dst`.


```python
last_x_before_rim = w - rim - 1
last_y_before_rim = h - rim - 1

src = np.array([
    [rim, rim],
    [last_x_before_rim, rim],
    [last_x_before_rim, last_y_before_rim],
    [rim, last_y_before_rim]
], dtype=np.float32)

dst = np.array([
    [rim+30, rim],
    [last_x_before_rim-30, rim],
    [last_x_before_rim, last_y_before_rim],
    [rim, last_y_before_rim]
], dtype=np.float32)
```


```python
print(f'src =\n{src}')
print()
print(f'dst =\n{dst}')
```

    src =
    [[ 10.000  10.000]
     [ 389.000  10.000]
     [ 389.000  289.000]
     [ 10.000  289.000]]
    
    dst =
    [[ 40.000  10.000]
     [ 359.000  10.000]
     [ 389.000  289.000]
     [ 10.000  289.000]]


In the visualization below, the `src` points are shown as larger pink dots, while the transformed ones (`dst`), sort of as seen from a different perspective, are the smaller cyan dots:


```python
plt.imshow(im, interpolation='none')
plt.scatter(src[:, 0], src[:, 1], color='deeppink', s=100)
plt.scatter(dst[:, 0], dst[:, 1], color='cyan', s=20)
plt.show()
```


    
![png](/opencv-warping/figure_2.png)
    


We then use `cv2.getPerspectiveTransform` to obtain the transformation matrix:


```python
M = cv2.getPerspectiveTransform(src, dst)
print(f'M =\n{M}')
```

    M =
    [[ 0.837 -0.113  32.531]
     [-0.000  0.831  1.631]
     [ 0.000 -0.001  1.000]]


Having the matrix at hand, we pass it over to `cv2.warpPerspective`, together with the original image, the desired new image size, and the interpolation method to get the transformed version:


```python
im_warped = cv2.warpPerspective(im, M, (w, h), flags=cv2.INTER_LINEAR)

_, (ax_original, ax_warped) = plt.subplots(1, 2)
ax_original.imshow(im, interpolation='none')
ax_warped.imshow(im_warped, interpolation='none')
plt.show()
```


    
![png](/opencv-warping/figure_3.png)
    


For the second example, we would like to get an image rotated around the center of our green object. We start with some points around the origin (top left corner):


```python
src_at_origin = np.array([[-2, -1], [2, -1], [2, 1], [-2, 1]], dtype=np.float32)
```

However, the goal is not to rotate around the origin, but rather around the center of the object. We will use some homogeneous transformations for that, and will start with defining the helper functions:


```python
def rotation_matrix(theta):

    c = np.cos(theta)
    s = np.sin(theta)

    return np.array([[c, -s], [s, c]])


def create_transform(t_x, t_y, theta):

    translation = np.array([t_x, t_y])
    rotation = rotation_matrix(theta)

    transform = np.eye(3, dtype=float)
    transform[:2, :2] = rotation
    transform[:2, 2] = translation

    return transform


def transform_points(transform, points):

    n_points, dim = points.shape

    x = np.ones((dim + 1, n_points))
    x[:dim, :] = points.T

    transformed = transform @ x
    normalized = transformed[:dim, :] / transformed[-1, :]

    return np.array(normalized.T, dtype=np.float32)
```

Let's define two tranformations:

 - `T_obj` transforms the origin frame to the center of the green object;
 - `T_rot` rotates a coordinate frame by a small angle, 0.2 radians to be exact.


```python
T_obj = create_transform(w / 2, h / 2, 0)
T_rot = create_transform(0, 0, 0.2)

print(f'T_obj =\n{T_obj}')
print()
print(f'T_rot =\n{T_rot}')
```

    T_obj =
    [[ 1.000 -0.000  200.000]
     [ 0.000  1.000  150.000]
     [ 0.000  0.000  1.000]]
    
    T_rot =
    [[ 0.980 -0.199  0.000]
     [ 0.199  0.980  0.000]
     [ 0.000  0.000  1.000]]


As the source points, we will move the points around the origin to be around the center (`T_obj`). For the destination points, we will apply `T_obj` first, followed by rotation `T_rot`, which is equivalent to the matrix multiplication `T_obj @ T_rot`:


```python
src_at_center = transform_points(T_obj, src_at_origin)
dst_at_center = transform_points(T_obj @ T_rot, src_at_origin)

M_rot = cv2.getPerspectiveTransform(src_at_center, dst_at_center)
im_rotated = cv2.warpPerspective(im, M_rot, (w, h), flags=cv2.INTER_LINEAR)

_, (ax_original, ax_warped) = plt.subplots(1, 2)
ax_original.imshow(im, interpolation="none")
ax_warped.imshow(im_rotated, interpolation="none")
plt.show()
```


    
![png](/opencv-warping/figure_4.png)
    


Below is a visualization of the pairs of source and destiation points used in the rotation example:


```python
_, ax = plt.subplots()
ax.axis("equal")
ax.invert_yaxis()
ax.scatter(src_at_center[:, 0], src_at_center[:, 1], color='blue')
ax.scatter(dst_at_center[:, 0], dst_at_center[:, 1], color='orange')
ax.axhline(h / 2, color='gray', linestyle='--')
ax.axvline(w / 2, color='gray', linestyle='--')

for i, j in ((0, 1), (1, 2), (2, 3), (3, 0)):
    ax.plot([src_at_center[i, 0], src_at_center[j, 0]], 
            [src_at_center[i, 1], src_at_center[j, 1]], 
            color='blue', linewidth=1)
    
    ax.plot([dst_at_center[i, 0], dst_at_center[j, 0]],
            [dst_at_center[i, 1], dst_at_center[j, 1]], 
            color='orange', linewidth=1)

plt.show()
```


    
![png](/opencv-warping/figure_5.png)
    


Useful resources:

 - [OpenCV documentation on geometric transformations](https://docs.opencv.org/4.x/da/d54/group__imgproc__transform.html)
 - [Geometric Transformations of Images (an OpenCV + Python tutorial)](https://docs.opencv.org/4.x/da/d6e/tutorial_py_geometric_transformations.html)
