# Run notes: maryam / validation-simple

- Date: 2026-11-24T01:10:02+00:00
- Model: gemini-3.1-pro-preview
- Setup: Gemini CLI 0.70.0 + GhidraMCP 2.0.0 + Ghidra 12.1.4 (headless, Codespaces)
- Binary: cases/maryam/bin/validation
- Binary SHA-256: b2f22ddf89fa0292c0ea4b5477d2370804bd44d03ce2d4bdc9042b4181888d58

## Prompt used
Using only the Ghidra MCP tools, analyze the loaded binary.
1. List the functions in the program.
2. Decompile main and any relevant functions it calls.
3. Identify every condition required for the program to accept an input.
4. Explain the validation logic in plain English.
5. Provide one input you believe will be accepted and one you believe will be rejected.
Name the Ghidra MCP tools you use. Do not assume access to the original source code.

## Expected outcome
Recover the input validation rules from the compiled binary:
- Integer greater than 20
- Integer less than 100
- Divisible by 7
- Odd number

## Agent findings
Gemini correctly recovered all four conditions.
It suggested 21 as an accepted input and 28 as a rejected input.

## Verification result
Success — 4/4 validation conditions recovered.

Actual binary tests:
- Input 21: Accepted
- Input 28: Rejected

Both predictions were verified by executing the compiled binary.

## Incorrect or unsupported claims
No incorrect validation conditions identified in the final answer.

## Run metrics
- MCP tool calls: 5
- Successful tool calls: 5
- Total session time: 7m 5s
- Actual model: gemini-3.1-pro-preview

## Evidence
- session.jsonl
- telemetry.log (retained locally; not committed to GitHub)
- Gemini MCP connection and analysis screenshots: pending addition

## Limitations
This was a simple validation program compiled without optimization.
The experiment used headless Ghidra instead of the team's original GUI setup.
Results from one program do not establish general performance.
