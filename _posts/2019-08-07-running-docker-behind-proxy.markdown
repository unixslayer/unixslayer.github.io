---
title: Running Docker behind proxy
layout: post
date: 2019-08-07
categories: [Developer workshop]
tags: [configuration, DevOps, Docker, proxy, Ubuntu]
---

> Disclaimer: there are bunch of tutorials on how to do this. I’ve already tried setting proxy in OS env and `/etc/docker/daemon.json` file. Both without success just like few other tries. I’m writing down how I achieved this on my `Ubuntu 18.04`.

If you’re trying to run `Docker` without having direct access to web you have to configure daemon to use proxy server. Without it you won’t be able to pull or push any image. Simple daemon check will end with failure.

```bash
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
 docker: Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp 34.201.196.144:443: connect: connection refused.
```

First what you have to do is to create configuration file /etc/systemd/system/docker.service.d/http-proxy.conf with following content:

```conf
[Service]
Environment="HTTP_PROXY=http://10.100.20.30:8000/" "HTTPS_PROXY=http://10.100.20.30:8000/"
```

Then reload systemd daemon

```bash
$ sudo systemctl daemon-reload
```

and restart docker service

```bash
$ sudo systemctl restart docker.service
```

Now Docker should work just fine

```bash
$ docker run hello-world                                       
 Unable to find image 'hello-world:latest' locally
 latest: Pulling from library/hello-world
 1b930d010525: Pull complete 
 Digest: sha256:6540fc08ee6e6b7b63468dc3317e3303aae178cb8a45ed3123180328bcc1d20f
 Status: Downloaded newer image for hello-world:latest
 
 Hello from Docker!
 This message shows that your installation appears to be working correctly.
 
 To generate this message, Docker took the following steps:
 The Docker client contacted the Docker daemon.
 The Docker daemon pulled the "hello-world" image from the Docker Hub.
 (amd64)
 The Docker daemon created a new container from that image which runs the
 executable that produces the output you are currently reading.
 The Docker daemon streamed that output to the Docker client, which sent it
 to your terminal. 
 
 To try something more ambitious, you can run an Ubuntu container with:
  $ docker run -it ubuntu bash
 
 Share images, automate workflows, and more with a free Docker ID:
  https://hub.docker.com/
 
 For more examples and ideas, visit:
  https://docs.docker.com/get-started/
```