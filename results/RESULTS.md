# Baseline results (Phase 1: Gemini + Ghidra MCP)

One row per run. Link each row to its folder in results/<member>/<case>/<timestamp>/.

| Member | Task | Agent output (short) | Verified result | Success / Partial / Failure | Notes / evidence folder |
|---|---|---|---|---|---|
| bryce (setup lead) | setup smoke test (test/hello), automated | Rules: argc==2, len 6, djb2 % 7 == 3; example input `aaaaaf` | Rules correct; `aaaaaf` rejected by binary | Partial | 11 Ghidra MCP calls; example input was guessed. `results/bryce/setup-smoke-test-automated/` |
| mohamed | Function identification (case01) | Identified FUN_001011c9; suggested classify_tier; explained the three parameters and four return values | Correct conditional logic and outputs; original function assess_login_risk; binary tests passed | Partial | [Evidence](mohamed/case01/20261122-111508/) |
| sami | string deobfuscation (`xor_simple`) | Identified single-byte XOR with key `0x23`; byte analysis recovered `SECRET`, but final summary reported `Secret` | Runtime output: `Decoded: SECRET`; plaintext not present in `strings` output | Partial | Correct method, key, and decoding logic; minor capitalization mismatch. `results/sami/xor-simple/20261122-baseline/` |
| bryce | control-flow deobfuscation (cfg_case, obfuscated) | Correctly diagnosed obfuscation (ret-addr patching, junk/anti-disasm, opaque predicates); proposed a standard calculator as the logic | Proposed C matches real output on only 2/11 inputs (both coincidental); real fn is a 5-state streak machine | Partial | **pro-preview**; Ghidra CFG truncated by obfuscation; 17 Ghidra MCP calls. `results/bryce/cfg-case/20261123-164047-pro-preview/` |
