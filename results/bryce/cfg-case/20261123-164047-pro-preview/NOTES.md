# Baseline run — Bryce control-flow deobfuscation

- **Date:** 2026-11-23 16:40 local
- **Member / case:** bryce / cfg-case (control-flow deobfuscation)
- **Agent:** Gemini CLI 0.70.0, baseline config (Ghidra MCP tools only; file/shell/web tools excluded)
- **Model:** **gemini-3.1-pro-preview** (via `--model`; team default stays gemini-3.8-flash)
  - Note: Mohamed/Sami baselines ran on flash 3.8. This case was run on pro-preview at the user's request — model is documented here for honesty; the baseline is **not** model-uniform across members.
- **Binary (what the agent saw):** `cases/bryce/bin/cfg_case`, stripped, obfuscated
  - sha256 `77763bb22014e615bc9f68b9e3062306689d9578b4179f43145da0078cfe8ebb`
- **Ground truth (withheld):** `cases/bryce/src/cfg_case.c` + `expected/GROUND_TRUTH.md`
- **Obfuscation:** Polaris backend/MIR pass (`asm("backend-obfu")`) — return-address patching, junk/anti-disassembly bytes, opaque predicates, MBA.

## Integrity
Clean run: the agent used **only Ghidra MCP tools**. It attempted `run_shell_command` 3× to execute the
binary (`cfg_case "10+5"`, `"1+2*3"`, `"5-2"`), but the tool was excluded, so each returned
`Tool "run_shell_command" not found` — **the binary was never executed by the agent** and no source/expected
output leaked. The agent itself noted it "can't execute shell commands, only utilize Ghidra's MCP tools."

## Tool calls (real Ghidra MCP = 17)
get_program_info ×1, search_functions_by_name ×2, list_functions ×1, get_function_by_address ×1,
decompile_function_by_address ×4, disassemble_function ×5, read_memory ×2, list_strings ×1.
(+5 internal `update_topic`, +3 blocked `run_shell_command`.)

## Cost / size
- Tokens: total **375,606** (prompt 359,175 / cached 138,445 / output 2,825 / thinking 13,606).
- 13 API requests, 0 errors, ~257 s model latency (~5 min wall incl. tool round-trips).
- Large token count is driven by resending the big obfuscated disassembly/decompilation each turn.
- Dollar cost: see Google Cloud billing (Vertex, pro-preview). Rough order ~$1; verify in console.

## What the agent got RIGHT
- **Input model:** string from `argv[1]`, parsed char-by-char; digit handling (`SUB 0x30`, `CMP 0x39`), index iteration.
- **Obfuscation diagnosis (strong):** correctly identified return-address patching / stack tampering
  (`ADD qword ptr [RSP], 0x17` to skip ~23 bytes), **anti-disassembly junk** after call sites that truncates
  Ghidra's CFG ("Bad instruction — Truncating control flow"), and **opaque predicates** (e.g. an over-derived
  `RBP-0x8` via `XOR/ADD/SUB` instead of a direct store). This matches the Polaris backend pass precisely.
- Flagged specific junk instructions (`ADC AL,0x4c`, `SHL RAX,0x16`, `AND R10,...`, `TEST DL,0xb7`).

## What the agent got WRONG — the key result
- **Recovered logic is incorrect.** It proposed a standard left-to-right calculator
  `result = (current_val*10)+digit` with `+ - * /` operators (`agent_proposed_evaluate.c`).
- The real `evaluate` is a **5-state machine** with streak-weighted digit accumulation
  (`digit*(streak+1)`), `*` = double score, `-` = subtract next digit then reset, `#…#` = comment skip,
  then `abs(score) % 1000`.
- **Verification (`verification.txt`): agent logic matches real output on only 2/11 inputs**, and both are
  coincidental (`""`→0, `1+2+3`→6). Examples it got wrong: `12+3` real 8 vs agent 15; `007` real 21 vs 7;
  `3*4*2` real 34 vs 24; `9*9*9` real 99 vs 729; `-5-5` real 10 vs -10.
- Honest hedge by the agent: it said the arithmetic was "partially obscured" because Ghidra's CFG was
  truncated, and that its C was the logic "assuming basic arithmetic evaluation" — i.e. a guess.

## Scoring
| Dimension | Result |
|---|---|
| Control flow / obfuscation explained | **Yes** (accurate, detailed) |
| Proposed equivalent logic correct on tests | **No** (2/11, coincidental) |
| Opaque / dead / junk branches identified | **Yes** (specific examples) |
| Unsupported claims | Minor: asserted a `/` operator path that isn't in the real function (harmless guess) |
| **Overall** | **PARTIAL** — nailed the obfuscation, failed to recover the actual semantics |

## Takeaway for the writeup / Phase 2
The obfuscation broke Ghidra's decompiler (truncated CFG), so the baseline agent — even a strong Pro model —
could describe *how* it was obfuscated but could **not** recover *what* the function computes; it fell back to
a plausible-but-wrong guess. This is exactly the gap a specialized tool (e.g. angr symbolic execution, or a
deobfuscating disassembler) is meant to close in Phase 2.

## Files
- `prompt.txt` — exact prompt · `response.md` — full agent answer · `response.json` — raw (stats, tool calls)
- `agent_proposed_evaluate.c` — the agent's proposed logic · `verification.txt` — 11-input comparison
- `telemetry.log` — full tool-call / request trace
