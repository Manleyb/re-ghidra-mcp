# Control-flow obfuscation evidence (Bryce case)

Obfuscator: **Polaris-Obfuscator** prebuilt clang 16 (`https://github.com/za233/Polaris-Obfuscator`, release v1.0),
run locally — no Docker, no registration. Binary toolchain lives outside the repo at `~/polaris-obf/`.

**Mechanism note (important for reproduction):** in this prebuilt release the documented
`clang -mllvm -passes=fla,bcf,...` form does **not** apply (a bogus pass name is silently accepted and
nothing changes). The obfuscation that actually works is the **backend/MIR pass**, triggered by inserting
`asm volatile("backend-obfu");` as the first statement of the target function. `cases/bryce/build.sh`
injects this marker into a build copy only; `src/cfg_case.c` stays clean and readable.

## Screenshots (real `xterm` captures under Xvfb, in `xterm/`)
Captured in an actual xterm terminal emulator (Xvfb virtual display, grabbed with ImageMagick `import`).
The `.txt` files alongside are the exact session text shown.
| File | Shows |
|---|---|
| `xterm/01_obfuscate.png` | the obfuscated build command and output |
| `xterm/02_equivalence.png` | obfuscated binary produces identical output to the clean reference (13/13 inputs) |
| `xterm/03_complexity.png` | instruction counts: clean vs obfuscated (complexity survived compilation) |
| `xterm/04_disasm.png` | `evaluate()` disassembly before vs after (bogus arithmetic, `test`, `rdrand`, MBA mixing) |

## Measured
- `evaluate()` / `.text`: **237 → ~1,500 instructions** (~6×); **+44** unconditional jumps injected.
- Behaviour preserved: all 13 ground-truth inputs match the clean reference (`expected/GROUND_TRUTH.md`).

This is the setup/obfuscation evidence. The baseline **agent** run (Gemini reading `cfg_case` through Ghidra
MCP and attempting to recover the logic) is the next step, per `cases/bryce/README.md`.
