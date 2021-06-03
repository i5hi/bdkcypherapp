FROM rust:alpine as builder

RUN apk add -u \
    build-base linux-headers zlib zlib-dev \
    ca-certificates \
    curl \
    unzip \
    git \
    jq \
    openssl openssl-dev \
    musl-dev gcc libffi-dev clang-libs clang libstdc++ libgcc cmake

RUN apk update


ENV CPU_CORES=5
ENV REPO="https://github.com/rajarshimaitra/bdk-cli"
ENV BRANCH="compact-filter"
ENV FEATURES="compiler,compact_filters"
ENV RUSTFLAGS="-Ctarget-feature=-crt-static"

RUN cargo install -j $CPU_CORES --git $REPO --branch $BRANCH --features=$FEATURES

FROM alpine as execution

RUN apk add -u \
    libstdc++ libgcc cmake

RUN apk update

COPY --from=builder /usr/local/cargo/bin/bdk-cli /cli

VOLUME ["/.bdk-bitcoin"]

ENTRYPOINT ["./cli"]

