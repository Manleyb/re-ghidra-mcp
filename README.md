# AI-Assisted Reverse Engineering & Deobfuscation

Phase 1 baseline: **Gemini CLI + LaurieWired GhidraMCP**. Setup steps, pinned versions and the end-to-end test are in **[SETUP.md](SETUP.md)**.

```
agent/      where you launch `gemini` (shared config; Ghidra MCP tools only)
cases/      each member's C source, binaries and expected outputs (kept from the agent)
test/       setup smoke-test program + shared build flags
results/    saved runs (session record, telemetry, notes) + RESULTS.md table
scripts/    check_setup.sh (versions + checks), save_run.sh (save evidence)
docs/       project planning PDFs
```

Never commit `.env`, API keys or credentials.
