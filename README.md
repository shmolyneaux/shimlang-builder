# shimlang-builder

A Docker image that provides a reproducible build environment for the [shimlang](https://github.com/shmolyneaux/shimlang) programming language. It bundles Rust nightly (with musl target for static linking), Google's [Bloaty](https://github.com/google/bloaty) for binary size analysis, and primes the Rust build cache with an early shimlang commit to speed up subsequent builds.

## Building the Image

```sh
docker build -t shimlang-builder .
```

## Usage

The image is intended to be used as a base for building shimlang. Copy your latest shimlang source into the container and build:

```dockerfile
FROM shimlang-builder

COPY . /src/shimlang
WORKDIR /src/shimlang
RUN . $HOME/.cargo/env && \
    cargo +nightly build --release \
      -Z build-std=std,panic_abort \
      -Z build-std-features=panic_immediate_abort \
      --target x86_64-unknown-linux-musl
```

Use `bloaty` (pre-installed) to inspect the resulting binary size:

```sh
bloaty target/x86_64-unknown-linux-musl/release/shimlang
```

## Features

- **Static linking via musl** — produces fully static Linux binaries with no runtime dependencies.
- **Small binary size** — uses Rust nightly `build-std` with `panic_immediate_abort` to strip unnecessary code.
- **Binary size profiling** — includes Bloaty v1.1 for inspecting what contributes to binary size.
- **Build cache priming** — pre-builds an early shimlang commit so incremental builds are faster.

## Limitations

- Targets **x86_64-unknown-linux-musl** only; other architectures and platforms are not supported.
- Based on **Ubuntu 18.04**, which is end-of-life and may have outdated system packages.
- Requires **Rust nightly**; builds may break if nightly introduces breaking changes.
- The primed build cache is based on a specific early commit and may not always accelerate builds if shimlang's dependency tree has changed significantly.

## History

Development on shimlang-builder was active on 2021-10-06, with no further changes after that date:

- 2021-10-06 — Initial commit with repository scaffolding (README)
- 2021-10-06 — Added Dockerfile with Ubuntu 18.04 base, Rust nightly + musl toolchain, Bloaty v1.1, and shimlang build cache priming