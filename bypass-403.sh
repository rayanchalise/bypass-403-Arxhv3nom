#!/bin/bash

# Function to print messages in green
print_success() {
    echo -e "\033[0;32m$1\033[0m"  # Green
}

# Function to print messages in red
print_failure() {
    echo -e "\033[0;31m$1\033[0m"  # Red
}

# Check if exactly one argument (the full URL) is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <full_url>"
    exit 1
fi

# Define full URL
url="$1"

# Define function to test and print results
test_url() {
    local payload="$1"
    local description="$2"

    local response_code
    response_code=$(curl -k -s -o /dev/null -iL -w "%{http_code}" "$url$payload")

    if [[ "$response_code" == "200" || "$response_code" == "301" || "$response_code" == "302" ]]; then
        print_success "$description: $response_code"
    else
        print_failure "$description: $response_code"
    fi
}

# List of payloads with descriptions
test_url "%5c" "Backslash"
test_url "%2F" "Forward Slash"
test_url "+" "Plus"
test_url "" "Range Header: bytes=0-10" "-H 'Range: bytes=0-10'"
test_url "" "Accept-Encoding Header: gzip,deflate" "-H 'Accept-Encoding: gzip,deflate'"
test_url "" "X-Original-Host Header: malicious.com" "-H 'X-Original-Host: malicious.com'"
test_url "\`" "Backtick"
test_url "" "PATCH Method" "-X PATCH"
test_url "" "Authorization Header: Bearer some_token" "-H 'Authorization: Bearer some_token'"
test_url "%09" "Tab"
test_url "%00" "Null Byte"
test_url ",%00" "Comma Null Byte"
test_url "/..//..//" "Directory Traversal"
test_url "/?v=1/" "Query String"
test_url "" "Connection Upgrade Header" "-H 'Connection: Upgrade' -H 'Upgrade: websocket'"
test_url "" "If-None-Match Header: some-etag-value" "-H 'If-None-Match: some-etag-value'"
test_url "~" "Tilde"
test_url "" "X-Forwarded-Proto Header: https" "-H 'X-Forwarded-Proto: https'"
test_url "" "Accept Header: */*" "-H 'Accept: */*'"
test_url "" "Expect Header: 100-continue" "-H 'Expect: 100-continue'"
test_url "" "Referer Header: http://localhost" "-H 'Referer: http://localhost'"
test_url "" "Host Header: 127.0.0.1" "-H 'Host: 127.0.0.1'"
test_url "." "Dot"
test_url ";/" "Semicolon Slash"
test_url "" "GET Method" "-X GET"
test_url "?" "Query Parameter"
test_url "" "Cookie Header: cookie=" "-b 'cookie='"
test_url "" "OPTIONS Method" "-X OPTIONS"
test_url "" "Origin Header: http://trusted.com" "-H 'Origin: http://trusted.com'"
test_url "" "X-Forwarded-For Header: 127.0.0.1" "-H 'X-Forwarded-For: 127.0.0.1'"
test_url "" "User-Agent Header: ''" "-A ''"
test_url "%2520" "Encoded Space"
test_url "" "HEAD Method" "-X HEAD"
test_url "" "Transfer-Encoding Header: chunked" "-H 'Transfer-Encoding: chunked'"
test_url "%23" "Hash"
test_url "" "Proxy-Authorization Header: Basic dXNlcjpwYXNz" "-H 'Proxy-Authorization: Basic dXNlcjpwYXNz'"
test_url "http://subdomain.$url" "Subdomain"
test_url "%7C" "Pipe"
test_url "" "Authorization Header: Bearer fake_token" "-H 'Authorization: Bearer fake_token'"
test_url "" "Host Header: [::1]" "-H 'Host: [::1]'"
test_url "%26" "Ampersand"
test_url "" "Content-Type Header: application/json" "-H 'Content-Type: application/json' -H 'Accept: application/json'"
test_url "%2C" "Comma"
test_url "" "X-HTTP-Method-Override Header: PUT" "-H 'X-HTTP-Method-Override: PUT'"
test_url "/" "Trailing Slash"


for payload in "${curl_payloads[@]}"; do
    response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" $payload)
    echo "$response  --> $payload"
done
