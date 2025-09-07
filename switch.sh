#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: ./switch.sh [blue|green]"
    exit 1
fi

sed -i "s/proxy_pass http:\/\/.*;/proxy_pass http:\/\/$1;/" nginx/downhill.conf
docker compose exec load-balancer nginx -s reload
echo "Switched to $1 deployment"