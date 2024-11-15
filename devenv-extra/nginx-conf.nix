{ nginx, ... }:


''
    # Load mime types and configure maximum size of the types hash tables.
    types_hash_max_size 2688;
    include ${nginx}/conf/fastcgi.conf;
    include ${nginx}/conf/uwsgi_params;
    default_type application/octet-stream;
    # $connection_upgrade is used for websocket proxying
    map $http_upgrade $connection_upgrade {
      default upgrade;
      \'\'      close;
    }
    client_max_body_size 100M;
    server_tokens off;
    server {
      listen 0.0.0.0:8080;
      http2 off;

      location /up {
        add_early_header "Link" "</assets/application-a287cdb7.css>;rel=preload;as=style; nopush";

        proxy_pass http://127.0.0.1:3000;
        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header        X-Forwarded-Host $host;
        proxy_set_header        X-Forwarded-Server $host;
      }

      location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header        X-Forwarded-Host $host;
        proxy_set_header        X-Forwarded-Server $host;
      }

      add_header X-Frame-Options "SAMEORIGIN";
      add_header X-XSS-Protection "0"; # Do NOT enable. This is obsolete/dangerous
      add_header X-Content-Type-Options "nosniff";
      add_header Origin-Agent-Cluster "?1" always;
      add_header Strict-Transport-Security "max-age=31536000" always;
      ssl_stapling on;
      ssl_stapling_verify on;
    }
''
