FROM rust:alpine as builder

RUN apk add -u \
    build-base linux-headers zlib zlib-dev \
    ca-certificates \
    curl \
    unzip \
    git \
    jq \
    openssl openssl-dev \
    musl-dev gcc libffi-dev clang-libs

RUN apk update

RUN git config --global core.eol lf && \
    git config --global core.autocrlf input

ENV CPU_CORES=3
ENV REPO="https://github.com/bitcoindevkit/bdk-cli"
ENV BRANCH="master"
ENV FEATURES="compiler"
ENV RUSTFLAGS="-C target-feature=+crt-static"

RUN cargo install -j $CPU_CORES --git $REPO --branch $BRANCH --features=$FEATURES --target x86_64-unknown-linux-musl

FROM scratch as execution

COPY --from=builder /usr/local/cargo/bin/bdk-cli /cli

ENTRYPOINT ["./cli"]

# docker build -t bdk .
# docker run bdk help

# sniper extensions:
# echo "alias bcli='docker run bdk'" >> ~/.bashrc && source ~/.bashrc
# bcli help 

# Have fun :)
