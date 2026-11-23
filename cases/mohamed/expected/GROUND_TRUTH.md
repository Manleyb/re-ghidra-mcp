# Ground truth — Mohamed Beta Case 01

**Keep this file out of Gemini's prompt and workspace.**

Original function purpose: assess login risk from failed attempts, minutes since last failure, and trusted-device flag.
Suggested meaningful name: `assess_login_risk` or `classify_login_risk`.

Return codes: -1 invalid data; 0 allow; 1 challenge; 2 block.

| Binary arguments (three integers) | Observed stdout | Interpretation |
|---|---|---|
| `0 0 1` | `0` | allow |
| `2 20 0` | `1` | challenge |
| `2 20 1` | `0` | allow |
| `3 8 1` | `2` | block |
| `3 25 0` | `1` | challenge |
| `5 300 1` | `2` | block |
| `-1 5 1` | `-1` | invalid |
| `4 11 1` | `0` | allow |
| `4 10 1` | `2` | block |
