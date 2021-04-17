---
layout: post
title: Building C++ code from command line on Windows
comments: true
slug: build-cpp-code-from-windows-terminal
date: "2021-04-17"
tags: [c++, windows]
---

After many years of working exclusively in Unix environments, Windows experience appears daunting, in particular when it comes doing stuff in terminal. I have heard a lot of about the power of PowerShell, but I have never had enough motivation to explore it -- I sticked to the familar Bash on Mac and Linux for most of my work. However, I was always interested in mastering the task of building C++ code using the native compiler on Windows (Visual C++) without using any GUI tools. 

Most of the tutorials on the Web, though, always describe the workflow based on CMake GUI as the first step to generate a Visual Studio project, and then using the Visual Studio itself to build the targets. Purely command line approach seemed very arcane to me. In this post, I would like to systematize some of the knowledge I gained while exploring terminal-based capabilities of Visual C++ and the associated workflow on a Windows machine. 

The official "entry point" to being able to use Visual Studio's command line tools is to launch the corresponding shortcut from the start menu:

```
Start -> 
    Programs -> 
        Visual Studio 2019 -> 
            Visual Studio Tools -> 
                x64 Native Tools Command Prompt for VS 2019
```

TODO.



