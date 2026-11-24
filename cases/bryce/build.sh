#!/usr/bin/env bash
# Build the Bryce control-flow case.
#   clean reference (ground truth):  gcc -O0 -fno-inline -g0   on the pristine source
#   obfuscated (given to Ghidra):    Polaris clang backend (MIR) obfuscation, triggered by an
#                                    injected  asm("backend-obfu")  marker in evaluate().
# The marker is injected into a BUILD COPY only; src/cfg_case.c stays clean and readable.
#
# Set POLARIS_CLANG, e.g.:
#   export POLARIS_CLANG="$HOME/polaris-obf/bin/clang"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$ROOT/bin"
SRC="$ROOT/src/cfg_case.c"

echo "[1/4] clean reference build (gcc)"
gcc -O0 -fno-inline -g0 -o "$ROOT/bin/cfg_case_clean" "$SRC"

echo "[2/4] inject backend-obfu marker into a build copy"
TMP="$(mktemp --suffix=.c)"
trap 'rm -f "$TMP"' EXIT
# insert the marker as the first statement inside evaluate()
awk '/^int evaluate\(const char \*s\) \{/{print; print "    asm volatile(\"backend-obfu\");"; next} {print}' "$SRC" > "$TMP"

echo "[3/4] obfuscated build (Polaris clang backend obfuscation)"
: "${POLARIS_CLANG:?set POLARIS_CLANG to the Polaris clang binary}"
"$POLARIS_CLANG" -O0 -o "$ROOT/bin/cfg_case" "$TMP"
strip --strip-all "$ROOT/bin/cfg_case"

echo "[4/4] results"
file "$ROOT/bin/cfg_case"
sha256sum "$ROOT/bin/cfg_case_clean" "$ROOT/bin/cfg_case"
