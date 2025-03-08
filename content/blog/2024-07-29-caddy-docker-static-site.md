---
layout: post
title: "Run Caddy in Docker for serving a static site"
comments: true
math: true
slug: caddy-docker-static-site
date: "2024-07-29"
tags: [docker]
---

[Caddy](https://caddyserver.com) is a really nice modern web sever written in Go, with an awesome feature of [automatic generation and renewal of HTTPS certificates](https://caddyserver.com/docs/automatic-https). To run Caddy in Docker for serving a static website (with HTTPS enabled), do as instructed in the [documentation](https://hub.docker.com/_/caddy) on Docker Hub:

```sh
docker run -d --cap-add=NET_ADMIN -p 80:80 -p 443:443 -p 443:443/udp \
    -v static_site_root_dir:/srv \
    -v caddy_data:/data \
    -v caddy_config:/config \
    caddy caddy file-server --domain mydomain.com
```

As such, you are just managing the files in `static_site_root_dir` (which is mapped to to the container's `/srv` directory), with the container's `/data` and `/srv` directories mounted as Docker volumes.

The `--cap-add=NET_ADMIN` option improves performance of the UDP-based HTTP/3 protocol (enabled in Caddy by default) by increasing the buffer size for the sockets. 
