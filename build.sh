#!/bin/bash
# docker buildx install
# PLATFORMS=linux/arm64,linux/amd64,linux/riscv64,linux/ppc64le,linux/s390x,linux/386,linux/arm/v7,linux/arm/v6
# docker build . -t caddy_builder --platform $PLATFORMS  -f Dockerfile_builder
docker build . -t caddy_builder  -f Dockerfile_builder

name='dnspod'
repo=github.com/caddy-dns/$name
caddy_version=$(docker run -it --rm caddy_builder ./caddy version | cut -d ' ' -f 1)
if [ ! -d $name ]; then
  git clone https://$repo
fi
cd $name
version=$(git describe --abbrev=0 --tags)
cd ../
final_tag=bebound/caddy-$name:$caddy_version"_"$version
final_tag_no_version=bebound/caddy-$name
echo Current valid version is $final_tag
docker manifest inspect $final_tag &> /dev/null
if [ $? -ne 0 ]; then
  echo Building $final_tag
  docker build . -t $final_tag -t $final_tag_no_version --platform $PLATFORMS -f Dockerfile --build-arg DNS=$repo
  docker push $final_tag
  docker push $final_tag_no_version
else
  echo "Already exists, skip build"
fi
#  docker run -it -p 80:80  --rm caddy ./caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
