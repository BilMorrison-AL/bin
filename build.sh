#!/bin/bash
set -eux
# Image name and version are pulled from files in the build directory: VERSION and NAME
export version=$(< VERSION)
# Image name
export IMAGE="$(< NAME)"
docker build --force-rm --no-cache -t "$IMAGE:latest" .
docker build --force-rm --no-cache -t "$IMAGE:$version" .
