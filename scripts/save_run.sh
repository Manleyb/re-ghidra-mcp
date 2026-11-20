#!/usr/bin/env bash
# Saves the evidence from the Gemini session you just finished.
# Usage: ./scripts/save_run.sh <member> <case-name>
#   e.g. ./scripts/save_run.sh bryce setup-smoke-test
# Copies: the newest Gemini CLI chat record (prompt, every MCP tool call + result, model answers)
#         and the telemetry log, into results/<member>/<case>/<timestamp>/
set -euo pipefail
[ $# -eq 2 ] || { echo "usage: $0 <member> <case-name>"; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/results/$1/$2/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

CHAT=$(find "$HOME/.gemini/tmp" -path '*/chats/*' -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
[ -n "$CHAT" ] && cp "$CHAT" "$OUT/session$( [[ $CHAT == *.json ]] && echo .json || echo .jsonl)" && echo "saved chat record: $(basename "$CHAT")" || echo "WARNING: no chat record found under ~/.gemini/tmp/*/chats/"

TEL="$ROOT/agent/logs/telemetry.log"
if [ -s "$TEL" ]; then mv "$TEL" "$OUT/telemetry.log"; echo "saved telemetry log"; else echo "WARNING: no telemetry log at agent/logs/telemetry.log"; fi

grep -c '"mcp_ghidra_\|mcp_ghidra_' "$OUT"/* 2>/dev/null | sed 's/^/ghidra tool-call mentions: /' || true
cat > "$OUT/NOTES.md" <<NOTES
# Run notes: $1 / $2
- Date: $(date -Iseconds)
- Model: $(python3 -c "import json;print(json.load(open('$ROOT/agent/.gemini/settings.json'))['model']['name'])")
- Binary + sha256:
- Prompt used:
- Screenshot(s):
- Expected outcome:
- Verification result (correct / partial / incorrect):
- Incorrect or unsupported claims:
NOTES
echo "Evidence saved to: $OUT  (fill in NOTES.md, add screenshots)"
