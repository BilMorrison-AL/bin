#!/bin/bash
set -eux
# Repo name for aws not using Dockerhub, otherwise use REPONAME="$HUBNAME"
REPONAME="894680052389.dkr.ecr.us-east-1.amazonaws.com"
# Always make sure it is current
git pull
# Make sure connected to AWS
export AWS_PAGER=""
aws sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
# Image name and version are pulled from files in the build directory: VERSION and NAME
version="$(< VERSION)"
IMAGE="$(< NAME)"
# Increment the minor version by one for every release
echo "Old Version:    $version"
docker images | grep "$IMAGE" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}
oldminornum=$(cut -d '.' -f3 VERSION)
newminornum=$(( $oldminornum + 1 ))
#   $((..)), ${} or [[ ]]
sed -iu "s/[0-9]\.[0-9]\.$oldminornum/1\.1\.$newminornum/" VERSION
#sed -iu "s/$oldminornum/$newminornum/g"  VERSION
rm -f VERSIONu
version=$(< VERSION)
echo "New Version:    $version"
echo "IMAGE  $IMAGE"
# Run build - Docker/Git Hub Username are defined in build
docker build --force-rm --no-cache -t "$IMAGE:latest" .
docker build --force-rm --no-cache -t "$IMAGE:$version" .

echo "Org-User Name  -  Image Name   -  Version number:    $HUBNAME/$IMAGE:$version"
docker tag  "$IMAGE:$version"  "$HUBNAME/$IMAGE:$version"
docker tag  "$IMAGE:$version"  "$HUBNAME/$IMAGE:latest"
#
git add -A
git commit -m "Version $version"
# Tag it
git tag -a "$version" -m "Version $version"
git push
git push --tags
echo "version   $version"
# Push it to dockerhub
docker push "$HUBNAME/$IMAGE:$version"
docker push "$HUBNAME/$IMAGE:latest"
