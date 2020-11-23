#!/usr/bin/env bash
set -eu
#set -eux

# REPO is either set to the organization name or your username
export REPO="williammorrisonal"
#export REPO="williammorrisonal"
# Always make sure it is current
docker stats --no-stream || exit 1
echo '---'

# Image name and version are pulled from files in the build directory: VERSION and NAME
version="$(< VERSION)"
name="$(< NAME)"
#echo "Old Version:    $version"
#docker images | grep "$name" | grep "$version" | awk '{print $3}'| xargs -I {} docker rmi -f {}

# Increment the minor version by one for every release
oldminornum=$(cut -d '.' -f3 VERSION)
newminornum=$(( $oldminornum + 1 ))
#   $((..)), ${} or [[ ]]
# Bump Version number in VERSION file
gsed -i "s/[0-9]\.[0-9]\.$oldminornum/1\.1\.$newminornum/" VERSION
#sed -iu "s/$oldminornum/$newminornum/g"  VERSION
#rm -f VERSIONu
# Set variable version to new value
version=$(< VERSION)

echo "Build with Repo-Image-Version: ${REPO}/${name}:${version}"
# Run build - Docker/Git Hub Username are defined in build
#docker build --force-rm --no-cache -t "${REPO}/${name}:${version}" -t "${REPO}/${name}:latest" .
docker build --force-rm --no-cache -t "${name}:${version}" -t "${name}:latest" .

echo '   '
echo '---'
echo "Org - Image - Version"
echo "${REPO}/${name}:${version}"

echo 'Docker Tag and Push to Dockerhub'
for st in {$version,latest}; do
    docker tag ${name}:${st} ${REPO}/${name}:${st}
    docker push ${REPO}/${name}:${st}
done

echo '   '
echo '---'

#docker tag  "${REPO}/${name}:${version}"  "${REPO}/${name}:${version}"
#docker tag  "${REPO}/${name}:latest"  "${REPO}/${name}:latest"
#docker push "${REPO}/${name}:latest"
#
echo "GIT commit and tag"
git add -A
git commit -m "Version $version"
git tag -a "$version" -m "Version $version"
git push
git push --tags
