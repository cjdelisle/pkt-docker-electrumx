FROM python:3.9.10-alpine3.15
LABEL maintainer="James P. Thomas <james@jamespthomas.com>"

COPY ./bin /usr/local/bin
COPY ./VERSION /tmp

RUN VERSION=$(cat /tmp/VERSION) && \
    chmod a+x /usr/local/bin/* && \
    apk add --no-cache git build-base openssl && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.15/main leveldb-dev && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing rocksdb-dev && \
    pip install aiohttp pylru plyvel websockets python-rocksdb && \
    git clone https://github.com/thomasjp0x42/electrumx.git && \
    cd electrumx && \
    git checkout $VERSION && \
    python setup.py install && \
    apk del git build-base && \
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
