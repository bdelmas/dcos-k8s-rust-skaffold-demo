FROM rustlang/rust:nightly

# Update packages and install tools
RUN apt-get update -y && apt-get install -y wget git gcc g++ unzip make pkg-config

RUN apt-get update \
    && apt-get install -y \
       curl \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION 1.8.6

RUN curl -sSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    CHECKSUM=f558c91c2f6aac7222e0bd83e6dd595b8fac85aaa96e55d15229542eb4aaa1ff && \
    echo "${CHECKSUM}  /tmp/go.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -vxzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go:/go/src/app/_gopath

RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

#COPY third_party/go-wrapper/go-wrapper /usr/local/bin/go-wrapper
#RUN chmod 755 /usr/local/bin/go-wrapper

RUN ln -s /go/src/app /app
WORKDIR /go/src/app

LABEL go_version=$GO_VERSION


# Install cmake 3.2
WORKDIR /tmp/cmake
RUN wget http://www.cmake.org/files/v3.9/cmake-3.9.6.tar.gz && tar xf cmake-3.9.6.tar.gz && cd cmake-3.9.6 && ./configure && make && make install

WORKDIR /
# Make sure you grab the latest version
RUN curl -OL https://github.com/google/protobuf/releases/download/v3.6.0/protoc-3.6.0-linux-x86_64.zip
# Unzip
RUN unzip protoc-3.6.0-linux-x86_64.zip -d protoc3
# Move protoc to /usr/local/bin/
RUN mv protoc3/bin/* /usr/local/bin/
# Move protoc3/include to /usr/local/include/
RUN mv protoc3/include/* /usr/local/include/

WORKDIR /usr/src/rust-web-demo

COPY Cargo.toml Cargo.toml

RUN mkdir src/

RUN echo "extern crate rocket;\nfn main() {}" > src/main.rs

# Me
COPY build.rs build.rs
COPY src/protos src/protos

# Me
RUN cargo update

RUN cargo build --release

RUN rm -rf src/

COPY . .

RUN rm -f target/release/rust-web-demo

# Me
RUN cargo update

RUN cargo build --release

RUN cargo install --path .

WORKDIR /

RUN rm -rf /usr/src/rust-web-demo

CMD ["rust-web-demo"]
