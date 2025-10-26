---
layout: post
title: "Recognition of green apples using HSV color model and region-based image processing"
comments: true
math: true
slug: green-objects-hsv-erosion-dilation-connected-components
summary: "Demo of using OpenCV's RGB-to-HSV, erosion, dilation, and connected components detection to identify green apples in an image"
date: "2025-10-26"
tags: [opencv, computervision]
---
This blog post is an adapted version of a Jupyter notebook I used for teaching at NTNU some years ago. It demonstrates using the [HSV color model](https://en.wikipedia.org/wiki/HSL_and_HSV) for recognition of objects in an image (in this case, green apples on a table). Additionally, it shows an application of some basic region-based image processing techniques (erosion, dilation, and detection of connected components) to facilitate a better segmentation.

We start by importing some modules for data representation, processing and visualization. Then we define some helper functions:


```python
import cv2
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


def open_image(fname, read_flag=cv2.IMREAD_ANYCOLOR, color_transform=None):

    im = cv2.imread(fname, read_flag)
    if color_transform is None:
        return im

    return cv2.cvtColor(im, color_transform)


def show_single_image(im):
    _, ax = plt.subplots()
    ax.imshow(im)
    ax.axis('off')
    plt.show()


def show_channels(im, channel_names, cmaps):
    fig, axes = plt.subplots(1, im.shape[2])

    for ch, (ax, cmap, channel_name) in enumerate(zip(axes, cmaps, channel_names)):
        ax.imshow(im[:, :, ch], cmap=cmap, vmin=0, vmax=255)
        ax.axis('off')
        ax.set_title(f'{channel_name}')
```

We open the image with five green apples on a wooden table:


```python
im_apples = open_image('apples_top.jpg', cv2.IMREAD_COLOR, cv2.COLOR_BGR2RGB)
show_single_image(im_apples)
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_1.png)
    


The most basic way to look at the data of this color image is by separating the three color channels, namely **R**ed, **G**reen, and **B**lue:


```python
black_red = LinearSegmentedColormap.from_list('black_red', ['black', 'red'])
black_green = LinearSegmentedColormap.from_list('black_green', ['black', 'green'])
black_blue = LinearSegmentedColormap.from_list('black_blue', ['black', 'blue'])

show_channels(im_apples, channel_names='RGB', cmaps=(black_red, black_green, black_blue))
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_2.png)
    


From the visualization above, one can notice that the green channel is potentially interesting for automatically detecting the apples, as they appear lighter (with higher value) in it.

Let's see if a simple thresholding of the green channel will work:


```python
def threshold_binary(im, t):
    _, im_t = cv2.threshold(im, t, 255, cv2.THRESH_BINARY)
    return im_t


im_apples_green = im_apples[:, :, 1]
green_mask_from_rgb = threshold_binary(im_apples_green, 200)

show_single_image(green_mask_from_rgb)
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_3.png)
    


As you can see, the more illuminated parts of the apples are indeed segmentable using this simple method. However, the masked regions don't cover the apples entirely, as well as a lot of noise is picked up on the table surface.

Let's do better by transforming the image from RGB to HSV, with the channels of **H**ue, **S**aturation, and **V**alue. The neat property of HSV is that the hue channel represents the color irrespective of the illumination, so e.g. lighter greens and darker greens will result in a similar hue. This can clearly be seen with our image:


```python
im_hsv = cv2.cvtColor(im_apples, cv2.COLOR_RGB2HSV)

show_channels(im_hsv, channel_names='HSV', cmaps=('hsv', 'viridis', 'viridis'))
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_4.png)
    


When plotting the histogram of the hue values in the image under consideration, the region between 35 and 75 seems to be what we are looking for:


```python
green_from = 35
green_to = 75

_, ax = plt.subplots()
ax.hist(im_hsv[:, :, 0].ravel(), bins=100)
ax.axvline(green_from, color='tab:green')
ax.axvline(green_to, color='tab:green')
plt.show()
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_5.png)
    


Let's now threshold the hue channel to include pixels within the region defined above:


```python
def mask_threshold_range(im, thresh_min, thresh_max):
    binary_output = (im >= thresh_min) & (im < thresh_max)
    return np.uint8(binary_output)

