# Mohamed — Beta Case 01: Function identification and semantic recovery

## Objective
Evaluate whether the **baseline Gemini + Ghidra MCP agent** can infer the behavior of a stripped, unnamed function and suggest a useful function name and comments. Do not ask Gemini to read source or expected results.

## Build and verify (outside the agent session)
```bash
bash cases/mohamed/build.sh
./cases/mohamed/bin/case01 3 8 1
./cases/mohamed/bin/case01 2 20 0
sha256sum cases/mohamed/bin/case01
```

Build settings are the team flags `gcc -O0 -fno-inline -g0`, followed by `strip --strip-all` so original function names are unavailable. Recompile locally if the committed binary does not match your platform.

## Baseline experiment
1. Open **only** `cases/mohamed/bin/case01` in Ghidra 12.1.4, let auto-analysis complete, and enable GhidraMCPPlugin.
2. From the repo root run `./scripts/check_setup.sh --live`. Do not switch the pinned model or tools.
3. `cd agent && gemini`. Confirm `/mcp` shows Ghidra connected.
4. Start a fresh session and paste this prompt:

> Using only Ghidra MCP tools, inspect the loaded binary and find the nontrivial function called from main that accepts three integers and returns a classification code. Explain what each argument and return value appears to mean, propose a descriptive function name, and propose two useful comments. Cite the decompiled operations or branch conditions that support your interpretation. Name the Ghidra MCP tools you actually called. If you cannot determine the real-world domain from the binary, say that explicitly rather than guessing.

5. Approve actual Ghidra MCP tool calls. Take screenshots of the tool calls and the answer. Do not reveal `src/` or `expected/`.
6. `/quit`; from the repo root run `./scripts/save_run.sh mohamed case01`. Fill in the generated `NOTES.md`.
7. Check agent claims against `expected/GROUND_TRUTH.md` and actual executable results. Enter one row in `results/RESULTS.md`.

**Scoring:** Correct behavior? (yes/partial/no); useful proposed function name? (yes/partial/no); grounded comments? (yes/partial/no); unsupported claims? Record exact examples.

No baseline model result is claimed until Gemini has actually used the Ghidra MCP tools and the output has been verified.
