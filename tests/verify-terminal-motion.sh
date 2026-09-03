#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"

fail() {
  echo "terminal motion: $1" >&2
  exit 1
}

grep -Eq '\.terminal-body[^\{]*\{[^}]*height:' "$FILE" || fail 'terminal body must have a stable height'
[ "$(grep -Ec 'class="[^" ]*typed-command|class="[^" ]+ typed-command' "$FILE")" -eq 2 ] || fail 'both terminal commands must use the typing treatment'
grep -Eq '@keyframes[[:space:]]+type-command' "$FILE" || fail 'missing finite command typing animation'
grep -Eq '\.doctor-typed[^\{]*\{[^}]*animation:[^;]*\.8s[[:space:]]+steps\(19,[[:space:]]*end\)' "$FILE" || fail 'doctor command must type 19 characters over .8 seconds'
grep -Eq '\.run-typed[^\{]*\{[^}]*animation:[^;]*\.9s[[:space:]]+steps\(21,[[:space:]]*end\)' "$FILE" || fail 'managed command must type 21 characters over .9 seconds'
grep -Eq 'class="sequence-step result-step"[[:space:]]+style="--delay:[[:space:]]*9\.15s"' "$FILE" || fail 'final result needs a deliberate pause after cleanup'

if grep -Eq 'animation:[^;]*infinite' "$FILE"; then
  fail 'terminal animations must settle and never loop'
fi

echo "terminal motion contract passed"
