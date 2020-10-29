#!/bin/bash
set -eux
# Repo name for aws not using Dockerhub
REPO="894680052389.dkr.ecr.us-east-1.amazonaws.com"
# Always make sure it is current
git pull
# Make sure connected to AWS
export AWS_PAGER=""
aws --version
#$(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
aws sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
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
#rm -f VERSION
version=$(< VERSION)
echo "New Version  ${name}   :  ${version}"
echo ''
# Run build - Docker/Git Hub Username are defined in build
#docker build --force-rm --no-cache -t "${REPO}/${name}:${version}" .
docker build --force-rm --no-cache -t "${REPO}/${name}:latest" .
echo ''
echo "Org - Image - Version"
echo "${REPO}/${name}:${version}"
#docker tag "$name:$version" "${REPO}/${name}:${version}"
docker tag "${REPO}/${name}:latest" "${REPO}/${name}:${version}"
#
git add -A
git commit -m "Version ${version}"
# Tag it
git tag -a "${version}" -m "Version ${version}"
git push
git push --tags
echo "version   ${version}"
# Push it to dockerhub
docker push "${REPO}/${name}:${version}"
docker push "${REPO}/${name}:latest"
#
printf '[{"name":"${name}","imageUri":"%s"}]' "${REPO}/${name}:${version}" > ./imagedefinitions.json
