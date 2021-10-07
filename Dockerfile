FROM ubuntu:18.04

# TODO: curl or wget, but not both
RUN apt-get update && apt-get install -y musl-dev curl build-essential cmake wget git unzip ninja-build zlib1g-dev pkg-config

RUN mkdir -p /src/bloaty && \
    cd /src/bloaty && \
    wget https://github.com/google/bloaty/releases/download/v1.1/bloaty-1.1.tar.bz2 && \
    tar -xf bloaty-1.1.tar.bz2 && \
    cd bloaty-1.1 && \
    cmake -B build -G Ninja -S . && \
    cmake --build . && \
    cmake --build . --target install

# Setup rust for static builds
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --component rust-src -y && \
    . $HOME/.cargo/env && \
    rustup component add rust-std-x86_64-unknown-linux-musl && \

# Prime the Rust build cache with a primordial version of Shimlang. To make use
# of this, consumers of this image need to copy the latest changes onto /src/shimlang
# and build there. There's a risk that there's something here that causes the
# build to pass/fail when it shouldn't have. The simplicity of the commit chosen
# should help to reduce that risk.
RUN mkdir -p /src/shimlang && \
    cd /src/shimlang && \
    wget https://github.com/shmolyneaux/shimlang/archive/0bc5eaddd5d3f926377e2f9c200c006ae05ddce1.zip && \
    unzip main.zip && \
    cargo +nightly build --release -Z build-std=std,panic_abort -Z build-std-features=panic_immediate_abort --target x86_64-unknown-linux-musl
