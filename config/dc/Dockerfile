FROM alpine:3.23

RUN apk update && apk add --no-cache dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 67/udp 53/udp 53/tcp
CMD ["/usr/sbin/dnsmasq", "--keep-in-foreground"]
