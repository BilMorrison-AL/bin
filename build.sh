#!/bin/bash
set -eux
# SET THE FOLLOWING VARIABLES
# docker hub username
# Environment variable
export USERNAME="$GITHUBUSERNAME"
# Image name
export IMAGE="$(cat NAME)"
echo "$USERNAME/$IMAGE:latest"
docker build --force-rm --no-cache -t "$USERNAME/$IMAGE:latest" .
