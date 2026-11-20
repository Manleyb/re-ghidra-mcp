# Test cases

One folder per member: `src/` (C source, kept from the agent), `bin/` (compiled binary given to Ghidra),
`expected/` (expected outputs + answer, kept from the agent).

| Member  | First test program |
|---|---|
| mohamed | Unknown-function identification |
| sami    | XOR or character-shift string decoding |
| bryce   | Confusing conditional / control flow |
| maryam  | Input acceptance / rejection conditions |

Rules:
- Build with the shared flags in `test/build.sh` (`gcc -O0 -fno-inline -g0`) unless your case needs different ones. Write them down.
- Never paste source or expected answers into the Gemini session. Gemini runs from `agent/`, has its file and shell tools turned off, and can only see what Ghidra shows it.
- Save expected output by actually running the binary (`./bin/x args > expected/run1.txt`).
