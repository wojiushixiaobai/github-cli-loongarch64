FROM golang:1.22-buster as builder

RUN set -ex \
    && apt-get update \
    && apt-get install -y rpm reprepro \
    && rm -rf /var/lib/apt/lists/*

ARG GORELEASER_VERSION=latest

RUN set -ex; \
    go install github.com/goreleaser/goreleaser@${GORELEASER_VERSION}

ARG CLI_VERSION=v2.51.0
ENV CLI_VERSION=${CLI_VERSION}

ARG WORKDIR=/opt/cli

RUN set -ex; \
    git clone -b ${CLI_VERSION} --depth=1 https://github.com/cli/cli ${WORKDIR}

ADD .goreleaser.yml /opt/.goreleaser.yml
WORKDIR ${WORKDIR}

RUN set -ex; \
    goreleaser --config /opt/.goreleaser.yml release --skip-publish --clean

FROM debian:buster-slim

WORKDIR /opt/cli

COPY --from=builder /opt/cli/dist /opt/cli/dist

VOLUME /dist

CMD cp -rf dist/* /dist/