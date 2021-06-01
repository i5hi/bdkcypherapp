FROM rust:alpine

# how many cores to use with cargo install
ENV CPU_CORES=2

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

CMD [""]
