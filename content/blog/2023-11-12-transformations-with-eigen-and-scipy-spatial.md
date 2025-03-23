---
layout: post
title: "Rotations and translations with Eigen and scipy.spatial"
comments: true
math: true
slug: transformations-with-eigen-and-scipy-spatial
summary: "Homogeneus transformations (rotation + translation), comparing Eigen (C++) and SciPy (Python); example with the roll-pitch-yaw (RPY) sequence of rotations"
date: "2023-11-12"
tags: [math, python, c++, numpy]
---

In this blog post I am going to demonstrate how homogeneus transformations are handled in C++ with Eigen and in Python with `scipy.spatial`. Let's start with the latter. 

The Scipy module `scipy.spatial.transform` provides a versatile collection of types to represent rotations in different forms. A widely used way of representing a rotation in 3D is roll-pitch-yaw (RPY) angles. [The convention of what RPY means may differ](https://petercorke.com/robotics/roll-pitch-yaw-angles/), depending on the discipline (like robotics or aerospace engineering), but one way of defining RPY is the following:

1. Rotate the coordinate frame around its X axis (yaw)
2. The, rotate the frame around its Y axis (pitch)
3. Finally, rotate the frame around its Z axis (roll)

This representaion is natural when we model e.g. a robot gripper, with the Z axis "sticking out" of it.

If you thing in terms of multiplication of rotation matrices, the sequence above can be described as such:

$$
R_{x}(yaw) R_{y}(pitch) R_{z}(roll)
$$


Let's model this sequence of rotations with NumPy + SciPy. First, import the libraries:


```python
import numpy as np
import scipy.spatial.transform as st

np.set_printoptions(precision=3)
```

We will play around with actual values for the angles: $yaw = \pi/4$, $pitch = \pi/3$, and $roll = -\pi/8$.


```python
angle_x = np.pi / 4
angle_y = np.pi / 3
angle_z = -np.pi / 8

input_angles = np.array([angle_x, angle_y, angle_z])
```

The sequence of X, then Y, then Z rotation [are technically Euler angles](https://robotacademy.net.au/lesson/rotation-angle-sequences-in-3d/). We construct a `Rotation` object using the `from_euler` initializer.


```python
R = st.Rotation.from_euler('XYZ', input_angles)
```

Take a notice that we specified the sequence of axes using capital letters. SciPy [interprets](https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.transform.Rotation.from_euler.html) such formatting as **intrinsic** rotations, i.e. the angles are considered with respect to the frame being rotated.

Let's now inspect the actual $SO(3)$ matrix corresponding to the rotation of interest:


```python
print(R.as_matrix())
```

    [[ 0.462  0.191  0.866]
     [ 0.295  0.888 -0.354]
     [-0.836  0.419  0.354]]


If a homogeneous trasnformation is of interest, when we combine rotation and translation, we can construct one directly using NumPy indexing:


```python
def create_transform(rotation, translation):

    transform = np.eye(4)
    transform[:3, :3] = rotation.as_matrix()
    transform[:3, 3] = translation

    return transform
```

An example is a transformation with the rotation above and translation of $[0.5, 0.4, 0.3]$:


```python
T = create_transform(R, np.array([0.5, 0.4, 0.3]))

print(T)
```

    [[ 0.462  0.191  0.866  0.5  ]
     [ 0.295  0.888 -0.354  0.4  ]
     [-0.836  0.419  0.354  0.3  ]
     [ 0.     0.     0.     1.   ]]


You may see that the original angles we used to construct the `Rotation` object match the Euler angles extracted from the obejct using `as_euler` method:


```python
print(input_angles)
print(R.as_euler('XYZ'))
```

    [ 0.785  1.047 -0.393]
    [ 0.785  1.047 -0.393]


Let's now play around with Eigen to create the same rotation, translation, and the homogeneous transformation. 

One of the supported way of specifying rotations in Eigen is **angle-axis**, where you provide an arbitrary axis vector to rotate around, together with an angle of rotation. To model the XYZ sequence, we can construct three rotation objects and then multiply them. We will start with helper functions constructing `Eigen::AngleAxisf` objects:

```c++
#include <Eigen/Dense>
#include <Eigen/Geometry>

Eigen::AngleAxisf rotate_x(float angle)
{
    return {angle, Eigen::Vector3f::UnitX()};
}

Eigen::AngleAxisf rotate_y(float angle)
{
    return {angle, Eigen::Vector3f::UnitY()};
}

Eigen::AngleAxisf rotate_z(float angle)
{
    return {angle, Eigen::Vector3f::UnitZ()};
}
```

For the actual example, we first construct a translation object:

```c++
Eigen::Translation<float, 3> t{0.5f, 0.4f, 0.3f};
```

To create the rotation object as in the Python example above, we use the previosly defined helper functions:

```c++
const float angle_x = M_PI / 4;
const float angle_y = M_PI / 3;
const float angle_z = -M_PI / 8;
const auto R = rotate_x(angle_x) * rotate_y(angle_y) * rotate_z(angle_z);
```

To get the transformation combining rotation and trasnlation, we perform multiplication corresponding to **first translating a coordinate frame, and then rotating it**:

```c++
const auto transform = t * R;
```

When we print the contents of the objecs above, we can see that the values are the same as in the Python example:

```c++
#include <iostream>

void print_array(const auto& arr, const char* prefix)
{
    std::cout << prefix << ":\n" << arr << "\n\n";
}
```

```c++
print_array(t.vector(), "Translation");
print_array(R.matrix(), "Rotation");
print_array(transform.matrix(), "Transformation");
```

The output:

```
Translation:
0.5
0.4
0.3

Rotation:
  0.46194  0.191342  0.866025
  0.29516  0.887626 -0.353553
-0.836356  0.418937  0.353553

Transformation:
  0.46194  0.191342  0.866025       0.5
  0.29516  0.887626 -0.353553       0.4
-0.836356  0.418937  0.353553       0.3
        0         0         0         1
```


See more Eigen examples in the [*Space Transformations* tutorial](https://eigen.tuxfamily.org/dox/group__TutorialGeometry.html).
