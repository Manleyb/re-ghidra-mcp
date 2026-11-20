# Shared Setup: Gemini CLI + Ghidra MCP (Phase 1 baseline)

Everyone uses this exact setup. Don't swap in a different MCP server, client or model.
If something doesn't work, post in Discord instead of changing the setup.

## Pinned versions

| Component | Version | Notes |
|---|---|---|
| OS | Linux (tested on Ubuntu 24.04) | |
| Ghidra | **12.1.4** (`ghidra_12.1.4_PUBLIC`) | Must match the GhidraMCP release below |
| GhidraMCP (LaurieWired) | **release 2.0.0**: `ghidra_12.1.4_PUBLIC_20261010_GhidraMCP.zip` + `ghidra_mcp-2.0.0` Python bridge | https://github.com/LaurieWired/GhidraMCP/releases |
| Java | OpenJDK 21 | Needed by Ghidra |
| Python | 3.12 | For the bridge's venv |
| Node.js | 22 (installed with nvm) | Gemini CLI needs 20+ |
| Gemini CLI | **0.70.0** | `npm i -g @google/gemini-cli@0.70.0` |
| Google Cloud SDK | 594.0.0 or newer | Only used for login |
| Model | **`gemini-3.8-flash`** (set in `agent/.gemini/settings.json`) | Same for everyone. Don't use `/model` or Auto. Verify with `./scripts/check_setup.sh --live` |
| Login | Vertex AI with your own Google account | Billed to your own AI Pro developer credits |
| gcc | 13.3 | Build flags: `-O0 -fno-inline -g0` |

## How it fits together

```
you ──> gemini (run from agent/) ──stdio──> ghidra-mcp bridge ──HTTP :8080──> GhidraMCP plugin inside Ghidra GUI
          │                                                                     (binary open in CodeBrowser)
          └── Vertex AI (your own Google Cloud project, paid by your own credits)
```

Gemini is started from `agent/`. That folder holds only the config and logs.
Gemini's file, shell and web tools are turned off, so its only tools are the Ghidra ones.
It can't read the C source in `cases/`, which is how we keep the answers from the agent.

---

## 1. Google Cloud + credits (browser, one time)

