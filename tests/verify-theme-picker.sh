#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"
HEADER=$(sed -n '/<header class="shell">/,/<\/header>/p' "$FILE")
FOOTER=$(sed -n '/<footer class="shell">/,/<\/footer>/p' "$FILE")

fail() {
  echo "theme picker: $1" >&2
  exit 1
}

require() {
  pattern=$1
  message=$2
  grep -Eiq -- "$pattern" "$FILE" || fail "$message"
}

printf '%s' "$FOOTER" | grep -Eq 'class="theme-picker"[^>]+role="radiogroup"[^>]+aria-labelledby="theme-label"' || fail 'theme selector must be an accessible footer control'
printf '%s' "$FOOTER" | grep -Eq 'id="theme-label">theme:<' || fail 'theme selector needs a visible label'
printf '%s' "$FOOTER" | grep -Eq 'class="footer-tools"' || fail 'footer links and theme selector need a stable vertical group'
require '\.footer-tools[^\{]*\{[^}]*flex-direction:[[:space:]]*column' 'footer controls must stack instead of crowding one row'
if printf '%s' "$HEADER" | grep -Eq 'theme-picker|theme-system|theme-light|theme-dark'; then
  fail 'theme selector must not compete with primary navigation'
fi
[ "$(grep -Ec 'type="radio"[[:space:]]+name="theme"' "$FILE")" -eq 3 ] || fail 'theme selector must expose system, light, and dark choices'
require 'id="theme-system"[^>]+checked' 'system theme must remain the default'
require ':root:has\(#theme-light:checked\)' 'light override must be CSS-only'
require ':root:has\(#theme-dark:checked\)' 'dark override must be CSS-only'
require -- '--bg:[[:space:]]*#fff([;[:space:]]|$)' 'light theme must use a white page background'
require '\.shell[^\{]*\{[^}]*width:[[:space:]]*min\(calc\(100%[[:space:]]*-[[:space:]]*2\.5rem\)' 'page shell must use valid responsive width math'

if grep -Eiq '<script([[:space:]>])|localStorage|sessionStorage|document\.' "$FILE"; then
  fail 'theme selection must not introduce JavaScript or browser storage'
fi

if printf '%s' "$FOOTER" | grep -Eiq '\bMIT\b|/LICENSE'; then
  fail 'footer must not claim an undecided project license'
fi

[ ! -f "$ROOT/LICENSE" ] || fail 'landing must not ship an unapproved project license'

echo "theme picker contract passed"
