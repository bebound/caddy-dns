#!/bin/bash
#PLATFORMS=linux/amd64,linux/arm64
PLATFORMS=linux/amd64
docker build . -t bebound/xcaddy_builder --platform $PLATFORMS  -f Dockerfile_builder --push

func build_dns(){
    name=$1
    repo=github.com/caddy-dns/$name
    caddy_version=$(docker run -it --rm bebound/caddy_builder ./caddy version | cut -d ' ' -f 1)
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
        docker build . -t $final_tag -t $final_tag_no_version --platform $PLATFORMS -f Dockerfile --build-arg DNS=$repo --push
    else
        echo "Already exists, skip build"
    fi
}

#  docker run -it -p 80:80  --rm caddy ./caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
for i in "alidns" "azure" "cloudflare" "digitalocean" "dnspd" "duckdns" "dynv6" "gandi" "googleclouddns" "hetzner" "ionos" "leaseweb" "loopia" "metaname" "namecheap" "namedotcom" "openstack-designate" "powerdns" "route53" "transip" "vercel" "vultr"
do
    echo build $name
    build $i
done