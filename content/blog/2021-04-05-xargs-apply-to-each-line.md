---
layout: post
title: Applying a command to each line in a file with xargs -L1
comments: true
slug: xargs-apply-to-each-line
summary: "An xargs example for doing an operation for each line printed by cat"
date: "2021-04-05"
tags: [bash, git]
---

Let's say you have a text file which you wish to use an input to some command-line tool. Specifically, the goal is to apply the same command to each line in the file. This short post showcases how this can be done in a Unix shell (such as Bash) using a combination of `cat`, `xargs` and piping. 

As a motivating example, consider a file `repos.txt` containing URLs of several Github repositories, and our goal is to clone each of the repositiries. As such, the content of `repos.txt` can be the following:

```
https://github.com/semeniuta/EPypes.git
https://github.com/semeniuta/visionfuncs.git
https://github.com/semeniuta/pdata.git
```

Our goal is to clone each of those, i.e. execute the usual `git clone <URL>` command. As a first step, let's just print the content of the file in the terminal. This is done with the `cat` command:

```bash
cat repos.txt
```

In order to automatically pipe each line as an argument to the `git clone` command, the previus basic example is extended as follows:

```bash
cat repos.txt | xargs -L1 git clone
```

What is done here is that the entire standard output of `cat` is piped to the standard input of `xargs`. The latter uses this input as text that is inserted immediately after the specified command (`git clone`). The option `-L1` instructs `xargs` to [**use at most 1 nonblank input line per command line**](https://man7.org/linux/man-pages/man1/xargs.1.html), which  guarantees that in our case the `git clone` command is executed three times, each time cloning the respective repository specified in the `repos.txt` file. 


