#!/bin/sh

source ./env.sh

if [ ! -f tmp/nginx.pid ]; then
    echo -e "\033[41;33mno living OR application ["$APP_NAME"]\033[0m"
    exit 1
fi

echo -e "\033[32mstop OR application ["$APP_NAME"]\033[0m"
$APP_NAME -s quit -p $(pwd)/ -c conf/nginx.conf