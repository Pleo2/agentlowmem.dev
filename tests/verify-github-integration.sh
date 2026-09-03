#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"

fail() {
  echo "GitHub integration contract: $1" >&2
  exit 1
}

grep -Fq '<h2>GitHub-aware inspection</h2>' "$FILE" || fail 'missing GitHub integration capability'
grep -Fq '<code>agent-lowmem github inspect --json</code>' "$FILE" || fail 'missing agent-compatible command'
grep -Fq 'href="mailto:support@agentlowmem.dev"' "$FILE" || fail 'missing verified support route'
if grep -Eq 'GITHUB_TOKEN|ghp_[A-Za-z0-9]+' "$FILE"; then
  fail 'landing must not expose or request token material'
fi

echo "GitHub integration contract passed"
