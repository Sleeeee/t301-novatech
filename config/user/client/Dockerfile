FROM alpine:3.23

RUN apk update && apk add --no-cache curl

ENV http_proxy=http://10.2.8.1:8888
ENV https_proxy=http://10.2.8.1:8888
ENV no_proxy="localhost,127.0.0.1,10.0.0.0/8,10.16.0.0/12,*.novatech.lab"

CMD ["/bin/sh"]
