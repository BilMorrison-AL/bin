#!/bin/bash
set -eux
# Make sure connected to AWS
export AWS_PAGER=""
aws sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
# Image name and version are pulled from files in the build directory: VERSION and NAME
export version=$(< VERSION)
export IMAGE="$(< NAME)"
docker build --force-rm --no-cache -t "$IMAGE:latest" .
docker build --force-rm --no-cache -t "$IMAGE:$version" .
