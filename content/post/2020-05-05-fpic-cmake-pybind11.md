---
layout: post
title: Position independent code
comments: true
slug: fpic-cmake-pybind11
date: "2020-05-05"
tags: [c++, programming, cmake, pybind11, python]
---

In this blog post, I am going to provide a short overview of the concept of position independent code and its specification in CMake, particularly in projects using pybind11.

Some time ago, when I was working on the [FxIS](https://github.com/semeniuta/FxIS) project, which was developed in C++ with the additional Python extension realized with pybind11, I encountered a linking error, which included a line similar to this: `/usr/bin/ld: libcore.a(sum.cpp.o): relocation R_X86_64_PC32 against symbol ... can not be used when making a shared object; recompile with -fPIC`. 

The linker option `-fPIC` turns out to signify position independent code, a type of executable format that is typically associated with shared libraries. It allows the machine code of certain operations to be located at any virtual address at runtime.

When doing compilation directly via GCC, position independent code is specified as follows

```bash
gcc -g -c -fPIC -Wall module1.c module2.c
gcc -g -shared -o libmylibrary.so module1.o module2.o
```

What I was building was in fact a static library, which was subsequently linked with the Python extension. However, because my project would not compile due to inclusion of a pydind11 module, I went on to figure out how to enable position independent code in my workflow (CMake). In short, the equivalent CMake specification of `-fPIC` option is done as follows:

```cmake
set_target_properties(mylibrary PROPERTIES POSITION_INDEPENDENT_CODE ON)
```

An example of a slightly stripped-down `CMakeLists.txt` file similar to my case is presented below:

```cmake
cmake_minimum_required(VERSION 3.1)

project(demo)

set(CMAKE_CXX_STANDARD 11)
include_directories("src")

add_subdirectory(pybind11)

file(GLOB SOURCES "src/*.cpp")

# Create static library "core" with position independent code
add_library(core STATIC ${SOURCES})
set_target_properties(core PROPERTIES POSITION_INDEPENDENT_CODE ON)

# Create a native executable
add_executable(app "app.cpp")
target_link_libraries(app core)

# Create Python extension
pybind11_add_module(pyext python_extension.cpp)
target_link_libraries(pyext PRIVATE core)
```

Interestingly, I got a linking error in such a case only on Linux. On macOS it was possible to define `core` in a regular way, and the whole build process turned out to be successful:

```cmake
add_library(core STATIC ${SOURCES})
# without:
# set_target_properties(core PROPERTIES POSITION_INDEPENDENT_CODE ON)
```

Read also:

 * [Position Independent Code (PIC) in shared libraries](https://eli.thegreenplace.net/2011/11/03/position-independent-code-pic-in-shared-libraries/)

 * [Position-independent code (Wikipedia)](https://en.wikipedia.org/wiki/Position-independent_code)

 * [Introduction to Position Independent Code (Gentoo Wiki)](https://wiki.gentoo.org/wiki/Hardened/Introduction_to_Position_Independent_Code)
