#!/bin/bash
set -eux
# Docker and Git Hub username are assumed to be the same and is pulled from environment variable
USERNAME="$HUBUSERNAME"
# Image name
IMAGE="$(< NAME)"
# Always make sure it is current
git pull
# Increment the minor version by one for every release
version="$(< VERSION)"
echo "Old Version:    $version"
docker images | grep "$IMAGE" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}
oldnum=$(cut -d '.' -f3 VERSION)
newnum=$(( $oldnum + 1 ))
#   $((..)), ${} or [[ ]]
sed -iu "s/$oldnum/$newnum/g"  VERSION
rm -f VERSIONu
version=$(< VERSION)
echo "New Version:    $version"
echo "IMAGE  $IMAGE"
# Run build - Docker/Git Hub Username are defined in build
docker build --force-rm --no-cache -t "$IMAGE:latest" .
docker build --force-rm --no-cache -t "$IMAGE:$version" .

echo "HUBUSERNAME:    $HUBUSERNAME/$IMAGE:$version"
docker tag  "$IMAGE:$version"  "$HUBUSERNAME/$IMAGE:$version"
docker tag  "$IMAGE:$version"  "$HUBUSERNAME/$IMAGE:latest"
#
git add -A
git commit -m "Version $version"
# Tag it
git tag -a "$version" -m "Version $version"
git push
git push --tags
echo "version   $version"
# Push it to dockerhub
docker push "$HUBUSERNAME/$IMAGE:$version"
docker push "$HUBUSERNAME/$IMAGE:latest"
