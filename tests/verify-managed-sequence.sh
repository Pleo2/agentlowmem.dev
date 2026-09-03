#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"
TERMINAL=$(sed -n '/<section class="terminal"/,/<section class="managed"/p' "$FILE")

fail() {
  echo "managed sequence: $1" >&2
  exit 1
}

printf '%s' "$TERMINAL" | grep -Eq 'class="run-sequence"' || fail 'run sequence must live inside the terminal window'
printf '%s' "$TERMINAL" | grep -Eq 'agent-lowmem run test' || fail 'missing managed run command'

STEPS=$(printf '%s' "$TERMINAL" | grep -Ec 'class="sequence-step"')
[ "$STEPS" -eq 7 ] || fail "expected 7 managed steps, found $STEPS"

grep -Eq '\.run-sequence[^\{]*\{[^}]*animation:[^;]+[[:space:]]4\.15s[[:space:]]' "$FILE" || fail 'sequence must begin after the slower doctor sequence exits'
grep -Eq '@media[[:space:]]*\(prefers-reduced-motion:[[:space:]]*reduce\)' "$FILE" || fail 'missing reduced-motion fallback'
grep -Eq '\.sequence-step[^\{]*\{[^}]*animation:' "$FILE" || fail 'steps must reveal progressively'
grep -Eq 'class="step-loader"[^>]+aria-hidden="true"' "$FILE" || fail 'missing decorative progress indicator'
grep -Eq -- '--result-gradient:[[:space:]]*linear-gradient\(90deg' "$FILE" || fail 'result needs its own horizontal gradient'
grep -Eq '\.sequence-step:last-child[[:space:]]+\.trace-key[[:space:]]*\{[^}]*background:[[:space:]]*var\(--result-gradient\)' "$FILE" || fail 'result label must use the horizontal gradient'

if grep -Eq '<script([[:space:]>])' "$FILE"; then
  fail 'managed sequence must not require JavaScript'
fi

echo "managed sequence contract passed"
