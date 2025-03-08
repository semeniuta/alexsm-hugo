---
layout: post
title: "Install and configure pyenv on a Mac"
comments: true
math: true
slug: install-and-configure-pyenv-on-mac
date: "2024-12-15"
tags: [python, mac]
---

It is well-known that the built-in Python on macOS is not the one you want to use. As an alternative, you could think of Anaconda/Miniconda or Python installed via Homebrew. The latter option can seem like a good choice, but it has a big downside in a sense that Homebrew Python is being quite eagerly updated, and you don't really have a good control over the version of the interpreter. A nice argument about this issue can be found in ["Homebrew Python Is Not For You"](https://justinmayer.com/posts/homebrew-python-is-not-for-you/). A bottom line is that Homebrew Python is more of a *dependency* for other Homebrew packages rather than a stable development environment.

A pretty cool feature of sticking with a certain LTS version of a Linux distribution is that you deal with a pre-installed Python of a certain version that remains stable as long as you are on the same version of the LTS. For example, Ubuntu has the the following Pythons ([see DistroWatch](https://distrowatch.com/table.php?distribution=ubuntu)):

 * Ubuntu 24.04: Python 3.12.3
 * Ubuntu 22.04: Python 3.10.4

If you want to achieve something similar (or even better) on a Mac, a nice tool for that is [**pyenv**](https://github.com/pyenv/pyenv). It is a *Python version management system*, allowing you to have one or more specific versions of the interpreter. Below you can find some of my notes for installing and configuring Python with a single specific Python version.

Install `pyenv` via `brew`:

```sh
$ brew install pyenv
```

Add the following to your `~/.zhsrc`:

```
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 
```

Now, having `~/.zhsrc` sourced, we can start installing Python of certain version. We can start by browsing what versions are available in general:

```sh
$ pyenv install -l
```

Let's say we want to have an exactly same version as on Ubuntu 24.04, namely Python 3.12.3:

```sh
$ pyenv install 3.12.3
```

Then, if we want this version to be our global default, run the following command:

```sh
$ pyenv global 3.12.3
```

Once this is done, when you `cat $HOME/.pyenv/version`, you will see this file containing "3.12.3", and the `python` command will point to the pyenv-managed interpreter of exactly this version. 

Then you can go ahead and create "vanilla" virtual environments inside you projects, which will link to this "default" Python:

```sh
$ python -m venv .venv
```

I often like having a separate virtual environment with a lot of the important libraries installed that I keep up-to-date and use for quick tinkering. Let's say we call this environment `main_venv` and we put it inside a directory named `code`:

```sh
$ cd code
$ python -m venv main_venv
$ main_venv/bin/activate
(main_venv) $ pip install numpy scipy pandas matplotlib ipython
```

To activate such environment from any directory, the following shell script function (added to `~/.zshrc`) can be used:

```sh
main_env_activate() {
	cd $PATH_TO_CODE # (absolute path to the `code` directory)
	source main_venv/bin/activate
	cd - > /dev/null # back to the original directory without anything being printed
}
```

I have [an earlier blog post](https://alexsm.com/upgrade-outdated-packages-virtualenv-pip/), where I show how to keep such an environment updated.

There are much more use cases of using **pyenv**, like using it to *actually* manage several Python versions, and having "local" configuration per directory. Some more resources about **pyenv**:

 * [Managing Multiple Python Versions With pyenv](https://realpython.com/intro-to-pyenv/)
 * [Calm the Chaos of Your Python Environment with Pyenv](https://learningnetwork.cisco.com/s/blogs/a0D6e00000snzA2EAI/calm-the-chaos-of-your-python-environment-with-pyenv)

