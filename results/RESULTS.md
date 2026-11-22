# Baseline results (Phase 1: Gemini + Ghidra MCP)

One row per run. Link each row to its folder in results/<member>/<case>/<timestamp>/.

| Member | Task | Agent output (short) | Verified result | Success / Partial / Failure | Notes / evidence folder |
|---|---|---|---|---|---|
| bryce (setup lead) | setup smoke test (test/hello), automated | Rules: argc==2, len 6, djb2 % 7 == 3; example input `aaaaaf` | Rules correct; `aaaaaf` rejected by binary | Partial | 11 Ghidra MCP calls; example input was guessed. `results/bryce/setup-smoke-test-automated/` |
| mohamed | Function identification (case01) | Identified FUN_001011c9; suggested classify_tier; explained the three parameters and four return values | Correct conditional logic and outputs; original function assess_login_risk; binary tests passed | Partial | [Evidence](mohamed/case01/20261122-111508/) |