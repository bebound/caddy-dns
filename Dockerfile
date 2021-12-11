FROM --platform=$BUILDPLATFORM caddy_builder as builder
ARG DNS
RUN xcaddy build --with $DNS

FROM scratch
WORKDIR /caddy/
COPY --from=builder /go/caddy ./
COPY ./Caddyfile /etc/caddy/Caddyfile
COPY ./index.html /usr/share/caddy/index.html
EXPOSE 80
EXPOSE 443
EXPOSE 2019

CMD ["./caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]