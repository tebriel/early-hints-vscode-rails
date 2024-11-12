{ fetchFromGitHub, lib, ... }:

{
  name = "earlyHints";
  src = fetchFromGitHub {
    name = "earlyHints";
    owner = "nginx-modules";
    repo = "ngx_http_early_hints";
    rev = "72e270fa13c6d1b6bdeae24659425f58b5576f4a";
    hash = "sha256-4aGHMTa7CXOVECB8Sf2PQtLUyWkyBJEwzYQAOARUcCM=";
  };

  inputs = [ ];

  meta = with lib; {
    description = "This is an experimental nginx module that sending 103 early hints.";
    homepage = "https://github.com/nginx-modules/ngx_http_early_hints";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ tebriel ];
  };
}
