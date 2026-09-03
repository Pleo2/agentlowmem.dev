#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"

fail() {
  echo "theme picker: $1" >&2
  exit 1
}

require() {
  pattern=$1
  message=$2
  grep -Eiq -- "$pattern" "$FILE" || fail "$message"
}

require '<fieldset[^>]+class="theme-picker"[^>]+aria-label="Theme"' 'missing accessible theme selector'
[ "$(grep -Ec 'type="radio"[[:space:]]+name="theme"' "$FILE")" -eq 3 ] || fail 'theme selector must expose system, light, and dark choices'
require 'id="theme-system"[^>]+checked' 'system theme must remain the default'
require ':root:has\(#theme-light:checked\)' 'light override must be CSS-only'
require ':root:has\(#theme-dark:checked\)' 'dark override must be CSS-only'
require -- '--bg:[[:space:]]*#fff([;[:space:]]|$)' 'light theme must use a white page background'
require '\.shell[^\{]*\{[^}]*width:[[:space:]]*min\(calc\(100%[[:space:]]*-[[:space:]]*2\.5rem\)' 'page shell must use valid responsive width math'

if grep -Eiq '<script([[:space:]>])|localStorage|sessionStorage|document\.' "$FILE"; then
  fail 'theme selection must not introduce JavaScript or browser storage'
fi

echo "theme picker contract passed"
