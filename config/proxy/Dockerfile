FROM alpine:3.23

RUN apk update && apk add --no-cache tinyproxy
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

EXPOSE 8888
CMD ["/usr/bin/tinyproxy", "-d"]
