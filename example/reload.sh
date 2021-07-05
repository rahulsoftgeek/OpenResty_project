#!/bin/sh

source ./env.sh

if [ ! -f tmp/nginx.pid ]; then
    echo -e "\033[41;33mno living OR application ["$APP_NAME"]\033[0m"
    exit 1
fi

mkdir -p logs & mkdir -p logs/old_logs & mkdir -p tmp

baklogs="logs/old_logs/$(date +'%Y%m%d_%H%M%S')"
mkdir -p ${baklogs}
mv ./logs/*.* ${baklogs}/

echo -e "\033[32mreload OR application ["$APP_NAME"]\033[0m"
kill -HUP $(cat $(pwd)/tmp/nginx.pid)