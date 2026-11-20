# Baseline results (Phase 1: Gemini + Ghidra MCP)

One row per run. Link each row to its folder in results/<member>/<case>/<timestamp>/.

| Member | Task | Agent output (short) | Verified result | Success / Partial / Failure | Notes / evidence folder |
|---|---|---|---|---|---|
| bryce (setup lead) | setup smoke test (test/hello), automated | Rules: argc==2, len 6, djb2 % 7 == 3; example input `aaaaaf` | Rules correct; `aaaaaf` rejected by binary | Partial | 11 Ghidra MCP calls; example input was guessed. `results/bryce/setup-smoke-test-automated/` |
