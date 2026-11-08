# ------------------------------------------------------------------------------
# Builder Stage
# ------------------------------------------------------------------------------
FROM golang:1.25.2-trixie AS build

WORKDIR /build
ADD util/* /build

RUN go build -o wg-http

# ------------------------------------------------------------------------------
# Release Stage
# ------------------------------------------------------------------------------
FROM debian:trixie-slim
ARG COREDNS_VERSION=1.13.1


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

RUN curl -o coredns.tgz -L https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_`dpkg --print-architecture`.tgz && \
    tar -zxf coredns.tgz && \
    chmod +x coredns && \
    mv coredns /usr/bin/coredns && \
    rm coredns*

COPY --from=build /build/wg-http /usr/bin/wg-http

ADD entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]
CMD ["wg-http"]
