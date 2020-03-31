#!/bin/bash
set -eux
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=williammorrisonal
# image name
IMAGE=awscli-alpine
# ensure we're up to date
git pull
# bump version
version="$(cat ./VERSION)"
docker images | grep "$IMAGE" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}
oldnum=$(cut -d '.' -f3 ./VERSION)
newnum=$(expr $oldnum + 1)
echo "$oldnum"
echo "$newnum"
sed -iu "s/$oldnum/$newnum/g"  VERSION
rm -f VERSIONu
version=`cat VERSION`
echo "version: $version"
# run build
build
# tag it
git add -A
git commit -m "version $version"
git tag -a "$version" -m "version $version"
git push
git push --tags
docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$version
# push it
docker push $USERNAME/$IMAGE:latest
docker push $USERNAME/$IMAGE:$version
