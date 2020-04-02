---
title: Docker - best practices
layout: post
date: 2020-04-02
categories: [Developer workshop]
tags: [docker, best practices, howto, build, tag]
---

I have been using a docker for some time. Most of the knowledge I have is empirical acquired by numerous trials and supported by even more errors. Recently, I tried to gather and organize everything in one place.

## Keep your build context clean

When you run `docker build .` command, docker runs in a context of directory you provided. This way every operation you describe in `Dockerfile` will be executed in context of that directory but first docker will send build context to Docker daemon. The smaller context will be, the less time and memory will be consumed for build. If, for some reason, you can't have context directory separated you should have file called `.dockerignore` placed in context root. `.dockerignore` works just like `.gitignore` file. Any file/directory that is not required for our application to run should be specified in `.dockerignore`.

## Keep your instructions in right order

While building, docker creates layers. You know... onions have layers, ogres have layers... also Docker image has layers. Instructions like `RUN`, `COPY` and `ADD` creates so called intermediate layers (or intermediate images) which are cacheable until something changes for that layer. Let's take following example into consideration:

```dockerfile
FROM php:apache

WORKDIR /app

COPY . .

RUN apt-get -y update 
RUN apt-get -y install curl ca-certificates gnupg2 git
RUN apt-get -y install postgresql-client-11 librabbitmq-dev libgmp-dev libpq-dev
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

In above example we are copying whole code into an image at very beginning whitch is a bad practice. Layer that is created by COPY instruction will be invalidated every time we change content of any file. Which happens quite often. When that layer gets invalidated, every layer that was created after will be invalidated too. So putting something that can change more often at the top of file will make our image to be build from scratch every time. What we can do is to put frequently changing stuff as late as possible, e.g. what changes less often than code itself are dependencies. That way we can install them at the start and copy rest of code almost at the end:

```dockerfile
FROM php:apache

WORKDIR /app

~~COPY . .~~

RUN apt-get -y update 
RUN apt-get -y install curl ca-certificates gnupg2 git
RUN apt-get -y install postgresql-client-11 librabbitmq-dev libgmp-dev libpq-dev
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install

COPY . .

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## Be more specific when copy

Copying our code into image we should specify only those files that are crucial for application to run. This will make final image even smaller.

```dockerfile
FROM php:apache

WORKDIR /app

RUN apt-get -y update
RUN apt-get -y install curl ca-certificates gnupg2 git
RUN apt-get -y install postgresql-client-11 librabbitmq-dev libgmp-dev libpq-dev
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install

COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## Combine your RUN commands

If you have many RUN instructions one under another, you can join them using `&&` sign. This will result as single intermediate layer with all those commands. This can be useful if you update the repository before installing dependencies. By doing these operations separately, Docker can cache repository update, but not package installation itself. If for some reason the required package is unavailable during building, the building process will fail.

```dockerfile
FROM php:apache

WORKDIR /app

~~RUN apt-get -y update~~
~~RUN apt-get -y install curl ca-certificates gnupg2 git~~
~~RUN apt-get -y install postgresql-client-11 librabbitmq-dev libgmp-dev libpq-dev~~
RUN apt-get -y update && apt-get -y install \
        curl \
        ca-certificates \
        gnupg2 \
        git \
        postgresql-client-11 \
        librabbitmq-dev \
        libgmp-dev \
        libpq-dev 

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install

COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## Stick to alphabetical order

This is simple purist practice. If you have a lot of dependencies to install, keeping them in alphabetical order will make it more readable for other developers and let you avoid repetitions.

```dockerfile
FROM php:apache

WORKDIR /app

RUN apt-get -y update && apt-get -y install \
        ~~curl \ ~~
        ~~ca-certificates \ ~~
        ~~gnupg2 \ ~~
        ~~postgresql-client-11 \ ~~
        ~~librabbitmq-dev \ ~~
        ~~libgmp-dev \ ~~
        ~~libpq-dev~~
        ca-certificates \
        curl \
        git \
        gnupg2 \
        libgmp-dev \
        libpq-dev \
        librabbitmq-dev \
        postgresql-client-11

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install

COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## Are you realy gonna need those extra dependencies? 

Just like you will copy only code that is required for application to run, you should install only those dependencies that are realy required. By default if package has some recommended dependencies, package manager will install them by default. Only required packages should installed. This can be sagnificant for image size and building time.

```dockerfile
FROM php:apache

WORKDIR /app

~~RUN apt-get -y update && apt-get -y install \ ~~
RUN apt-get -y update && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        git \
        gnupg2 \
        libgmp-dev \
        libpq-dev \
        librabbitmq-dev \
        postgresql-client-11

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install

COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## You are your own garbage collector

Installing dependencies will make package manager to cache the local repository of retrieved package files. This cache will stay on image layer. Again to keep final image as small as possible, you can clear unnecessary cache.

```dockerfile
FROM php:apache

WORKDIR /app

RUN apt-get -y update && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        git \
        gnupg2 \
        libgmp-dev \
        libpq-dev \
        librabbitmq-dev \
        postgresql-client-11 \
    && apt-get clean

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install && composer clear-cache

COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## Use specific version of base image

Using `latest` version of base image is strongly not recomended. This is because `latest` doesn't tell you exactly which version is required for application to run and most of the time links to latest stable version. Considering that there can be some sagnificant differences between each versions you should always specify which version to use. Just to be safe. Upgrade should always be done deliberately and with caution.

```dockerfile
~~FROM php:apache~~
FROM php:7.4.4-apache

WORKDIR /app

RUN apt-get -y update && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        git \
        gnupg2 \
        libgmp-dev \
        libpq-dev \
        librabbitmq-dev \
        postgresql-client-11 \
    && apt-get clean

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY composer.json ./
COPY composer.lock ./

RUN composer install && composer clear-cache

COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

## Choose smallest base image possible

Many base images comes in lighter versions (`-alpine`, `-slim`, etc.). They defer in preinstalled set of dependencies. It is up to you which version will be used as your base image. Depending on final result, you will end up with image build on top of full-sized image or build one `FROM scratch`.

## Separate responsibilities

Another good practice is that your container should be as ephemeral as as possible. That means that you should be able to stop, destroy, rebuild and start your container without any unnecessary changes in application. You will accomplish that by defining image as [one process only](https://12factor.net/processes) like API, console or some processing worker. This will make horizontal scaling easier and running containers in this stateless manner let you reuse them more efficiency.

## Multi-stage build

Multi-stage build involves the use of more complex base images containing dependencies required to build the application, but not necessarily to run it. An application built in this way in a larger, base image will become an artifact used in building the final image. This will reduce the number of layers and dependencies of the final image, which will drastically reduce its final size.

```dockerfile
FROM composer:1.9.3 as build

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install --ignore-platform-reqs --prefer-dist --optimize-autoloader --no-suggest --no-scripts

FROM php:7.4.4-apache

WORKDIR /app

RUN apt-get -y update && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        gnupg2 \
        libgmp-dev \
        libpq-dev \
        librabbitmq-dev \
        postgresql-client-11 \
    && apt-get clean

COPY --from=build /app/vendor /app/vendor
COPY src ./

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```