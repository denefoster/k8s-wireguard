# ------------------------------------------------------------------------------
# Builder Stage
# ------------------------------------------------------------------------------
FROM golang:1.25.2-trixie AS build

WORKDIR /build
ADD util/* /build

RUN go install github.com/coredns/coredns@v1.13.1
RUN go build -o wg-http

# ------------------------------------------------------------------------------
# Release Stage
# ------------------------------------------------------------------------------
FROM debian:trixie-slim

RUN apt-get update && \
    apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    net-tools \
    wireguard \
    dnsutils \
    iptables \
    iproute2 \
    procps

RUN \
  apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=build /build/wg-http /usr/bin/wg-http

COPY --from=build /go/bin/coredns /usr/bin/coredns

ADD entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]
CMD ["wg-http"]
