#!/bin/bash
set -eux
# Make sure connected to AWS
REPONAME="894680052389.dkr.ecr.us-east-1.amazonaws.com"
export AWS_PAGER=""
aws --profile sysops-permission-set-894680052389 sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
aws --profile sysops-permission-set-894680052389 ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${REPONAME}"
# Image name and version are pulled from files in the build directory: VERSION and NAME
export version=$(< VERSION)
export IMAGE="$(< NAME)"
#docker build --force-rm --no-cache -t "${IMAGE}:latest" .
#docker build --force-rm --no-cache -t "${IMAGE}:${version}" .
docker build --force-rm --no-cache -t "${REPONAME}/${IMAGE}:latest" .
docker build --force-rm --no-cache -t "${REPONAME}/${IMAGE}:${version}" .
