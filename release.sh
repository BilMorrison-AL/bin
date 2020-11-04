#!/usr/bin/env bash
set -eux
# REPO is either set to the organization name or your username
export REPO="angieslist"
#export REPO="williammorrisonal"
# Always make sure it is current
echo '---'
git pull
# Image name and version are pulled from files in the build directory: VERSION and NAME
version="$(< VERSION)"
name="$(< NAME)"
# Increment the minor version by one for every release
echo "Old Version:    $version"
docker images | grep "$name" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}
oldminornum=$(cut -d '.' -f3 VERSION)
newminornum=$(( $oldminornum + 1 ))
#   $((..)), ${} or [[ ]]
gsed -i "s/[0-9]\.[0-9]\.$oldminornum/1\.1\.$newminornum/" VERSION
#sed -iu "s/$oldminornum/$newminornum/g"  VERSION
#rm -f VERSIONu
version=$(< VERSION)
echo "Org-User Name  -  Image Name   -  Version number:    ${REPO}/${name}:${version}"
# Run build - Docker/Git Hub Username are defined in build
docker build --force-rm --no-cache -t "${REPO}/${name}:${version}" .
echo ''
echo "Org - Image - Version"
echo "${REPO}/${name}:${version}"
docker tag  "${REPO}/${name}:${version}"  "${REPO}/${name}:${version}"
docker tag  "${REPO}/${name}:latest"  "${REPO}/${name}:latest"
#
git add -A
git commit -m "Version $version"
# Tag it
git tag -a "$version" -m "Version $version"
git push
git push --tags
echo 'Push it to dockerhub'
docker push "${REPO}/${name}:latest"
