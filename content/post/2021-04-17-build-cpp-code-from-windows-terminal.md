---
layout: post
title: Building C++ code from command line on Windows
comments: true
slug: build-cpp-code-from-windows-terminal
date: "2021-04-17"
tags: [c++, windows]
---

After many years of working exclusively in Unix environments, Windows experience appears daunting, in particular when it comes doing stuff in terminal. I have heard a lot of about the power of PowerShell, but I have never had enough motivation to explore it --- I sticked to the familar Bash on Mac and Linux for most of my work. However, I was always interested in mastering the task of building C++ code using the native compiler on Windows (Visual C++) without using any GUI tools. 

Most of the tutorials on the Web, though, always describe the workflow based on CMake GUI as the first step to generate a Visual Studio project, and then using the Visual Studio itself to build the targets. Purely command line approach seemed very arcane to me. In this post, I would like to systematize some of the knowledge I gained while exploring terminal-based capabilities of Visual C++ and the associated workflow on a Windows machine. 

The official "entry point" to being able to use Visual Studio's command line tools is to launch the corresponding shortcut from the start menu:

```
Start -> 
    Programs -> 
        Visual Studio 2019 -> 
            Visual Studio Tools -> 
                x64 Native Tools Command Prompt for VS 2019
```

It will enable the good old `cmd.exe` with enabled set of the necessary environment variables and access to the compiler/linker executable `cl.exe` (see the [docs](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options) for more details). It can be further invoked as follows (imagine we are in the `build` directory, which is on the same level as `src` and `include`):

```cmd
cl ..\src\app.cpp ..\src\library.cpp /I ..\include
```

Here we are providing a list of source files to compile and link, along with the directory when headers are located (following the `/I` option). This example command will generate two object files per each C++ source (`app.obj`, `library.obj`), along with one executable (`app.exe`) corresponding to the source file containing the `main` entry point (`app.cpp`).

How to activate the compiler command prompt from a script rather than by pointing and clicking? If you look at the details of the mentioned start menu shortcut, it points to a batch script `vcvars64.bat` that does all the work setting up the environment. We can invoke this script from our own batch script as follows:

```bat
if not defined DevEnvDir (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)
```

The `if`-block, checking whether one of the required environment variables has been defined, is important in case your scipt is invoked more than once. 

When it comes to projects based on CMake, as I mentioned, the "default" way of generating build files is to use CMake GUI. However, it is totally possible to use a terminal/only approach. As a part of a Visual C++ distribution, one has access to [NMake](https://docs.microsoft.com/en-us/cpp/build/reference/nmake-reference), a utility similar to Unix's `make`. To generate makefiles for NMake, the following command is used:

```cmd
cmake .. -G "NMake Makefiles"
```

Further, the build process itself is initiated in this way:

```cmd
cmake --build . --target all --config Release
```



