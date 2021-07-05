#!/bin/sh

source ./env.sh

if [ -f tmp/nginx.pid ]; then
    echo -e "\033[41;33mduplicate OR application ["$APP_NAME"], see "$(pwd)"/tmp/nginx.pid\033[0m"
    exit 1
fi

mkdir -p logs & mkdir -p logs/old_logs & mkdir -p tmp

baklogs="logs/old_logs/$(date +'%Y%m%d_%H%M%S')"
mkdir -p ${baklogs}
mv ./logs/*.* ${baklogs}/

echo -e "\033[32mstart OR application ["$APP_NAME"]\033[0m"
$APP_NAME -p $(pwd)/ -c conf/nginx.conf