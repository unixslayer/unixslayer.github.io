#!/usr/bin/env bash

docker run --rm --volume="$PWD:/srv/jekyll" --volume="$PWD/vendor/bundle:/usr/local/bundle" -p 80:4000 -it jekyll/builder "$@"