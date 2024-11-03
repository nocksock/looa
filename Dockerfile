FROM alpine:3.12

# Install all required packages
RUN apk add --no-cache \
    lua5.1 \
    lua5.1-dev \
    luarocks5.1 \
    build-base \
    git \
    entr \
    curl \
    readline-dev \
    && luarocks-5.1 install busted \
    && luarocks-5.1 install luafilesystem

WORKDIR /app

COPY ./watch-tests.sh /usr/local/bin/watch-tests
RUN chmod +x /usr/local/bin/watch-tests

# Link busted to ensure it's in PATH
RUN ln -s /usr/local/bin/busted /usr/bin/busted

ENTRYPOINT [ "watch-tests" ]
