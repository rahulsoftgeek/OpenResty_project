#!/bin/sh

ulimit -c unlimited

# change it on your project
OR_ROOT=/home/tweyseo/programs/openresty-1.17.8.2-debug
APP_NAME=HTTPTestServer

mkdir -p sbin
if [ ! -f sbin/$APP_NAME ]; then
    ln -s ${OR_ROOT}/nginx/sbin/nginx sbin/$APP_NAME
fi

if [ ! -f conf/nginx.conf ]; then
    echo -e "\033[41;33minvalid profile: "${PROFILE}"\033[0m"
    exit 1
fi

export PATH=$PATH:$(pwd):$(pwd)/sbin
