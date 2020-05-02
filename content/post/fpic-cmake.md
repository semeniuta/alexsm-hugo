---
layout: post
title: Position independent code
comments: true
slug: fpic-cmake
date: "2020-05-02"
tags: [c++, programming, cmake, pybind11]
---

In this blog post, I am going to provide a short overview of the concept of position independent code and its specification in CMake, particularly in projects using pybind11.

TODO Summary from the LPI book.

```cmake
# CMake example from the FxIS project

add_library(FxIS-core STATIC ${SRC_LIB} ${HEADERS})
set_target_properties(FxIS-core PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_link_libraries(FxIS-core ${OpenCV_LIBS} -lpthread)

add_library(FxIS-avt STATIC ${SRC_LIB_AVT} ${HEADERS_AVT})
set_target_properties(FxIS-avt PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_link_libraries(FxIS-avt FxIS-core VimbaCPP)

# ...

pybind11_add_module(fxisext pyfxis/fxisext.cpp)
target_link_libraries(fxisext PRIVATE FxIS-avt)
```

Read also:

[Position Independent Code (PIC) in shared libraries](https://eli.thegreenplace.net/2011/11/03/position-independent-code-pic-in-shared-libraries/)
