---
layout: post
title: "Using git rebase --onto to attach a branch to an earlier commit"
comments: true
slug: git-rebase-onto
summary: "Manipulating where the current branch starts with git rebase"
date: "2022-02-20"
tags: [git]
---

Let's say you a working on a feature branch `feature` that is "attached" to a commit `X`. The latter was at some point the latest commit in the `main` branch, for instance when you started working on `feature`, or when you [rebased your branch against `main`](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) to keep up with what the others have added to `main`. Futher you see that there is some weird stuff happening due to certain changes intoructed in some commits preceding `X`, and you want to check how your code in the `feature` branch works as if it was based on some earlier commit, say `Y`. The original configuration looks like that:

```
...-(Y)-( )-( )-...-(X)-...-(main)
                      \
                       ( )-( )-(feature) 
```

To "re-attach" your feature branch, you apply the full version of `git rebase`, namely the one with the `--onto` option. For out situation, the command is as follows (where `X` and `Y` denote SHA-1 hashes on the respective commits of interest):

```sh
$ git rebase --onto Y X feature
```

Or, if we are already on the `feature` branch:

```sh
$ git rebase --onto Y X
```

The configuration changes to the following:

```
...-(Y)-( )-( )-...-(X)-...-(main)
      \
       ( )-( )-(feature) 
```

To attach the branch back to `X` or to the tip of the updated `main`, the short version of `git rebase` is sufficient:

```sh
$ git rebase X # or "git rebase main"
```

If it feels scary to experiment with rewriting Git history, a safe approach is to create a copy of the current branch:

```sh
# (when on feature)
$ git branch feature_backup
```

Then, no matter what you do with the `feature` branch after that, its exact original copy will "live" safely, marked as `feature_backup`. Later when you don't need the backup branch any more, you can force-delete it with the `-D` option:

```sh
$ git branch -D feature_backup
```

Further reading:
 - [Git rebase --onto an overview](https://womanonrails.com/git-rebase-onto)
 - [Rebase Onto - When Dropping Commits Makes Sense](https://www.thinktecture.com/en/tools/git-rebase-onto/)
 - [Regain Control of Branches with Git Rebase --onto](https://www.headway.io/blog/regain-control-of-branches-with-git-rebase-onto)