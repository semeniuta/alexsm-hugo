---
layout: post
title: Cancelling bad stuff in Git
comments: true
slug: cancel-bad-stuff-in-git
date: "2019-03-05"
tags: [git, programming]
---

Let's say you have staged some files to be further committed with `git add` and then change your mind. To unstage all or some files, invoke the `git reset` command (which is in a way an inverse of `git add`). A scenario for all changed files:

```
git add .
git reset
```

To unstage a single file, run the following command:

```
git reset HEAD myfile.py
```

If you have already made a commit, but then want to undo it, the following form of `git reset` can be used:

```
git reset --soft HEAD~1
```

The option `--soft` here is very important, as it leaves all the files in the working directory unchanged (that's what you need). Note that after this command the previosly staged files remain staged. 

