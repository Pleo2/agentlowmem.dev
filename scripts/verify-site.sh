#!/bin/sh
set -eu

FILE=${1:-index.html}
LIMIT=15360

fail() {
  echo "site contract: $1" >&2
  exit 1
}

[ -f "$FILE" ] || fail "missing $FILE"

require() {
  pattern=$1
  message=$2
  grep -Eiq "$pattern" "$FILE" || fail "$message"
}

reject() {
  pattern=$1
  message=$2
  if grep -Eiq "$pattern" "$FILE"; then
    fail "$message"
  fi
}

require '<!doctype html>' 'missing HTML5 doctype'
require '<html[^>]+lang="en"' 'missing English language declaration'
require '<meta[^>]+charset="utf-8"' 'missing UTF-8 declaration'
require '<meta[^>]+name="viewport"' 'missing viewport metadata'
require '<meta[^>]+name="color-scheme"[^>]+content="dark light"' 'missing adaptive color-scheme metadata'
require '<link[^>]+rel="icon"[^>]+href="data:' 'missing request-free favicon declaration'
require '<nav([[:space:]>])' 'missing navigation landmark'
require '<main([[:space:]>])' 'missing main landmark'
require '<h1([[:space:]>])' 'missing primary heading'
require '<footer([[:space:]>])' 'missing footer landmark'
require 'prefers-color-scheme:[[:space:]]*light' 'missing light theme adaptation'
require 'prefers-reduced-motion:[[:space:]]*reduce' 'missing reduced-motion override'

reject '<script([[:space:]>])' 'production JavaScript is forbidden'
reject '<img([[:space:]>])' 'image requests are forbidden'
reject '<iframe([[:space:]>])' 'embedded documents are forbidden'
reject '@font-face' 'downloadable fonts are forbidden'
reject '<link[^>]+rel="(stylesheet|preload|modulepreload)"' 'linked subresources are forbidden'
reject '<link[^>]+rel="icon"[^>]+href="(https?:)?//' 'remote icons are forbidden'
reject '(src|poster)="[^"]+"' 'source subresources are forbidden'
reject 'url\([^)]*//' 'remote CSS resources are forbidden'

SIZE=$(gzip -9 -c "$FILE" | wc -c | tr -d '[:space:]')
[ "$SIZE" -lt "$LIMIT" ] || fail "gzip size ${SIZE} bytes exceeds ${LIMIT}-byte limit"

echo "site contract: ${SIZE} gzip bytes; no production subresources"
