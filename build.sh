#!/bin/bash
set -eux
# Docker and Git Hub username are assumed to be the same and is pulled from environment variable
export USERNAME="$HUBUSERNAME"
# Image name
export IMAGE="$(< NAME)"
echo "$USERNAME/$IMAGE:latest"
docker build --force-rm --no-cache -t "$USERNAME/$IMAGE:latest" .
