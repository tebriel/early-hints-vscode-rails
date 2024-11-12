# early-hints-vscode-rails

This is to test if we can use early hints:

1. In NGINX
2. In Rails
3. Forwarding through the VSCode Exposed Port Proxy

## Setup

`devenv up` will launch nginx and the rails server.

## Test

`curl -i http://localhost:3000/` should show you some HTTP/1.1 103 Early Hints headers.
`curl -i http://localhost:8080/` should show you some HTTP/1.1 103 Early Hints headers.

`curl -i <Public Mapped URL>` from your host after the port is mapped will show no 103

`curl -i <Public Mapped URL> --http2` From your host (not vscode) also show no 103
