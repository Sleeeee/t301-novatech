#!/bin/sh

mkdir -p /dev/net

if [ ! -c /dev/net/tun ]; then
    echo "Creating /dev/net/tun device..."
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

exec "$@"
