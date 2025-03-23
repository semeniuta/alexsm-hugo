---
layout: post
title: "Update all outdated packages inside a virtualenv with pip"
comments: true
math: false
slug: upgrade-outdated-packages-virtualenv-pip
summary: "Shell pipeline using pip, tail, awk, tr, xargs"
date: "2022-11-25"
tags: [bash, python]
---

Let's say you have a `virtualenv` environment that you haven't touched for a while, and you wish to keep all the packages in it up-to-date (this is clearly not applicable for virtual environments that are meant to contain specific versions of the packages for reproducibility's sake, but we are not talking about those). There is unfortunately no single `pip` option for that, but we can easily create our own simple script by combining several Unix tools with piping.

If you have your environment activated, you can check which packages are out of date:

```sh
pip list --outdated
```

The output might look something like this:

```
Package    Version Latest Type
---------- ------- ------ -----
comm       0.1.0   0.1.1  wheel
jedi       0.18.1  0.18.2 wheel
jsonschema 4.17.0  4.17.1 wheel
setuptools 65.6.0  65.6.3 wheel
```

If `pip` itself is outdated, the comand above will also result in an additional notice regarding that. Let's now use some Unix magic to turn this tabular output into an up-to-date `virtualenv`. 

The overall taks is simple: we need to parse the names of the outdated packages, and then install newer versions of precisely those packages.

The first step is to exclude the table's header, which amounts to the first two lines of the output. At the same time, we don't really need the pip notice check that might appear at the bottom. We achieve all this by using an appropriate `pip` option and piping the output into `tail`:

```sh
pip list --outdated --disable-pip-version-check | tail -n +3
```

`tail -n +3` means that we skip the first two lines and start with the third.

Further on, we need to get only the first word from each line, and then separate each word with a space (instead of a newline). These two tasks can be achieved using `awk` and `tr`:

```sh
... | awk '{print $1;}' | tr '\n' ' '
```

To get the final `pip install --upgrade comm jedi jsonschema setuptools`, we pipe the result into `xargs`. The final one-liner will look as follows:

```sh
pip list --outdated --disable-pip-version-check \
    | tail -n +3 \
    | awk '{print $1;}' \
    | tr '\n' ' ' \
    | xargs pip install --upgrade
```