green_mask_from_hsv = mask_threshold_range(im_hsv[:, :, 0], green_from, green_to)

show_single_image(green_mask_from_hsv)
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_6.png)
    


Now the segmentation is much more complete, and with less noise. 

To make the result even better, we can apply the following sequence of image processing operations:

  1. **Erosion**: removing boundary pixels of the objects (in our case, removing a lot of the remaining noise)
  2. **Dilation**: enlarging the existing objects (leading to the apples' regions getting closer to their original size)


```python
def erode(im, kernel_size, n_iter=1):
    kernel = np.ones((kernel_size, kernel_size), np.uint8)
    return cv2.erode(im, kernel, iterations=n_iter)


def dilate(im, kernel_size, n_iter=1):
    kernel = np.ones((kernel_size, kernel_size), np.uint8)
    return cv2.dilate(im, kernel, iterations=n_iter)


im_eroded = erode(green_mask_from_hsv, kernel_size=7)
im_dilated = dilate(im_eroded, kernel_size=11, n_iter=2)
```

Here is the visualization of the two steps above:


```python
_, (ax_eroded, ax_dilated) = plt.subplots(1, 2)
ax_eroded.imshow(im_eroded)
ax_eroded.axis('off')
ax_dilated.imshow(im_dilated)
ax_dilated.axis('off')
plt.show()
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_7.png)
    


The final binary image looks pretty good. Let's apply it as a mask given the original image:


```python
def apply_mask(im, mask):
    return cv2.bitwise_and(im, im, mask=mask)

im_masked = apply_mask(im_apples, im_dilated)

show_single_image(im_masked)
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_8.png)
    


At last, let's use the same binary image to detect the connected components in the image:


```python
def find_ccomp(im, *args, **kwargs):
    num, labels, stats, centroids = cv2.connectedComponentsWithStats(im, *args, **kwargs)
    
    stats_df = pd.DataFrame(stats, columns=['LeftX', 'TopY', 'Width', 'Height', 'Area'])
    stats_df['CenterX'] = centroids[:, 0]
    stats_df['CenterY'] = centroids[:, 1]
    
    return labels, stats_df


ccomp_labels, ccomp_stats = find_ccomp(im_dilated)

show_single_image(ccomp_labels)
```


    
![png](/green-objects-hsv-erosion-dilation-connected-components/figure_9.png)
    


The first connected component represents the background, while the rest, in our case, correspond to each individual apple:


```python
ccomp_stats
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>LeftX</th>
      <th>TopY</th>
      <th>Width</th>
      <th>Height</th>
      <th>Area</th>
      <th>CenterX</th>
      <th>CenterY</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0</td>
      <td>0</td>
      <td>1280</td>
      <td>945</td>
      <td>1010446</td>
      <td>646.502673</td>
      <td>466.151459</td>
    </tr>
    <tr>
      <th>1</th>
      <td>591</td>
      <td>184</td>
      <td>218</td>
      <td>206</td>
      <td>36198</td>
      <td>698.482651</td>
      <td>287.159070</td>
    </tr>
    <tr>
      <th>2</th>
      <td>159</td>
      <td>209</td>
      <td>230</td>
      <td>223</td>
      <td>41703</td>
      <td>272.268230</td>
      <td>318.972016</td>
    </tr>
    <tr>
      <th>3</th>
      <td>933</td>
      <td>484</td>
      <td>229</td>
      <td>212</td>
      <td>39383</td>
      <td>1047.201965</td>
      <td>589.960262</td>
    </tr>
    <tr>
      <th>4</th>
      <td>218</td>
      <td>506</td>
      <td>237</td>
      <td>225</td>
      <td>42742</td>
      <td>333.928408</td>
      <td>617.393150</td>
    </tr>
    <tr>
      <th>5</th>
      <td>610</td>
      <td>569</td>
      <td>221</td>
      <td>219</td>
      <td>39128</td>
      <td>718.931711</td>
      <td>679.580505</td>
    </tr>
  </tbody>
</table>
</div>



Some related resources:

[OpenCV: Eroding and Dilating](https://docs.opencv.org/3.4/db/df6/tutorial_erosion_dilatation.html)

[OpenCV Connected Component Labeling and Analysis](https://pyimagesearch.com/2021/02/22/opencv-connected-component-labeling-and-analysis)
