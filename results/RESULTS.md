# Baseline results (Phase 1: Gemini + Ghidra MCP)

One row per run. Link each row to its folder in results/<member>/<case>/<timestamp>/.

| Member | Task | Agent output (short) | Verified result | Success / Partial / Failure | Notes / evidence folder |
|---|---|---|---|---|---|
| bryce (setup lead) | setup smoke test (test/hello), automated | Rules: argc==2, len 6, djb2 % 7 == 3; example input `aaaaaf` | Rules correct; `aaaaaf` rejected by binary | Partial | 11 Ghidra MCP calls; example input was guessed. `results/bryce/setup-smoke-test-automated/` |
| sami | string deobfuscation (`xor_simple`) | Identified single-byte XOR with key `0x23`; byte analysis recovered `SECRET`, but final summary reported `Secret` | Runtime output: `Decoded: SECRET`; plaintext not present in `strings` output | Partial | Correct method, key, and decoding logic; minor capitalization mismatch. `results/sami/xor-simple/20261122-baseline/` |