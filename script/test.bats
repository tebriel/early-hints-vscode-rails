#!/usr/bin/env bash

set -euo pipefail

HTTP_1_1_103_EARLY_HINTS="HTTP/1.1 103 Early Hints"
HTTP_2_103_EARLY_HINTS="HTTP/2 103"
NGX_HINTS_PATH="/up"
PUMA_HINTS_PATH="/home/index"

function test_http1_1_url() {
    URL=$1
    COUNT=$(curl "${URL}" --http1.1 -i --stderr - --silent | grep -c "${HTTP_1_1_103_EARLY_HINTS}")
    [ "$COUNT" -gt 0 ]
}

function test_http2_url() {
    URL=$1
    COUNT=$(curl "${URL}" --http2-prior-knowledge -i --stderr - --silent | grep -c "${HTTP_2_103_EARLY_HINTS}")
    [ "$COUNT" -gt 0 ]
}

### URLS
# 1. http://127.0.0.1:3000
# 2. http://127.0.0.1:8080
# 3. http://127.0.0.1:8081
# 4. http://127.0.0.1:8082
# 5. http://127.0.0.1:8091
# 6. http://127.0.0.1:8092
#
@test "puma early hints HTTP/1.1" {
    test_http1_1_url "http://127.0.0.1:3000${PUMA_HINTS_PATH}"
}

@test "nginx -> puma early hints HTTP/1.1" {
    test_http1_1_url "http://127.0.0.1:8080${PUMA_HINTS_PATH}"
}

@test "nginx -> puma early hints HTTP/2" {
    test_http2_url "http://127.0.0.1:8080${PUMA_HINTS_PATH}"
}

@test "nginx ngx_http_early_hints early hints HTTP/1.1" {
    test_http1_1_url "http://127.0.0.1:8080${NGX_HINTS_PATH}"
}

@test "nginx ngx_http_early_hints early hints HTTP/2" {
    test_http2_url "http://127.0.0.1:8080${NGX_HINTS_PATH}"
}

@test "haproxy -> puma early hints HTTP/1.1" {
    test_http1_1_url "http://127.0.0.1:8081${PUMA_HINTS_PATH}"
}

@test "haproxy -> puma early hints HTTP/2" {
    test_http2_url "http://127.0.0.1:8082${PUMA_HINTS_PATH}"
}

@test "haproxy -> nginx -> puma early hints HTTP/1.1" {
    test_http1_1_url "http://127.0.0.1:8091${PUMA_HINTS_PATH}"
}

@test "haproxy -> nginx -> puma early hints HTTP/2" {
    test_http2_url "http://127.0.0.1:8092${PUMA_HINTS_PATH}"
}

@test "haproxy -> nginx ngx_http_early_hints HTTP/1.1" {
    test_http1_1_url "http://127.0.0.1:8091${NGX_HINTS_PATH}"
}

@test "haproxy -> nginx ngx_http_early_hints HTTP/2" {
    test_http2_url "http://127.0.0.1:8092${NGX_HINTS_PATH}"
}
