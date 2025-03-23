---
layout: post
title: "Configure NAT port forwarding on VMWare Fusion for SSH"
comments: true
slug: vmware-fusion-nat-port-forwarding-ssh
summary: "Setting up openssh-server and ufw on an Ubuntu virtual machine, and configuring NAT on VMWare Fusion"
date: "2022-04-16"
tags: [linux, ubuntu, ssh, networking, virtualization]
---

Let's say you have a VMWare Fusion VM with Ubuntu on it, and you would like to connect to it from the host system (macOS) through SSH. How to configure port forwarding for that? This post is based on [the tutorial by Craig Weatherhead](http://www.weatherhead.net/2015/06/21/vmware-fusion-nat-port-forwarding-101/), with some added steps related to SSH and firewall configuration on the guest system.

So, by default you get a VM with a NAT network adapter. When you log into your guest OS, check the assigned IP address:

```sh
$ ip address show
```

Take a note of this address, as we will later need it on our host system to configure port forwarding. Before doing that, though, let's [install and enable OpenSSH server](https://www.cyberciti.biz/faq/ubuntu-linux-install-openssh-server/):

```sh
$ sudo apt install openssh-server # install
$ sudo systemctl enable ssh       # enable
$ sudo systemctl start ssh        # start service
$ sudo systemctl status ssh       # check status
```

Then, enable SSH port (22) in the Uncomplicated Firewall (`ufw`):

```sh
$ sudo ufw allow ssh              # enable SSH port
$ sudo ufw enable                 # enable the firewall
$ sudo ufw status                 # list the current firewall rules
```

OK, so the OpenSSH server is ready on the guest OS. Let's go back to the host OS and do some configuration of NAT port forwarding. First, let's open the configuration file:

```sh
$ sudo vim Library/Preferences/VMware\ Fusion/vmnet8/nat.conf
```

Search for the section starting with `[incomingtcp]` (in Vim, use "`/`" for that). On a clean installation you will find a commented-out example. Now it is time to use the previously noted IP address, together with port 22 for OpenSSH to enable port forwarding. Let's say our IP address is `192.168.102.128`. Then the configuration line will be the following:

```
[incomingtcp]
2222 = 192.168.102.128:22
```

Which means that our goal is to connect to `localhost` (`127.0.0.1`) via SSH, but using port `2222`. 

Once the editing is done, restart the VMWare networking with the following commands:

```sh
$ sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --stop
$ sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --start
```

You are good to go. To establish the connection through a non-standard port (in our case, `2222`), use the following form of `ssh` command (`-l` for login name and `-p` for port):

```sh
$ ssh -l user -p 2222 127.0.0.1
```

When using `rsync` with this kind of setup, just add the following option to the rest of the command:

```
-e 'ssh -p 2222'
```

