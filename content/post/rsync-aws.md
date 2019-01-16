---
layout: post
title: Using rsync with AWS EC2 instance
comments: true
slug: rsync-aws-ec2
date: "2019-01-14"
tags: [rsync, linux, aws, ssh]
---

`rsync` is an extremely useful utility for synchronizing files between remote computers. It is the primary tool I use to deploy code to target such as servers, Raspberry Pies, or other remote Linux machines. In the simplest case, the workflow is as follows:

```bash
# upload everything in directory my_project to the remote host
rsync -avz my_project/ username@hostname:/home/username/my_project/

# donwload
...

```

If you look at the documentation via `man rsync`, the classic `-avz` option 

* `-a` you want recursion and want to preserve (symbolic links, devices, attributes, permissions, ownerships,  etc.  are  preserved)
* `-v` enables verbosity
* `-z` compresses the files being transmitted

When dealing with an AWS instance, one requires a private key (`pem`-file) that is associated with the given instance. 

```bash
rsync -avze "ssh -i ~/.ssh/AWSFrankfurt.pem" \
  my_project/ aws_user@$EC2_INSTANCE_HOSTNAME:/home/aws_user/my_project/
```

https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/