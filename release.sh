#!/bin/bash
set -e
# Container image name
IMAGE="$(< NAME)"
# Always make sure it is current
git pull
# Increment the minor version by one for every release
version="$(< VERSION)"
echo "Old Version: $version"
docker images | grep "$IMAGE" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}
oldnum=$(cut -d '.' -f3 VERSION)
newnum=$(expr $oldnum + 1)
echo "$oldnum"
echo "$newnum"
sed -iu "s/$oldnum/$newnum/g"  VERSION
rm -f VERSIONu
version=$(< VERSION)
echo "New Version: $version"
# Run build - Docker/Git Hub Username are defined in build
build
git add -A
git commit -m "version $version"
# Tag it
git tag -a "$version" -m "version $version"
git push
git push --tags
docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$version
# Push it to dockerhub
docker push $USERNAME/$IMAGE:latest
docker push $USERNAME/$IMAGE:$version
