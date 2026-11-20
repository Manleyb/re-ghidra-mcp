# Expected behaviour of test/hello (setup smoke test)

Do not show this file to the agent.

- `./hello` with no argument prints the usage line and exits 2.
- Accepts a 6-character input whose djb2 hash (seed 5381, h = h*33 + c, 32-bit) mod 7 == 3.
  It prints `ok` and exits 0. Otherwise it prints `nope` and exits 1.
- Example accepted input: `aaaaac`
- Functions: `main`, `is_valid` (length == 6 && checksum % 7 == 3), `checksum` (djb2).
- sha256 of binary built on the reference machine: 86c822e7aa9fca9e41f0e319735b6d2097eeccf851e8c81945703c79b3caf8c9
