FROM alpine:3.23

RUN apk update && apk add --no-cache openvpn vim

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/sh"]
