---
layout: post
title: "Configuring SSH agent"
comments: true
slug: configure-ssh-agent
summary: "Using SSH agent across Mac and Linux, forwarding the agent in sessions"
date: "2022-03-19"
tags: [ssh, macos, linux, ubuntu]
---

SSH agent is a program resposible for handling passhareses for SSH keys. Instead of typing your passphare every time you connect to a remote host, the correctly configured SSH agent will provide the passphrase to `ssh` or `scp` without you being prompted. It also allows to initiate another SSH session from a remote host by the means of agent forwarding. This blog post will be a bit Mac-oriented, since I am still in the process of figuring out the details of how certain aspects of SSH agent work on Linux. 

Let's say we have generated a pair of keys (as described [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)) using a secret passphrase:

 - `~/.ssh/id_ed25519` (private key)
 - `~/.ssh/id_ed25519.pub` (public key)

Further, you copy your public key to the remote host, which adds the key to its own `~/.ssh/authorized_keys`:

```
$ ssh-copy-id -i ~/.ssh/id_ed25519 user@host
```

At this point, you will be prompted for the passphrase every time you connect to the remote host with `ssh`. The most basic way to use SSH agent to remember the passphrase is as follows:

```
$ ssh-add -k ~/.ssh/id_ed25519
```

This will load the passphrase into SSH agent's memory, and remote logins will happen "passwordless". When the agent is stopped or the computer is rebooted, the key will need to be added again. 

In some situations, SSH agent might not be running. It can be launched as follows:

```
eval `ssh-agent`
```

If you would like to stop the agent, a similar command with the `-k` option is issued:

```
eval `ssh-agent -k`
```

It is worth noting that SSH agent works with slightly differently on Linux and Mac. The latter can utilize [Keychain](https://en.wikipedia.org/wiki/Keychain_(software)) to store the passphrases. The upside of this is that your agent's "memory" can be made persistent between reboots. On macOS you can use the `--apple-use-keychain` option:

```
$ ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

To automate adding the key to the agent, you can edit `~/.ssh/config` and add the following entry:

```
Host *
  UseKeychain yes
  AddKeysToAgent yes
```

This enables the use of Keychain and automatic lookup in it whenever you use `ssh`. 

If you have SSH keys with some "non-standard" names/locations (other than `~/.ssh/id_rsa`, `~/.ssh/id_ed25519` and the like), you may want to add the `IdentityFile` directive:

```
  IdentityFile ~/.ssh/my_key
```

The latter directive, together with `IdentitiesOnly` can be used to specify concrete keys to be used with certain hosts, as described in [this nixCraft tutorial](https://www.cyberciti.biz/faq/force-ssh-client-to-use-given-private-key-identity-file/). 

In some cases you might be interested in **SSH agent forwarding**. When it is enabled, the saved identity gets forwarded to the remote host, so you could initiate an SSH session from it to some third host. One way to make it work is to create an entry in `~/.ssh/config`:

```
Host myhost
  ForwardAgent yes
```

However, as noted in [this tutorial](https://smallstep.com/blog/ssh-agent-explained/), agent forwarding comes at a risk, so it might be wiser to only enable it per connection if you intend to use it (with the option `-A`):

```
$ ssh -A user@host
```

To list the identities added to the agent, use the following command:

```
$ ssh-add -l
```

To clear all identities:

```
$ ssh-add -D
```

On **Linux**, or on Ubuntu 20.04 to be exact, I haven't completely figured out how the SSH agent operates. On bootup, the `ssh-add -l` lists my primary key. When I want to delete it with `ssh-add -D`, it still remains listed. Other people have discussed this situation [on StackExchange](https://unix.stackexchange.com/questions/330569/ssh-add-d-refused-to-remove-identity). What I notice is that on the cleanly-started system during the first SSH connection, a *graphical prompt* for the passphrase pops up, and on all the subsequent connections the agent uses the stored pasphrase. On the other hand, if I restart the agent as such:

```
eval `ssh-agent -k` ; eval `ssh-agent`
```

Then the agent behaves more like expected: it *promts for the passphrase in the terminal* and "obeys" the deletion command. It looks like the former case (on a cleanly-booted system) also works just fine, it is just that what you see in the terminal is a bit confusing.

Some useful turotials about the topic:

 - [SSH Agent Explained](https://smallstep.com/blog/ssh-agent-explained/)
 - [The Ultimate Guide to SSH - Setting Up SSH Keys](https://www.freecodecamp.org/news/the-ultimate-guide-to-ssh-setting-up-ssh-keys/)
 - [ssh-agent - How to configure, forwarding, protocol](https://www.ssh.com/academy/ssh/agent)