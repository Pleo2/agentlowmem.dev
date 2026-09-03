#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"

require() {
  pattern=$1
  message=$2
  grep -Eiq -- "$pattern" "$FILE" || {
    echo "terminal window: $message" >&2
    exit 1
  }
}

reject() {
  pattern=$1
  message=$2
  if grep -Eiq -- "$pattern" "$FILE"; then
    echo "terminal window: $message" >&2
    exit 1
  fi
}

require 'class="window-controls"[^>]+aria-hidden="true"' 'missing decorative macOS window controls'
require 'class="window-control close"' 'missing close control'
require 'class="window-control minimize"' 'missing minimize control'
require 'class="window-control zoom"' 'missing zoom control'
require 'class="window-title">agent-lowmem — managed session<' 'missing centered window title'
[ "$(grep -Ec 'class="window-spacer"' "$FILE")" -eq 1 ] || {
  echo "terminal window: terminal title bar must contain exactly one layout spacer" >&2
  exit 1
}
require '\.terminal[^\{]*\{[^}]*border-radius:[[:space:]]*1\.25rem' 'terminal needs the approved 20px rounded frame'
require '\.terminal[^\{]*\{[^}]*box-shadow:' 'terminal needs restrained window depth'
require '\.window-control[^\{]*\{[^}]*background:[[:space:]]*var\(--window-control\)' 'window controls must share one neutral gray'
require '\.result-line[^\{]*\{[^}]*display:[[:space:]]*grid[^}]*grid-template-columns:[[:space:]]*9ch' 'completed must align with the other result values'
require '--window-surface:[[:space:]]*rgba\([^;]+,[[:space:]]*\.45\)' 'terminal surface must remain 45% translucent'
require '--window-bar:[[:space:]]*rgba\([^;]+,[[:space:]]*\.55\)' 'title bar must remain 55% translucent'
reject 'backdrop-filter' 'GPU-heavy backdrop filtering is forbidden'
reject '\.window-control\.(close|minimize|zoom)[^\{]*\{[^}]*background:' 'individual traffic-light colors are forbidden'

echo "terminal window contract passed"
