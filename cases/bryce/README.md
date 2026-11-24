# Bryce — Beta Case: Control-flow deobfuscation (baseline)

## Objective
Test whether the **baseline Gemini + Ghidra MCP agent** can read an *obfuscated* function,
explain its control flow, and propose simpler equivalent logic — then check that proposal
against the clean source and representative input/output tests.

## What the agent sees
Only `cases/bryce/bin/cfg_case` (stripped, **obfuscated**). It never sees `src/` or `expected/`.

## Obfuscation
Source `src/cfg_case.c` (a clean 5-state evaluator) is compiled with **Polaris-Obfuscator**
(prebuilt clang 16 fork, no Docker / no registration). The obfuscation is its **backend/MIR pass**,
triggered by injecting `asm volatile("backend-obfu");` as the first statement of `evaluate()`.
`build.sh` injects the marker into a build copy only, so `src/cfg_case.c` stays clean and readable.
This mangles the instruction stream and control flow with bogus arithmetic, fake `test`/branch
sequences, `rdrand`, and MBA mixing (`evaluate()` grows ~6×; see `results/bryce/cfg-case/obfuscation/`).

Note: the Polaris prebuilt's documented `-mllvm -passes=fla,bcf,...` form does **not** apply in this
release (a fake pass name is accepted silently); the `backend-obfu` marker is the mechanism that works.

The clean reference is built with the team flags `gcc -O0 -fno-inline -g0`; its runtime output is the
verification oracle in `expected/GROUND_TRUTH.md`. The obfuscated binary must produce identical output.

### Toolchain
Download once (outside the repo): the Polaris v1.0 Linux prebuilt from
`https://github.com/za233/Polaris-Obfuscator/releases`, extract to `~/polaris-obf/`, then
`export POLARIS_CLANG="$HOME/polaris-obf/bin/clang"`.

Model for this case: **gemini-3.8-flash** (same as Mohamed/Sami — do not switch).

## Build and verify (outside the agent session)
```bash
export POLARIS_CLANG="$HOME/polaris-obf/<polaris-dir>/bin/clang"
bash cases/bryce/build.sh
# equivalence check: obfuscated output must match the clean reference
for x in "12+3" "5*2" "-7" "9-3+4" "007" "3*4*2" "9*9*9"; do
  diff <(./cases/bryce/bin/cfg_case_clean "$x") <(./cases/bryce/bin/cfg_case "$x") && echo "ok: $x"
done
sha256sum cases/bryce/bin/cfg_case
```

## Baseline experiment
1. Open **only** `cases/bryce/bin/cfg_case` in Ghidra 12.1.4, let auto-analysis finish, enable GhidraMCPPlugin.
2. From the repo root: `./scripts/check_setup.sh --live` (confirm Ghidra connected, model = gemini-3.8-flash).
3. `cd agent && gemini`, fresh session. Confirm `/mcp` shows ghidra connected.
4. Paste this prompt:

> Using only the Ghidra MCP tools, inspect the loaded binary. Focus on the main user function `evaluate`.
> Its control flow has been obfuscated. Describe what the function computes, explain the control-flow
> structure, and propose simpler **equivalent** C that would produce the same outputs. Point out any
> branches that appear to be dead or always-true/false (opaque predicates). Name every Ghidra MCP tool
> you call. If you cannot be sure, say so rather than guessing.

5. Approve the real Ghidra MCP tool calls. Screenshot the tool calls and the answer.
6. `/quit`; from repo root: `./scripts/save_run.sh bryce cfg-case`. Fill in `NOTES.md`.
7. **Verify** the agent's proposed simplified C: compile it and run the same inputs from
   `expected/GROUND_TRUTH.md`; record where it matches and where it diverges. Note any opaque predicates
   it correctly flagged vs. missed. Add one row to `results/RESULTS.md`.

**Scoring:** control flow explained? (yes/partial/no); proposed equivalent logic correct on tests? (yes/partial/no);
opaque/dead branches identified? (yes/partial/no); unsupported claims (with examples).
