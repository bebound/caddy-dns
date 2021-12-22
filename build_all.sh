#!/bin/bash
PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7
docker build . -t bebound/caddy_builder --platform $PLATFORMS  -f Dockerfile_builder --push

build_with_all_dns(){
    dns_args=""
    for dns in $@
    do
        dns_args+="--with github.com/caddy-dns/$dns "
    done
    name=alldns
    version=$(date '+%Y.%m.%d')
    caddy_version=$(docker run --rm bebound/caddy_builder ./caddy version | cut -d ' ' -f 1 | xargs)
    final_tag=bebound/caddy-$name:$version"_"$caddy_version
    final_tag_no_version=bebound/caddy-$name
    echo Current valid version is $final_tag
    echo Building $final_tag
    docker build . -t $final_tag -t $final_tag_no_version --platform $PLATFORMS -f Dockerfile --build-arg DNS="$dns_args" --push
}

build_with_all_dns "alidns" "azure" "cloudflare" "digitalocean" "dnspod" "duckdns" "gandi" "googleclouddns" "hetzner" "ionos" "leaseweb" "loopia" "metaname" "namecheap" "namedotcom" "openstack-designate" "route53" "vercel" "vultr"
