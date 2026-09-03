#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"
TERMINAL=$(sed -n '/<section class="terminal"/,/<section class="managed"/p' "$FILE")

fail() {
  echo "doctor sequence: $1" >&2
  exit 1
}

printf '%s' "$TERMINAL" | grep -Eq 'class="doctor-sequence"' || fail 'doctor output needs its own animated sequence'
printf '%s' "$TERMINAL" | grep -Eq 'class="doctor-command"' || fail 'doctor command must animate independently'

ROWS=$(printf '%s' "$TERMINAL" | grep -Ec 'class="doctor-row')
[ "$ROWS" -eq 7 ] || fail "expected 7 doctor rows, found $ROWS"

grep -Eq '\.doctor-sequence[^\{]*\{[^}]*animation:[^;]*doctor-exit' "$FILE" || fail 'doctor sequence must exit after completing'
grep -Eq '@keyframes[[:space:]]+doctor-exit' "$FILE" || fail 'missing doctor exit animation'
grep -Eq '\.doctor-row[^\{]*\{[^}]*animation:' "$FILE" || fail 'doctor rows must reveal progressively'
grep -Eq '\.doctor-sequence[[:space:]]*\{[^}]*display:[[:space:]]*none' "$FILE" || fail 'reduced-motion state must skip doctor animation'

if grep -Eq '@keyframes[[:space:]]+doctor-exit[^}]*opacity' "$FILE"; then
  fail 'doctor exit must preserve text contrast while collapsing'
fi

if grep -Eq '<script([[:space:]>])' "$FILE"; then
  fail 'doctor sequence must not require JavaScript'
fi

echo "doctor sequence contract passed"
