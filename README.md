# early-hints-vscode-rails

This is to test if we can use early hints:

1. In NGINX
2. In Rails
3. Forwarding through the VSCode Exposed Port Proxy
4. Forwarding from puma -> nginx -> haproxy (like production)

## Setup

`devenv up` will launch nginx, haproxy, and the rails server.

## Test

`bats script/test.bats` will run the test suite, showing which cases succeed with early hints.

### Most Recent Output (2024-11-15)

test.bats
✓ puma early hints HTTP/1.1
✓ nginx -> puma early hints HTTP/1.1
✗ nginx -> puma early hints HTTP/2
(from function `test_http2_url' in file script/test.bats, line 18,
    in test file script/test.bats, line 39)
     `test_http2_url "http://127.0.0.1:8080${PUMA_HINTS_PATH}"' failed
✓ nginx ngx_http_early_hints early hints HTTP/1.1
✗ nginx ngx_http_early_hints early hints HTTP/2
(from function `test_http2_url' in file script/test.bats, line 18,
    in test file script/test.bats, line 47)
     `test_http2_url "http://127.0.0.1:8080${NGX_HINTS_PATH}"' failed
✓ haproxy -> puma early hints HTTP/1.1
✓ haproxy -> puma early hints HTTP/2
✓ haproxy -> nginx -> puma early hints HTTP/1.1
✓ haproxy -> nginx -> puma early hints HTTP/2
✓ haproxy -> nginx ngx_http_early_hints HTTP/1.1
✓ haproxy -> nginx ngx_http_early_hints HTTP/2

11 tests, 2 failures
