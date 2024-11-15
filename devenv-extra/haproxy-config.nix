{ pkgs, ... }:

pkgs.writeText "haproxy.conf" ''
  defaults
    mode http
    timeout client 10s
    timeout connect 5s
    timeout server 10s
    timeout http-request 10s

  frontend http1_1
    bind 127.0.0.1:8081
    use_backend nginx if { path_beg /home/ }
    default_backend rails

  frontend http2
    bind 127.0.0.1:8082 proto h2
    use_backend nginx if { path_beg /home/ }
    default_backend rails

  backend rails
    server puma 127.0.0.1:3000

  backend nginx
    server nginx 127.0.0.1:8080
''
