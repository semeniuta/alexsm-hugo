---
layout: post
title: Serve images on the fly in a binary form with Flask
comments: true
slug: flask-serve-images-on-the-fly
date: "2021-05-01"
tags: [python, programming, flask, opencv, numpy]
---

In this post I am going to demonstrate how to serve images from a REST endpoint for a situation when the images are not stored as static files, but generated on the fly given some original form. This use case will be described with application of Flask, OpenCV and NumPy. 

A situation when this functionality is needed is when the original images are too large, and their downscaled representations are sometimes required, or when the original format of the images is too heavy to be served via a web service (like BMP). Of course, one solution may be to pre-process the images and serve the target files statically. However, in situations when it is expected to have just occasional requests for the downscaled/converted images, it can be a good idea to implement an on-the-fly handler. 

Let's imagine that we can identify a concrete image using a unique ID, and our REST endpoint has the follwing form:

```
http://<HOST>/image/<ID>
```

Further, let there be a Python function `get_image_path` that takes the `id` (originally supplied via a GET request) and returns the full path of where the image is stored locally. A simplified version of a Flask app realizing the required functionality is presented below (for simplicity, error handling such non-existent resource is omitted). Here, our goal is to read the original image, downscale it, and serve it in a binary form as a PNG image:

```python
import flask
import cv2


app = flask.Flask(__name__)


def get_image_path(id):
    # ... build the full path
    return image_path


@app.route('/image/<int:id>')
def serve_image(id):

    # Get the full image path
    image_path = get_image_path(id)

    # Read the original image
    im = cv2.imread(fname, cv2.IMREAD_ANYCOLOR)
    
    # Resize the image (here make it 9 times smaller)
    new_shape = (im.shape[1] // 3, im.shape[0] // 3)
    im_smaller = cv2.resize(im, new_shape)
    
    # Encode the resized image to PNG
    _, im_bytes_np = cv2.imencode('.png', im_smaller)
    
    # Constuct raw bytes string 
    bytes_str = im_bytes_np.tobytes()

    # Create response given the bytes
    response = flask.make_response(bytes_str)
    response.headers.set('Content-Type', 'image/png')
    
    return response
```

The pipeline here is as follows. The original color image is read as a NumPy array. It then undergoes a series of transformations (in our example, resizing). The changed image is then encoded in PNG format with [`cv2.imencode`](https://docs.opencv.org/3.4/d4/da8/group__imgcodecs.html#ga461f9ac09887e47797a54567df3b8b63). The result of the latter is `(1 x n)` NumPy array, which has to be further converted to raw bytes with NumPy's [`tobytes`](https://numpy.org/doc/stable/reference/generated/numpy.ndarray.tobytes.html) method. Finally, Flask's [`make_response`](https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response) function is used to construct an HTTP response with the image bytes. 

You may take a look at similar use cases with some alternative approaches at these StackOvervlow questions:
 
 - [Flask to return image stored in database](https://stackoverflow.com/questions/11017466/flask-to-return-image-stored-in-database)
 - [Encoding a Numpy Array Image to an Image type (.png etc.) to use it with the GCloud Vision API - without OpenCV](https://stackoverflow.com/questions/56564977/encoding-a-numpy-array-image-to-an-image-type-png-etc-to-use-it-with-the-gcl)



