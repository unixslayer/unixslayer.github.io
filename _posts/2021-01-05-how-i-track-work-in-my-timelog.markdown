---
title: How I track work in my timelog
layout: post
date: 2021-01-05
categories: [tech]
tags: [productivity, improvements, hamster, timetracking, ubuntu, gnome, extensions]
---

As a programmer who works with different tasks, projects and even teams it is important to be able to report work time either when settling with client, superiors or during the daily Scrum. There are some browser-based tools but they ain't comfortable when you have opened many tabs at once.

There is a possibility to install an time tracking application on your phone. I was once using `Jira time tracker` on my phone, which was connecting directly with company's Jira. Unfortunately in the long run this didn't work. Not because this was poor solution, but because I didn't took my phone everywhere with me. This was more common even to leave my phone at home rather than my computer. Later I sometimes forgot to fill my timelog, and who remembers what he/she did few days ago, or even yesterday? ;)

There are also services like `Toggl` which allows you to install a desktop application. HHere however I alway had some problems with how they work and integrate with Linux. For some reason desktop applications have better support on Windows or MacOS systems. 

Personally I spend much time with my hands on the keyboard and that is why best solution for me is the one that can well integrate with shell and easily allows to switch between activity context. Fortunately, such tool exists.

## Hamster time tracker

`Hamster` can be installed on any Linux distribution. It provides a service that allows you to track your activities from command line. `Hamster time tracker` can be installed with apt.

    sudo apt install hamster-time-tracker

I recommend to install `Hamster` this way. There is a possibility for installing it via `snap`, but at the moment snap won't allow for external services to launch user session dbus-services ([see related discussion](https://forum.snapcraft.io/t/need-help-dbus-activation-for-project-hamster-snap/11885)).

From now on, you can use `Hamster` from your command line. 

    hamster help

## Recording activity

Activities can be categorized, tagged, filled with description and defined in the past if you forgot to report them. 

When you want to record an activity, you can simply type what you are doing and `Hamster` will do the rest, but there is more to that which can help you track your time even better.

To add activity `Hamster` defines following syntax:

    activity name time @category name,, some description #tag #other tag with spaces

Everything you pass at the begining will be used as an activity name. Time can be defined as a starting point, time period or have relative value, eg. `14:30`, `11:35-12:00`, `-5` for `started 5 minutes ago`. Using `@` let you categorize your activity, double coma (`,,`) is for description and `#` can be used for tags. Be advised that `Hamster` will handle empty spaces as part of a started section until it finds next special character.

    hamster add doing something important -5 @project #tag

`Hamster` also allows you to export your timelog in such formats as `xml`, `csv`, `html` and `ical`.

    hamster export tsv

However there is more efficient way to track your time with `Hamster` for those who use Gnome.

## Gnome Shell Extension

`Hamster shell extension` available on [Gnome extensions website](https://extensions.gnome.org/) is outdated however it is realy straight-forward to install it by yourself. Start from cloning official repository.

    git clone https://github.com/projecthamster/hamster-shell-extension.git

Make sure, that you are on `develop` branch

    git checkout develop

Repository contains a Makefile that allows you to build and install this extension in your home directory. 

    make install-user

During compilation, I got the following result

```
$ make dist
cp -R extension/* build
cp -R data/* build
glib-compile-schemas build/schemas
find build -name \*.po -execdir msgfmt hamster-shell-extension.po -o hamster-shell-extension.mo \;
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
find: ‘msgfmt’: No such file or directory
mkdir -p dist;
cd build; zip -rq ../dist/contact@projecthamster.org.zip ./* || true
cd build; tar -czf ../dist/contact@projecthamster.org.tar.gz *
total 112
-rw-r--r-- 1 marc marc 46418 mar 19 11:05 contact@projecthamster.org.tar.gz
-rw-r--r-- 1 marc marc 65436 mar 19 11:05 contact@projecthamster.org.zip
```

This is related to translations compilation and can be solved by installing `gettext` package.

    sudo apt install gettext

To finalize, we may have to restart Gnome Shell. To do that press `Alt+F2`, type `r` and hit `Enter`. Last thing I do is to disable `<super>+h` shortcut which hides current active window. `Hamster extension` binds to it, and since I dont use it, I can disable it. You can either do the same as I, or can also change extension shortcut by looking for `Hanster time tracker` on installed extensions list and go into preferences.

Each time we start doing something, we can hit `<super>+h`, type current activity, hit `Enter` and `Hamster` will ... start tracking time ;) Shell extension uses the same syntax as command line with one difference - if defined, time must be passed at the beginning.

Currently ongoing activity should be visible on the top bar.

![hamster-top-bar](/assets/hamster-top-bar.png)
