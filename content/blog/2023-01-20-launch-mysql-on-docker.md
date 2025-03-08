---
layout: post
title: "Spin up a MySQL database powered by Docker"
comments: true
math: false
slug: launch-mysql-on-docker
date: "2023-01-20"
tags: [databases, mysql, docker]
---

Let's say you want to quickly launch a MySQL database and populate it with data, perhaps in an automated way using a script. We are going to use Docker on a remote Linux server and a MySQL client on the local computer (in my case a Mac). This tutorial will be based on Docker commands only, without using Docker Compose or other fancy tools.

Our goal is to spin up a dummy MySQL instance where we don't care about persistence of data after we are done working with it (like when using it to support development of some data-driven app). As such, at this point we don't care about the version of MySQL, so we can go ahead and pull the latest available version (the commands here are executed on the Docker host):

```sh
$ docker pull mysql
```

Then, we launch the container:

```sh
$ docker container run \
    --name mysql_dummy \
    --publish 3306:3306 \
    --env MYSQL_ROOT_PASSWORD=mysQl_dummY_pwd \
    --detach \
    mysql:latest
```

Here we are instructing Docker to launch a container named `mysql_dummy` based on the `mysql:latest` image. The container will run in the background (`--detach`), and its port 3306 ([MySQL's port for the classic protocol](https://dev.mysql.com/doc/mysql-port-reference/en/mysql-ports-reference-tables.html)) will be published to Docker host as the same port value. The newly created MySQL instance will be configured with the *not so secure* `root` passord as specified in the command (this is done through setting an evironment variable inside the container via `--env`).

When we are done working with this container, we may invoke commands for stopping and removing it:

```sh
$ docker container stop mysql_dummy
$ docker container rm mysql_dummy
```

When after this we invoke the same `docker container run` above, we will get a fresh database server. If, on the other hand, the goal is for the data to persist betwen the launches, we can create a [named volume](https://docs.docker.com/storage/volumes/) mapped to the container's `/var/lib/mysql`, which stores the actual MySQL data. To do this, add the following option to the `docker container run` command above:

```sh
--mount source=mysql_dummy_volume,target=/var/lib/mysql
```

To install MySQL client on a Mac, we'll use Homebrew. Because this installs only the client, and not the full-fledged MySQL with the server part, we will need to manually add the client's location to `$PATH` (all further commands are executed locally):

```sh
$ brew install mysql-client
$ echo 'export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"' >> ~/.zshrc
```

When [`nmap`](https://nmap.org/) is available on the local machine (if not, `brew install nmap`), it can be used to to check whether the MySQL server's port is open. Assuming that the Docker host's IP or hostname is stored in the `$DOCKER_HOST` environment varible, the `nmap` invocation is as follows:

```sh
nmap $DOCKER_HOST -p 3306
```

If everything works as expected, the output of the `nmap` scan will include the following:

```
PORT     STATE SERVICE
3306/tcp open  mysql
```

Let's then populate the database with some data via a SQL script. We will create a table for blog comments, where each entry is comprised of the author name, URL of the author's website, and comment text. First, we create a script, let's call it `create.sql`:


```sql
CREATE DATABASE dummy_db;
USE dummy_db;

CREATE TABLE comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    author_name VARCHAR(255) NOT NULL,
    author_url VARCHAR(255),
    comment_text TEXT,
    PRIMARY KEY (comment_id)
);

INSERT INTO comments (author_name, author_url, comment_text) VALUES (
    "Ivanna Baturynska",
    "https://ivannacooks.com",
    "That was useful!"
);

INSERT INTO comments (author_name, author_url, comment_text) VALUES (
    "Oleksandr Semeniuta",
    "https://alexsm.com",
    "Please add more stuff."
);
```

Then we'll use the local MySQL client to connect to the database and execute the script:

```sh
$ mysql -h$DOCKER_HOST -P3306 -uroot -p < create.sql
```

This example was a bit primitive, particularly when it comes to the security aspects. A more realistic/proper way is to modify the root user and create a custom user with fine-grained privileges (see [this guide](https://www.linode.com/docs/guides/securing-mysql)).

Some useful links:

 * [MySQL on Docker Hub](https://hub.docker.com/_/mysql)
 * [Executing SQL Statements from a Text File](https://dev.mysql.com/doc/refman/8.0/en/mysql-batch-commands.html)
 * [Documentation on docker container run](https://docs.docker.com/engine/reference/commandline/container_run/)