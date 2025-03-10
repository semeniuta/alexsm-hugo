---
layout: post
title: Cancelling bad stuff in Git
comments: true
slug: cancel-bad-stuff-in-git
summary: "Some Git command to recover from when something has been messed up."
date: "2019-06-23"
tags: [git, programming]
---

In this post I am going to provide some examples of Git usage that may come in handy in case of unsuccessful previous actions during staging, committing, and merging. 

Let's say you have staged some files to be further committed with `git add` and then change your mind. To **unstage all or some files**, invoke the `git reset` command (which is in a way an inverse of `git add`). A scenario for all changed files:

```bash
$ git add .
$ git reset
```

To unstage a single file, run the following command:

```bash
$ git reset myfile.py
```

If you look up the [Git documentation](https://git-scm.com/docs/git-reset), the previous two example correspond to the form of `git reset`  that resests the state of the index (what is going to be committed next) to what is currently in the last commit, i.e. `HEAD`. As such they can be written in more explicit form as follows:

```bash
$ git reset HEAD
$ git reset HEAD myfile.py
```

**If you have already made a commit, but then want to undo it**, `git reset` can be used in one of these three ways:

```bash
$ git reset --soft HEAD~1
$ git reset --mixed HEAD~1
$ git reset HEAD~1
```

Such form of `git reset` operates on commits rather than on files (as the previous examples do). What is done here is that what `HEAD` points to has moved: initally `HEAD` points to the  last commit that we are going to undo, and after any of these commands `HEAD` points to `HEAD~1`, i.e. the previous commit before the last one. 

The option `--soft` only moves the commit history, but doesn't touch the index. It means that whatever was staged with `git add` previously will remain staged. The option `--mixed`, however, updates the index to match the target commit (in our case `HEAD~1`), so you will have a possibility for performig staging afterwards. It is also the default option, so it may be ommitted as in the third line. 

To discard changes made to a specific file and update it to what is currently in the last commit, the `git checkout` command can be used: 

```bash
$ git checkout -- myfile.py
```

The dash-dash literal (`--`) here is optional, and is used to separate options (starting with dash) and parameters (in this case, the filename). See [this](https://stackoverflow.com/questions/22750028/in-git-what-does-dash-dash-mean) Stack Overflow question for more details on that matter. 

To get a better understanding of the various forms of `git reset` and `git checkout`, please refer to [this chapter](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified) of the official Git book.  

The last use case is **unsuccessful merge (resulting in conflics) that has to be aborted**, thus leading to reconstruction of the pre-merge state. In this situation, the following command shall be invoked:

```bash
$ git merge --abort
```