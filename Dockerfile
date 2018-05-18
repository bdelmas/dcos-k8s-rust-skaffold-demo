FROM rustlang/rust:nightly

WORKDIR /usr/src/rust-web-demo

COPY Cargo.toml Cargo.toml

RUN mkdir src/

RUN echo "extern crate rocket;\nfn main() {}" > src/main.rs

RUN cargo build --release

RUN rm -rf src/

COPY . .

RUN rm -f target/release/rust-web-demo

RUN cargo build --release

RUN cargo install --path .

WORKDIR /

RUN rm -rf /usr/src/rust-web-demo

CMD ["rust-web-demo"]
