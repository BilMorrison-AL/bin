#!/usr/bin/env bash
set -eu

# Instructions on how to push from AWS
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 894680052389.dkr.ecr.us-east-1.amazonaws.com
# docker build -t ops/audit-jenkins .
# docker tag ops/audit-jenkins:latest 894680052389.dkr.ecr.us-east-1.amazonaws.com/ops/audit-jenkins:latest
# docker push 894680052389.dkr.ecr.us-east-1.amazonaws.com/ops/audit-jenkins:latest
docker stats --no-stream || exit 1
echo '---'

# Repo name for aws not using Dockerhub
REPONAME="894680052389.dkr.ecr.us-east-1.amazonaws.com"
echo '---'
# Always make sure it is current
ALPROFILE=" --profile sysops-permission-set-894680052389 "
AWS_DEFAULT_REGION="us-east-1"
# Pull down any changes from remote origin
## git pull
echo "AWS Version"
aws ${ALPROFILE} --version
export AWS_PAGER=""
# Make sure connected to AWS
#   "${AL}"
## export ECR="$(aws ecr get-login --region $AWS_DEFAULT_REGION)"

aws --profile sysops-permission-set-894680052389 sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
aws --profile sysops-permission-set-894680052389 ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${REPONAME}"

# If this fails, then manually run -> aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 894680052389.dkr.ecr.us-east-1.amazonaws.com

#AWSTOKEN="$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPONAME})"
echo ''
## echo "${ECR}" | docker login -u AWS --password-stdin "$REPONAME"

# Image name and version are pulled from files in the build directory: VERSION and NAME
version="$(< VERSION)"
name="$(< NAME)"
echo "Old Version:    $version"
oldminornum=$(cut -d '.' -f3 VERSION)
newminornum=$(( $oldminornum + 1 ))
# Increment the minor version by one for every release
gsed -i "s/[0-9]\.[0-9]\.$oldminornum/1\.1\.$newminornum/" VERSION
#sed -iu "s/$oldminornum/$newminornum/g"  VERSION ; rm -f VERSION
echo ''
version=$(< VERSION)
echo "New Version  ${name}   :  ${version}"
echo ''
#docker build --force-rm --no-cache -t "${REPONAME}/${name}:${version}" -t "${REPONAME}/${name}:latest" -t "${name}:${version}" -t "${name}:latest" .
#docker build --force-rm --no-cache -t "${name}:latest" -t "${name}:${version}" .
echo ' '
#docker tag "$name:$version" "${REPONAME}/${name}:${version}"
#docker tag "${name}":latest "${REPONAME}/${name}":latest
#docker tag "${name}:${version}" "${REPONAME}/${name}:${version}"
#docker tag "${REPONAME}/${name}:${version}" "${REPONAME}/${name}:latest"
#printf '[{"name":"${name}","imageUri":"%s"}]' "${REPONAME}/${name}:${version}" > ./imagedefinitions.json

echo ''
echo ''
#docker images | grep "$name" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}
echo -n "Org - Image - Version"
echo "${REPONAME}/${name}:${version}"
echo ''
echo 'Build latest version'
#docker build -t "${name}:${version}" -t "${name}:latest" -t "${REPONAME}/${name}:${version}" -t "${REPONAME}/${name}:latest" .
#docker build --squash -t "${name}:${version}" -t "${name}:latest" .
docker build --force-rm --no-cache -t "${name}:${version}" -t "${name}:latest" .
echo ''
echo ''
echo "Tag and Push Container Image  ${version}  to  ${REPONAME}"
for st in {$version,latest}; do
    docker tag ${name}:${st} ${REPONAME}/${name}:${st}
    docker push ${REPONAME}/${name}:${st}
done


#docker tag "${REPONAME}/${name}:${version}" "${REPONAME}/${name}:${version}"
#docker push "${REPONAME}/${name}:${version}"
#docker push "${REPONAME}/${name}:latest"
#
echo ' '
echo 'Git add commit push'
git add -A
git commit -m "Version ${version}"
# Tag it
git tag -a "${version}" -m "Version ${version}"
git push
git push --tags
#
echo 'DONE'
#

