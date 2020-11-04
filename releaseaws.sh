#!/usr/bin/env bash
set -eux
echo '---'
PATH="${HOME}/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Repo name for aws not using Dockerhub
REPO="894680052389.dkr.ecr.us-east-1.amazonaws.com"
echo '---'
# Always make sure it is current
ALPROFILE=' --profile sysops-permission-set-894680052389 '
# Pull down any changes from remote origin
## git pull
echo "AWS Version"
aws ${ALPROFILE}--version
export AWS_PAGER=""
# Make sure connected to AWS
#   "${AL}"
#$(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
#aws sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
#aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${REPO}"

# If this fails, then manually run -> aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 894680052389.dkr.ecr.us-east-1.amazonaws.com

#AWSTOKEN="$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPO})"
echo ''
#echo "$AWSTOKEN" | docker login -u AWS --password-stdin "$REPO"

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
docker build --force-rm --no-cache -t "${REPO}/${name}:${version}" .
echo ''
echo "Org - Image - Version"
echo "${REPO}/${name}:${version}"

#docker tag "$name:$version" "${REPO}/${name}:${version}"
#docker tag "${name}":latest "${REPO}/${name}":latest
docker tag "${REPO}/${name}":${version} "${REPO}/${name}:${version}"
docker tag "${REPO}/${name}":latest "${REPO}/${name}:latest"

echo ''
echo 'Git add commit push'
git add -A
git commit -m "Version ${version}"
# Tag it
git tag -a "${version}" -m "Version ${version}"
git push
git push --tags

echo "Push Container Image  ${version}  to  ${REPO}"
echo 'Push it to ECR'
# docker push "${REPO}/${name}:${version}"
docker push "${REPO}/${name}":latest
#
printf '[{"name":"${name}","imageUri":"%s"}]' "${REPO}/${name}:${version}" > ./imagedefinitions.json
