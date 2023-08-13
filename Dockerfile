FROM alpine:3.15
COPY entrypoint.sh /
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update \
    && apk add iodine iptables bash \
    && chmod +x /entrypoint.sh

ENV PASSWORD=""
ENV NETWORK="10.0.0.1"
ENV DOMAIN=""
ENV MTU=""
ENV DEV_TUNNEL=""
ENV FORCE_DNS_TUNNEL="false"
ENV LOG_LEVEL="0"
ENV FORWARD_DEST=""
ENV DNS_TYPE=""
ENV MAX_INTERVAL=""
ENV LAZY_MODE="false"
ENV DNS_SERVER="8.8.8.8"
ENV HOSTNAME_SIZE=""
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD [ "server" ]
