#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$ROOT/bin"
gcc -O0 -fno-inline -g0 -o "$ROOT/bin/case01" "$ROOT/src/case01.c"
strip --strip-all "$ROOT/bin/case01"
file "$ROOT/bin/case01"
sha256sum "$ROOT/bin/case01"
