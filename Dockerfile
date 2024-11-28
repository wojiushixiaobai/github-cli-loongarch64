FROM cr.loongnix.cn/library/golang:1.22-buster as builder

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && apt-get update \
    && apt-get install -y rpm reprepro \
    && rm -rf /var/lib/apt/lists/*

ARG GORELEASER_VERSION=latest

RUN --mount=type=cache,target=/go/pkg/mod \
    set -ex; \
    go install github.com/goreleaser/goreleaser@${GORELEASER_VERSION}

ARG CLI_VERSION=v2.63.0
ENV CLI_VERSION=${CLI_VERSION}

ARG WORKDIR=/opt/cli

RUN set -ex; \
    git clone -b ${CLI_VERSION} --depth=1 https://github.com/cli/cli ${WORKDIR}

ADD .goreleaser.yml /opt/.goreleaser.yml
WORKDIR ${WORKDIR}

RUN --mount=type=cache,target=/go/pkg/mod \
    set -ex; \
    goreleaser --config /opt/.goreleaser.yml release --skip-publish --clean

FROM cr.loongnix.cn/library/debian:buster-slim

WORKDIR /opt/cli

COPY --from=builder /opt/cli/dist /opt/cli/dist

VOLUME /dist

CMD cp -rf dist/* /dist/