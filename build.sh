#!/bin/bash
PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7
docker build . -t bebound/caddy_builder --platform $PLATFORMS  -f Dockerfile_builder --push

build_with_dns(){
    name=$1
    repo=github.com/caddy-dns/$name
    caddy_version=$(docker run --rm bebound/caddy_builder ./caddy version | cut -d ' ' -f 1 | xargs)
    echo latest caddy version $caddy_version
    if [ ! -d $name ]; then
        git clone https://$repo
    fi
    cd $name
    version=$(git describe --abbrev=0 --tags)
    cd ../
    # always build image if no version
    if [ "$version" = "" ]; then
        version=$(date '+%Y.%m.%d')
    fi
    final_tag=bebound/caddy-$name:$version"_"$caddy_version
    final_tag_no_version=bebound/caddy-$name
    echo Current valid version is $final_tag
    docker manifest inspect $final_tag &> /dev/null
    if [ $? -ne 0 ] || [ "$FORCE_PUSH" = "true" ]; then
        echo Building $final_tag
        docker build . -t $final_tag -t $final_tag_no_version --platform $PLATFORMS -f Dockerfile --build-arg DNS="--with $repo" --push
    else
        echo "Already exists, skip build"
    fi
}

for i in "alidns" "azure" "cloudflare" "digitalocean" "dnspod" "duckdns" "gandi" "googleclouddns" "hetzner" "ionos" "leaseweb" "loopia" "metaname" "namecheap" "namedotcom" "openstack-designate" "powerdns" "route53" "transip" "vercel" "vultr"
do
    echo build $name
    build_with_dns $i
done
