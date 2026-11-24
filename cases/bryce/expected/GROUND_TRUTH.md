# Ground truth — Bryce control-flow case (cfg_case)

**Do not show this file to the agent.** Verification oracle = runtime output of the binary,
per beta rule "checked against known source-code behavior or executable output".

## Reference behaviour (clean source: cases/bryce/src/cfg_case.c)
`evaluate(s)` runs a 5-state machine over the characters of `s`:
- state 0 (start): a digit seeds score and moves to state 1; `-` -> state 2; `#` -> state 4; anything else -> state 3 (error).
- state 1 (accumulate): `+` -> state 0; a digit adds (digit * (streak+1)) and grows streak; `*` doubles score; anything else -> state 3.
- state 2: subtract the next digit, then return to state 0.
- state 4: skip until the next `#`, then state 0.
- state 3: error sink -> returns -1 immediately.
Final: if end state is 3 -> -1; else take abs(score) % 1000.
Note the trap: `-` and `*` are only valid in specific states, so e.g. "9-3+4" errors (-1).

## Expected outputs (from the clean build; the obfuscated build must match these exactly)
| input | evaluate() |
|---|---|
| `12+3` | 8 |
| `5*2` | 14 |
| `-7` | 7 |
| `9-3+4` | -1 |
| `#hi#8` | 8 |
| `x` | -1 |
| `007` | 21 |
| `3*4*2` | 34 |
| `<empty>` | 0 |
| `abc` | -1 |
| `1+2+3` | 6 |
| `9*9*9` | 99 |
| `-5-5` | 10 |
