#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/index.html"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP_DIR=$(mktemp -d)
PROBE="$TMP_DIR/index.html"
OUTPUT="$TMP_DIR/dom.html"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

fail() {
  echo "capabilities spacing: $1" >&2
  exit 1
}

[ -x "$CHROME" ] || fail "Google Chrome is required for the layout probe"

PROBE_SCRIPT='<script>addEventListener("load",()=>{const comparison=document.querySelector(".comparison");const features=document.querySelector(".features");const gap=Math.round(features.getBoundingClientRect().top-comparison.getBoundingClientRect().bottom);document.body.textContent=JSON.stringify({gap});});</script>'
sed "s#</body>#$PROBE_SCRIPT</body>#" "$FILE" > "$PROBE"

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --dump-dom \
  --window-size=972,1010 \
  "file://$PROBE" > "$OUTPUT" 2>/dev/null

grep -Eq '&quot;gap&quot;:0|"gap":0' "$OUTPUT" || {
  RESULT=$(grep -Eo '&quot;gap&quot;:[0-9-]+|"gap":[0-9-]+' "$OUTPUT" | head -1 || true)
  fail "expected comparison and capabilities to be contiguous, got ${RESULT:-no measurement}"
}

echo "capabilities spacing passed"
