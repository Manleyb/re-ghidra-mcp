#!/usr/bin/env bash
# Prints every version the team must match, and checks each piece of the setup.
# Usage: ./scripts/check_setup.sh   (run from anywhere)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$HOME/.nvm/versions/node/$(ls "$HOME/.nvm/versions/node" 2>/dev/null | sort -V | tail -1)/bin:$HOME/google-cloud-sdk/bin:$PATH"
ok(){ printf "  [ OK ] %s\n" "$*"; }; bad(){ printf "  [FAIL] %s\n" "$*"; FAILS=$((FAILS+1)); }; FAILS=0

echo "== Versions (must match SETUP.md) =="
printf "  %-12s %s\n" "Ghidra"     "$(ls -d "$HOME"/ghidra/ghidra_*_PUBLIC 2>/dev/null | xargs -n1 basename | tr '\n' ' ')"
printf "  %-12s %s\n" "GhidraMCP"  "$("$HOME/ghidramcp/venv/bin/python" -c 'import importlib.metadata as m;print(m.version("ghidra-mcp"))' 2>/dev/null || echo missing)"
printf "  %-12s %s\n" "Java"       "$(java -version 2>&1 | head -1)"
printf "  %-12s %s\n" "Python"     "$(python3 --version 2>&1)"
printf "  %-12s %s\n" "Node"       "$(node --version 2>/dev/null || echo missing)"
printf "  %-12s %s\n" "Gemini CLI" "$(gemini --version 2>/dev/null | tail -1 || echo missing)"
printf "  %-12s %s\n" "gcloud"     "$(gcloud --version 2>/dev/null | head -1 || echo missing)"
printf "  %-12s %s\n" "gcc"        "$(gcc -dumpfullversion 2>/dev/null || echo missing)"
printf "  %-12s %s\n" "Model"      "$(python3 -c "import json;print(json.load(open('$ROOT/agent/.gemini/settings.json'))['model']['name'])")"

echo "== Checks =="
[ -d "$HOME/.config/ghidra/ghidra_12.1.4_PUBLIC/Extensions/GhidraMCP" ] && ok "GhidraMCP extension installed in Ghidra 12.1.4" || bad "GhidraMCP extension not installed for Ghidra 12.1.4"
[ -x "$HOME/ghidramcp/venv/bin/ghidra-mcp" ] && ok "bridge at ~/ghidramcp/venv/bin/ghidra-mcp" || bad "bridge missing at ~/ghidramcp/venv/bin/ghidra-mcp"
curl -s -m 2 http://127.0.0.1:8080/ >/dev/null 2>&1 && ok "Ghidra plugin answering on 127.0.0.1:8080" || bad "Ghidra plugin not answering on :8080 (is Ghidra open with a binary loaded and the plugin enabled?)"
[ -f "$ROOT/.env" ] && ok ".env exists" || bad ".env missing (cp .env.example .env and fill it in)"
if [ -f "$ROOT/.env" ]; then
  P=$(grep -E '^GOOGLE_CLOUD_PROJECT=' "$ROOT/.env" | cut -d= -f2)
  [ -n "$P" ] && [ "$P" != "your-project-id" ] && ok "GOOGLE_CLOUD_PROJECT=$P" || bad "GOOGLE_CLOUD_PROJECT not set in .env"
fi
[ -f "$HOME/.config/gcloud/application_default_credentials.json" ] && ok "gcloud application-default login done" || bad "run: gcloud auth application-default login"
[ -z "${GEMINI_API_KEY:-}${GOOGLE_API_KEY:-}" ] && ok "no API key in shell env (Vertex ADC will be used)" || bad "unset GEMINI_API_KEY / GOOGLE_API_KEY so Vertex login is used"
git -C "$ROOT" check-ignore -q .env && ok ".env is git-ignored" || bad ".env is NOT git-ignored"

if [ "${1:-}" = "--live" ]; then
  echo "== Live check (one tiny prompt via Vertex) =="
  ( cd "$ROOT/agent" && GEMINI_CLI_TRUST_WORKSPACE=true timeout 120 gemini -p "Reply with exactly: OK" --output-format json 2>/dev/null ) \
    | python3 -c "
import sys,json
raw=sys.stdin.read()
try:
    d=json.loads(raw[raw.index('{'):])
except Exception:
    print('  [FAIL] no response from Gemini (login / project / network?)'); sys.exit(1)
want=json.load(open('$ROOT/agent/.gemini/settings.json'))['model']['name']
used=list(d.get('stats',{}).get('models',{}).keys())
print('  response:', d.get('response','').strip(), '| models used:', used)
print('  [ OK ] model matches pin' if used==[want] else '  [FAIL] model used differs from pinned '+want+' (tell the setup lead)')
" || FAILS=$((FAILS+1))
  rm -f "$ROOT/agent/logs/telemetry.log"
fi

echo; [ $FAILS -eq 0 ] && echo "All checks passed." || echo "$FAILS check(s) failed."
