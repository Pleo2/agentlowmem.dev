#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"

require() {
  pattern=$1
  message=$2
  grep -Eiq "$pattern" "$FILE" || {
    echo "terminal window: $message" >&2
    exit 1
  }
}

reject() {
  pattern=$1
  message=$2
  if grep -Eiq "$pattern" "$FILE"; then
    echo "terminal window: $message" >&2
    exit 1
  fi
}

require 'class="window-controls"[^>]+aria-hidden="true"' 'missing decorative macOS window controls'
require 'class="window-control close"' 'missing close control'
require 'class="window-control minimize"' 'missing minimize control'
require 'class="window-control zoom"' 'missing zoom control'
require 'class="window-title">agent-lowmem — doctor<' 'missing centered window title'
require '\.terminal[^\{]*\{[^}]*border-radius:' 'terminal needs a rounded window frame'
require '\.terminal[^\{]*\{[^}]*box-shadow:' 'terminal needs restrained window depth'
reject 'backdrop-filter' 'GPU-heavy backdrop filtering is forbidden'

echo "terminal window contract passed"
