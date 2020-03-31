#!/bin/bash
set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
# Environment variable
export USERNAME=$GITHUBUSERNAME
# image name
export IMAGE="$(cat NAME)"
docker build -t $USERNAME/$IMAGE:latest .
