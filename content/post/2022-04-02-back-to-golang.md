---
layout: post
title: "Looking again at Go: go.mod, go.sum, go.work, and VSCode config"
comments: true
slug: back-go-golang
date: "2022-04-02"
tags: [golang, programming, vscode]
---

I really like the Go programming language. Although I have never had a chance to use it professionally, I had a fun time learning it back in 2017 with the [Todd McLeod's course](https://www.udemy.com/course/go-programming-language/). These days I decided to take another look at Golang, with the goal of eventually applying it in my side projects. I was aware that a number of new features were added to the language since I touched it last time, most notably modules and generics. I haven't yet looked at the latter, but the thing I wanted to tinker with first was the **module-based project structure and the toolset around it**. This blog post is basically a short set of notes of how to get started with those. 

A nice little excercise is to create two modules, one being a **command-line "Hello World" app**, and the second serving as a **library** providing some functionality for the app. This is sort of what you write if you follow the official Golang's [**getting started tutorial**](https://go.dev/doc/tutorial/create-module). In my case I create the following two modules under some arbitrary directory `back2go`:

 - `back2go/greetings`: this one provides just a simple function like this: `func Hello(name string) (string, error)`
 - `back2go/hello-app`: this one contains `main.go` with `package main` that uses our own `"greetings"` package above, as well as the `"rsc.io/quote"` package providing some sample quotes. 

First things first, I create `go.mod` files in each of the packages' directories by executing the following command:

```sh
$ go mod init alexsm.com/back2go/greetings
# ...
$ go mod init alexsm.com/back2go/hello-app
```

The original `go.mod` files are pretty minimal, containing only the specified unique paths and the version of Golang. Our `hello-app` has two dependecies, specfied as imports in code. To add them to the corresponding `go.mod` we do the following. First, it is necessary to let Golang know that our `greetings` module cannot really be fetched from its path (`alexsm.com/back2go/greetings`), but should rather be found in its local directory:

```
$ go mod edit -replace alexsm.com/back2go/greetings=../greetings
```

This adds the following line to `go.mod` (which, of course, could have been added manually):

```
replace alexsm.com/back2go/greetings => ../greetings
```

After we specified all local modules (in this case only one), we fetch and install all the remote dependencies:

```sh
$ go mod tidy
```

This edits `go.mod`, adding the dependecies with the most recent versions, downloads/installs the packages themselves, as well as creates a `go.sum` file, containing checksums of the installed packages. The directory in which the packages are installed, namely `$GOPATH/pkg/mod`, is known as the **mudule cache directory**.

To complete the setup, it is necessary to make the directory containing `greetings` and `hello-app` a **Go workspace**. 

```sh
$ cd .. # one level up from any of the two modules
$ go work init
```

As a result, you get a `go.work` file in the root directory. Then we specify our two modules in this file. Again, this can be done with either terminal commands or by editing the file:

```sh
$ go work use ./hello-app
$ go work use ./greetings
```

The `go.work` looks like that:

```
go 1.18

use ./hello-app
use ./greetings
```

To finalize the post, I wanted to add a snapshot of the Golang part of my VSCode configuration file (`settings.json`). It annoys me quite a bit when stuff gets deleted on saving a file, so I prefer to disable some of the auto-formatting functionality in favor of manual invocation of `go fmt`:

```json
{
    "[go]": {
        "editor.insertSpaces": false,
        "editor.formatOnSave": false,
        "editor.codeActionsOnSave": {
            "source.fixAll": false,
            "source.organizeImports": false
        }
    },
}   
```

Useful links:

 * [Tutorial: Getting started with multi-module workspaces](https://go.dev/doc/tutorial/workspaces)
 * [Understanding go.mod and go.sum](https://faun.pub/understanding-go-mod-and-go-sum-5fd7ec9bcc34)