1. Claim the Google Developer Program credits that come with Google AI Pro ($10/month), and link them to a Cloud billing account.
2. Create a Google Cloud project (https://console.cloud.google.com/projectcreate) and attach it to that billing account.
3. Turn on the **Vertex AI API** for the project (APIs & Services → Enable APIs → "Vertex AI API").
4. **Set a budget alert** at $10 (Billing → Budgets & alerts).
5. Write down your **project ID**.

## 2. Install the tools

```bash
# Build tools
sudo apt install -y build-essential openjdk-21-jdk python3-venv git curl unzip

# Ghidra 12.1.4: unzip into ~/ghidra/
#   https://github.com/NationalSecurityAgency/ghidra/releases  → ghidra_12.1.4_PUBLIC_*.zip
mkdir -p ~/ghidra && unzip ghidra_12.1.4_PUBLIC_*.zip -d ~/ghidra

# GhidraMCP 2.0.0: download the release zip from LaurieWired/GhidraMCP into ~/ghidramcp/
#   (the release zip unpacks to GhidraMCP-release-2-0/ with the Ghidra extension zip + the bridge wheel)
mkdir -p ~/ghidramcp && cd ~/ghidramcp && unzip ~/Downloads/<GhidraMCP-release-zip>.zip
python3 -m venv ~/ghidramcp/venv
~/ghidramcp/venv/bin/pip install ~/ghidramcp/GhidraMCP-release-2-0/ghidra_mcp-2.0.0-py3-none-any.whl

# Node 22 + Gemini CLI (no sudo)
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc && nvm install 22 && nvm alias default 22
npm install -g @google/gemini-cli@0.70.0

# Google Cloud SDK (no sudo, installs to ~/google-cloud-sdk)
curl -fsSLo ~/gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xzf ~/gcloud.tar.gz -C ~ && rm ~/gcloud.tar.gz
~/google-cloud-sdk/install.sh --quiet --path-update true
source ~/.bashrc
```

**Paths matter:** `agent/.gemini/settings.json` expects the bridge at `~/ghidramcp/venv/bin/ghidra-mcp`.

## 3. Install the Ghidra plugin

1. Start Ghidra: `~/ghidra/ghidra_12.1.4_PUBLIC/ghidraRun`
2. **File → Install Extensions → +** and pick `~/ghidramcp/GhidraMCP-release-2-0/ghidra_12.1.4_PUBLIC_20261010_GhidraMCP.zip`, then restart Ghidra.
3. Create a project, import a binary and open it in **CodeBrowser**.
4. In CodeBrowser: **File → Configure → Developer** and tick **GhidraMCPPlugin**.
   The plugin then serves on `127.0.0.1:8080` (change it under Edit → Tool Options → GhidraMCP if needed).

## 4. Clone the repo and log in

```bash
git clone <repo-url> && cd <repo>
cp .env.example .env          # then set GOOGLE_CLOUD_PROJECT to YOUR project ID
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login     # this is the login Gemini CLI uses
./scripts/check_setup.sh                   # everything should say OK once Ghidra is open
./scripts/check_setup.sh --live            # also sends one tiny prompt and shows which model really answered
```

Don't put API keys anywhere. Vertex AI uses your gcloud login. `.env` is git-ignored and holds only your project ID.

## Available MCP operations (GhidraMCP 2.0.0, 30 tools)

In Gemini they appear as `mcp_ghidra_<name>`. Every one of them was listed live from the bridge against Ghidra 12.1.4.

| Group | Tools |
|---|---|
| Program overview | `get_program_info`, `list_segments`, `list_imports`, `list_exports`, `list_strings`, `list_data_items`, `list_classes`, `list_namespaces` |
| Functions | `list_functions`, `search_functions_by_name`, `get_function_by_address`, `list_methods` (deprecated) |
| Code | `decompile_function`, `decompile_function_by_address`, `disassemble_function`, `read_memory` |
| Cross-refs / call graph | `get_xrefs_to`, `get_xrefs_from`, `get_function_xrefs`, `get_function_calls` |
| GUI selection | `get_current_address`, `get_current_function` |
| Annotate (writes to your Ghidra project) | `rename_function`, `rename_function_by_address`, `rename_data`, `rename_variable`, `set_function_prototype`, `set_local_variable_type`, `set_decompiler_comment`, `set_disassembly_comment` |

The annotate tools change your Ghidra project. Re-import the binary fresh for each experiment so earlier renames don't leak hints.

## 5. End-to-end test (the "ready-to-start" checkpoint)

1. `./test/build.sh`, then in Ghidra import `test/hello`, let auto-analysis run, open it in CodeBrowser, and make sure the plugin is on.
2. Start the agent **from `agent/`**:
   ```bash
   cd agent && gemini
   ```
   The first time, trust the folder when asked and check that the footer says Vertex AI and `gemini-3.8-flash`.
3. Type `/mcp`. You should see **ghidra - Connected** and its tool list. Take a screenshot.
4. Paste this prompt exactly:
   > Using only the Ghidra MCP tools, list the functions in the loaded binary, decompile `main` and every function it calls, then explain what input the program accepts. Name each tool you call.
5. Approve the tool calls. Gemini should call things like `list_functions` and `decompile_function`. Take a screenshot.
6. `/quit`, then save the evidence:
   ```bash
   cd .. && ./scripts/save_run.sh <your-name> setup-smoke-test
   ```
   Fill in `NOTES.md` in that folder. The correct answer is in `test/EXPECTED.md`; don't show it to the agent.
7. Note the cost of the run in the Cloud console (Billing → Reports; it can show up hours later) and post it in Discord.

You're ready when the `/mcp` screenshot, the tool-call screenshot and the saved `session.json*` / `telemetry.log` exist.

## Experiment rules (from the beta plan)

- Start a **fresh `gemini` session for every case**: `/quit` and relaunch, and don't resume.
- Only the binary goes into Ghidra. Never paste source or expected answers into the chat.
- Run `./scripts/save_run.sh <member> <case>` after every run, and add a row to `results/RESULTS.md`.
- Never change `agent/.gemini/settings.json` (model, tools) on your own. Changes go through the setup lead so everyone stays identical.

## Known issues / notes

- **Model swap (important):** Gemini CLI 0.70.0 silently swaps `gemini-3.5-flash` for `gemini-3.8-flash` when your account has access to the newer model.
  That's why we pin `gemini-3.8-flash` itself. Run `./scripts/check_setup.sh --live`: it must say `models used: ['gemini-3.8-flash']`.
  If it shows anything else, tell the setup lead before running experiments.

- **"tools.exclude is deprecated" warning** when Gemini starts: harmless in 0.70.0. That's why the CLI version is pinned.
- **Model fallback:** if Vertex returns quota or errors, Gemini CLI may *offer* to switch models. **Say no** and retry later, otherwise your run uses a different model. Note it in NOTES.md if it happens.
- **`/mcp` shows ghidra connected but tool calls fail:** Ghidra isn't open, no binary is open in CodeBrowser, or the plugin isn't enabled. Check `curl http://127.0.0.1:8080/` and run `./scripts/check_setup.sh`.
- **"API key" or auth prompt instead of Vertex:** `unset GEMINI_API_KEY GOOGLE_API_KEY`, make sure `.env` has your project, and rerun `gcloud auth application-default login`.
- **`gemini: command not found` in a new terminal:** run `source ~/.bashrc` (nvm), or `nvm use 22`.
- **Headless option (not used for the baseline):** the bridge can also run Ghidra without the GUI (`ghidra-mcp --headless --binary <path>`). We stick with GUI mode so there are screenshots for the demo.
