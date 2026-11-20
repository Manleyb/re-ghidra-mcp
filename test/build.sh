#!/usr/bin/env bash
# Shared build flags. Use the SAME flags for experiment binaries unless your case says otherwise.
set -euo pipefail
cd "$(dirname "$0")"
gcc -O0 -fno-inline -g0 -o hello hello.c
echo "built test/hello with: gcc $(gcc -dumpfullversion) -O0 -fno-inline -g0"
sha256sum hello
