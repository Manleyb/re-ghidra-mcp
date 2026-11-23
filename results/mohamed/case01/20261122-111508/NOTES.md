# Beta Case 01 — Function Identification and Semantic Recovery

- Date: 2026-11-22
- Member: Mohamed
- Model: gemini-3.8-flash
- Binary: cases/mohamed/bin/case01
- SHA-256: ec90995c2f8bf5a7d21be9f324dac155d8e84d0456e40baa950139ba857748da

## Objective
Determine whether Gemini, using only Ghidra MCP, can identify and explain an unnamed function in a stripped binary.

## Ground Truth
Original function: assess_login_risk

The function evaluates failed login attempts, time since the last failure, and trusted-device status.

Return values:
- -1: Invalid input
- 0: Allow
- 1: Challenge
- 2: Block

## Gemini Results
- Identified target: FUN_001011c9
- Suggested name: classify_tier
- Alternative name: classify_priority_level
- Correctly identified three integer parameters.
- Correctly described the branching conditions and return values.
- Proposed a function header comment and an inline logic comment.
- Did not recover the original login-security context.

## Evaluation
Result: PARTIAL SUCCESS

Gemini correctly recovered the function's computational behavior and proposed reasonable generic names. However, its explanation did not identify the original authentication-related purpose.

## Limitations
- The binary was stripped, removing original function names.
- The prompt described the function as producing a classification result.
- The original business purpose could not be uniquely determined from the numeric logic.
- Exact MCP tool-call count and API cost still need verification.

## Evidence
- session.jsonl
- telemetry.log
- Screenshots:
![alt text](<Screenshot 2026-11-22 102221.png>)
![alt text](<Screenshot 2026-11-22 110646.png>)
![alt text](<Screenshot 2026-11-22 110718.png>)
![alt text](<Screenshot 2026-11-22 110756.png>)
![alt text](<Screenshot 2026-11-22 110818.png>)

## Verification
Executable tests:
- ./cases/mohamed/bin/case01 3 8 1 -> 2
- ./cases/mohamed/bin/case01 2 20 0 -> 1
