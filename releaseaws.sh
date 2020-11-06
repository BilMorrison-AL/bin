#!/usr/bin/env bash
set -eux
# Instructions on how to push from AWS
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 894680052389.dkr.ecr.us-east-1.amazonaws.com
# docker build -t ops/audit-jenkins .
# docker tag ops/audit-jenkins:latest 894680052389.dkr.ecr.us-east-1.amazonaws.com/ops/audit-jenkins:latest
# docker push 894680052389.dkr.ecr.us-east-1.amazonaws.com/ops/audit-jenkins:latest
echo '---'
PATH="${HOME}/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Repo name for aws not using Dockerhub
REPO="894680052389.dkr.ecr.us-east-1.amazonaws.com"
echo '---'
# Always make sure it is current
ALPROFILE=' --profile sysops-permission-set-894680052389 '
AWS_DEFAULT_REGION='us-east-1'
# Pull down any changes from remote origin
## git pull
echo "AWS Version"
aws ${ALPROFILE}--version
export AWS_PAGER=""
# Make sure connected to AWS
#   "${AL}"
## export ECR="$(aws ecr get-login --region $AWS_DEFAULT_REGION)"
#aws sts get-caller-identity | grep '894680052389' && echo 'Yes aws sso logged in' || echo "Need to run > aws sso login"
#REPO="894680052389.dkr.ecr.us-east-1.amazonaws.com" && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${REPO}"

# If this fails, then manually run -> aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 894680052389.dkr.ecr.us-east-1.amazonaws.com

#AWSTOKEN="$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPO})"
echo ''
## echo "${ECR}" | docker login -u AWS --password-stdin "$REPO"

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
#sed -iu "s/$oldminornum/$newminornum/g"  VERSION ; rm -f VERSION
echo ''
version=$(< VERSION)
echo "New Version  ${name}   :  ${version}"
echo ''
#docker build --force-rm --no-cache -t "${REPO}/${name}:${version}" -t "${REPO}/${name}:latest" -t "${name}:${version}" -t "${name}:latest" .
#docker build --force-rm --no-cache -t "${name}:latest" -t "${name}:${version}" .
echo ' '
#docker tag "$name:$version" "${REPO}/${name}:${version}"
#docker tag "${name}":latest "${REPO}/${name}":latest
#docker tag "${name}:${version}" "${REPO}/${name}:${version}"
#docker tag "${REPO}/${name}:${version}" "${REPO}/${name}:latest"

echo ' '
echo 'Git add commit push'
git add -A
git commit -m "Version ${version}"
# Tag it
git tag -a "${version}" -m "Version ${version}"
git push
git push --tags


echo ''
echo "Org - Image - Version"
echo "${REPO}/${name}:${version}"
echo 'Build latest version'
docker build -t "${REPO}/${name}:${version}" -t "${REPO}/${name}:latest" .
echo ''
echo ''
echo "Tag and Push Container Image  ${version}  to  ${REPO}"
for st in {$version,latest}; do
    docker tag ${REPO}/${name} ${REPO}/${name}:${st}
    docker push ${REPO}/${name}:${st}
done


#docker tag "${REPO}/${name}:${version}" "${REPO}/${name}:${version}"
#docker push "${REPO}/${name}:${version}"
#docker push "${REPO}/${name}:latest"
#
printf '[{"name":"${name}","imageUri":"%s"}]' "${REPO}/${name}:${version}" > ./imagedefinitions.json
#
echo 'DONE'
#
