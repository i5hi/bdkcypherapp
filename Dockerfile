FROM rust:alpine as builder

# how many cores to use with cargo install
ENV CPU_CORES=4

RUN apk add -u \
    ca-certificates \
    curl \
    unzip \
    git \
    jq \
    openssl openssl-dev \
    musl-dev gcc libffi-dev

RUN apk update

RUN cargo install -j $CPU_CORES --git https://github.com/bitcoindevkit/bdk-cli --features="compiler,esplora"

# RUN ln -s $(which bdk-cli) /usr/bin/cli

# Create the execution container
FROM alpine as execution

COPY --from=builder /usr/local/cargo/bin/bdk-cli /usr/bin/cli

CMD [""]


