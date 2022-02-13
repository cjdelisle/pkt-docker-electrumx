FROM python:3.9.10-alpine3.15
LABEL maintainer="James P. Thomas <james@jamespthomas.com>"
  
COPY ./bin /usr/local/bin
COPY ./VERSION /tmp
                                                                                                      
ARG BUILD_DEPS="git build-base linux-headers cmake"
ARG DEPS="openssl leveldb-dev"
ARG ROCKS_DEPS="bzip2-dev gflags-dev lz4-dev snappy-dev zlib-dev zstd-dev"
RUN VERSION=$(cat /tmp/VERSION) && \
    chmod a+x /usr/local/bin/* && \
    apk add --no-cache $BUILD_DEPS $DEPS $ROCKS_DEPS && \
    git clone https://github.com/facebook/rocksdb && \
    cd rocksdb && git checkout df4d3cf6fd52907f9a9a9bb62f124891787610eb && \
    mkdir build && cd build && cmake .. && \
    PORTABLE=1 make -j$(nproc) && \
    make install && \
    cd ../../ && \
    pip install aiohttp pylru plyvel websockets python-rocksdb && \
    git clone https://github.com/thomasjp0x42/electrumx.git && \
    cd electrumx && \
    git checkout $VERSION && \
    python setup.py install && \
    apk del $BUILD_DEPS && \
    rm -rf /tmp/*

VOLUME ["/data"]
ENV HOME /data
ENV ALLOW_ROOT 1
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:64766,ssl://:64767,wss://:64719,rpc://0.0.0.0:8252
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx.key

ENV COIN=PKT
ENV DB_ENGINE=rocksdb
ENV LOG_LEVEL=debug
ENV PEER_ANNOUNCE=on
ENV CACHE_MB=1000

ENV HOST ""
WORKDIR /data

EXPOSE 64766 64767 64719 8252

CMD ["init"]