#!/bin/sh

url="http://localhost:3030/"

status_code=$(wget --server-response --spider --quiet "$url" 2>&1 | grep "HTTP/" | awk '{print $2}' | head -n 1)

if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 401 ]; then
    exit 0
else
    exit 1
fi
