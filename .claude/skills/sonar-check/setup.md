# SonarQube Setup

Interactive step-by-step guide. Claude executes commands that do not require user intervention and asks for input only when necessary.

---

## Quick Start (for experienced users)

Already familiar with SonarQube and MCP? Here's the fast path:

```bash
# 1. Start SonarQube Docker container
docker run -d --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  sonarqube:latest

# 2. Configure MCP server (auto-creates .mcp.json with full config and approves server)
source .env && claude mcp add sonarqube \
  --env SONARQUBE_TOKEN=$SONAR_TOKEN \
  --env SONARQUBE_URL=http://localhost:9000 \
  --env SONARQUBE_PROJECT_KEY=$(grep sonar.projectKey sonar-project.properties | cut -d= -f2) \
  -- npx @sonar/mcp-server-sonarqube

# This creates .mcp.json with all required flags: --network host, env vars, etc.

# 3. Configure test coverage (see Part C)

# 4. Verify and run
ping_system  # Should return 'pong'
/sonar-check
```

**First time?** Follow the detailed guide below.

---

## Part A: SonarQube MCP Server ⚠️ REQUIRED ⚠️

**The MCP server is MANDATORY for the `sonar-check` skill.** Without it, the skill will stop and ask you to complete this setup.

**Why MCP is required:**
- ✅ Direct, structured access to SonarQube (no bash/curl)
- ✅ 10x fewer tokens consumed
- ✅ Instant per-file analysis via `analyze_code_snippet` (no full scanner needed in fix loops)
- ✅ Type-safe API calls with proper error handling
- ✅ Parallel queries for faster results

**Estimated time:** 5 minutes

### Step 1: Add MCP server configuration

**Choose ONE of the following options:**

**Option A: Using CLI (Recommended)**

```bash
source .env && claude mcp add sonarqube \
  --env SONARQUBE_TOKEN=$SONAR_TOKEN \
  --env SONARQUBE_URL=http://localhost:9000 \
  --env SONARQUBE_PROJECT_KEY=$(grep sonar.projectKey sonar-project.properties | cut -d= -f2) \
  -- npx @sonar/mcp-server-sonarqube
```

This creates `.mcp.json` automatically with the full Docker config (including `--network host`, all env vars, and proper flags) and prompts you to approve the server.

**Option B (Manual): Create `.mcp.json`**

If you prefer manual setup, create `.mcp.json` in the project root with the **full Docker config**:

```json
{
  "mcpServers": {
    "sonarqube": {
      "command": "docker",
      "args": [
        "run",
        "--init",
        "--pull=always",
        "-i",
        "--rm",
        "--network",
        "host",
        "-e",
        "SONARQUBE_TOKEN",
        "-e",
        "SONARQUBE_URL",
        "-e",
        "SONARQUBE_PROJECT_KEY",
        "mcp/sonarqube"
      ],
      "env": {
        "SONARQUBE_URL": "http://localhost:9000",
        "SONARQUBE_TOKEN": "<paste sqa_xxxxx token here>",
        "SONARQUBE_PROJECT_KEY": "<sonar.projectKey from sonar-project.properties>"
      }
    }
  }
}
```

**Key configuration points:**
- `--network host` — **REQUIRED** so the MCP container can reach SonarQube at `localhost:9000`
- `SONARQUBE_TOKEN` — Same as `SONAR_TOKEN` in `.env` (just different variable name)
- `SONARQUBE_PROJECT_KEY` — **Recommended** to avoid passing `projectKey` in every MCP call
- `--pull=always` — Ensures you always use the latest MCP server version

**After manual setup:** Approve the MCP server by adding to `.claude/settings.local.json`:

```json
{
  "enableAllProjectMcpServers": true
}
```

Or approve only the SonarQube server specifically:

```json
{
  "enabledMcpjsonServers": ["sonarqube"]
}
```

### Step 2: Verify MCP connection

**If you used Option A (`claude mcp add`):** 
- ✅ The server is already configured, approved, and loaded
- ✅ No restart needed
- ✅ Skip to verification below

**If you used Option B or C (manual `.mcp.json`):** 
- Restart Claude Code to load the MCP server

Verify the connection by calling:

```
ping_system
```

If it returns `pong`, the MCP server is connected and the `sonar-check` skill will use the fast MCP path automatically.

**Troubleshooting:** 

**"No matching deferred tools found"** → Server not loaded. Check:
- `.mcp.json` exists in project root with correct syntax
- Server is approved in `.claude/settings.local.json` (or via `claude mcp add`)
- Claude Code was restarted after creating these files (manual setup only)

**"Failed to connect" in `claude mcp list`** → Check:
- Docker is running: `docker info`
- Environment variables are set correctly in `.mcp.json`
- SonarQube container is running and accessible at the configured URL
- **Restart Claude Code** after configuration changes

**Environment variable mapping:**
- Shell environment: `SONAR_TOKEN` → Container environment: `SONARQUBE_TOKEN`
- The `.mcp.json` file maps these variables using the `env` section

### Step 3: Available MCP tools

| Tool | Purpose | Replaces |
|---|---|---|
| `ping_system` | Health check | `curl /api/system/status` |
| `analyze_code_snippet` | Instant per-file analysis (no full scan) | Docker scanner in fix loop |
| `get_project_quality_gate_status` | Gate status after full scan | `curl /api/qualitygates/project_status` |
| `search_sonar_issues_in_projects` | Issues with severity/scope filter | `curl /api/issues/search` + python parse |
| `search_files_by_coverage` | Files below coverage threshold | Manual coverage checks |
| `search_security_hotspots` | Security hotspots (new code) | Separate hotspot review |
| `show_rule` | Rule description + fix guidance | Web search for rule docs |
| `get_component_measures` | Metrics per file/module | `curl /api/measures/component` |

`SONARQUBE_PROJECT_KEY` in env removes the `projectKey` parameter from every tool call.

---

## Part B: SonarQube Server (Docker)

**Estimated time:** 10 minutes (first time), 2 minutes (if already configured)

**Why standalone Docker instead of docker-compose?**
- ✅ **Reusable across projects** — one SonarQube instance serves all your projects
- ✅ **Simpler setup** — no need to modify each project's docker-compose.yml
- ✅ **Persistent state** — data survives between `docker stop/start` cycles
- ✅ **Lightweight** — no additional compose overhead

### Step 1: Check container status

```bash
docker ps -a --filter "name=sonarqube" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

- **Up** → skip to Step 3 (or Step 4 if token already exists in `.env`).
- **Exited / stopped** → restart it: `docker start sonarqube`
- **Not listed** → proceed to Step 2 to create the container.

### Step 2: Start SonarQube

**First time setup:**

```bash
docker run -d --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  sonarqube:latest
```

**If container exists but is stopped:**

```bash
docker start sonarqube
```

Wait for ready (~2 min):

```bash
until curl -s http://localhost:9000/api/system/status | grep -q '"status":"UP"'; do sleep 5; done && echo "SonarQube ready"
```

### Step 3: Initial browser configuration

These steps require user action in the browser:

1. Open http://localhost:9000
2. Login with `admin` / `admin`
3. Change the password when prompted
4. Go to **My Account → Security → Generate Token**
5. Token name: `local-dev`, type: `User Token`
6. Copy the generated token (`sqp_xxxxx`)

Ask the user: **"Have you copied the token?"** and wait for them to share or confirm.

### Step 4: Save the token in .env

```bash
echo "SONAR_TOKEN=<token>" >> .env
grep SONAR_TOKEN .env
```

### Step 5: Generate sonar-project.properties

If `sonar-project.properties.example` exists, copy it:

```bash
cp sonar-project.properties.example sonar-project.properties
```

Otherwise ask the user:

1. **"What is the project name?"** → derive `sonar.projectKey` in kebab-case
2. **"Language: TypeScript or Python?"**
3. **"Source directory?"** (default: `src`)
4. **"Tests directory?"** (default: `src` for TS, `tests` for Python)

**TypeScript:**
```properties
sonar.projectKey=<kebab-case>
sonar.projectName=<name>
sonar.projectVersion=1.0
sonar.language=ts
sonar.sources=src
sonar.tests=src
sonar.test.inclusions=src/**/*.spec.ts
sonar.exclusions=**/*.spec.ts,**/*.module.ts,**/*.model.ts,**/*.schema.ts,**/main.ts,**/setup.ts
sonar.javascript.lcov.reportPaths=coverage/unit-test-coverage.lcov
sonar.coverage.exclusions=**/*.spec.ts,**/*.module.ts,**/main.ts
```

**Python:**
```properties
sonar.projectKey=<kebab-case>
sonar.projectName=<name>
sonar.host.url=http://sonarqube:9000
sonar.sources=src
sonar.tests=tests
sonar.language=py
sonar.exclusions=**/__pycache__/**,**/.venv/**
sonar.python.coverage.reportPaths=coverage.xml
```

Show the file to the user and ask for confirmation before writing.

### Step 6: Verify token

```bash
curl -s -u "$(grep SONAR_TOKEN .env | cut -d= -f2):" \
  http://localhost:9000/api/authentication/validate | grep -o '"valid":[^,}]*'
```

`"valid":true` → server setup complete. **You MUST continue to Part A** to set up the MCP server (required for the skill to work), and **Part C** to configure test coverage.

### Step 7: Create sonar-project.properties (if needed)

If you skipped Step 5 earlier, this file is still needed. See Step 5 above for templates and configuration options.

### Step 8: Managing the SonarQube container

**Useful commands for the standalone container:**

```bash
# Check container status
docker ps --filter "name=sonarqube"

# Stop the container (preserves data)
docker stop sonarqube

# Start the container again
docker start sonarqube

# View logs
docker logs sonarqube -f

# Restart the container
docker restart sonarqube

# Remove the container (keeps volumes/data)
docker rm sonarqube

# Remove the container AND all data (⚠️ destructive)
docker rm -v sonarqube
docker volume rm sonarqube_data sonarqube_logs sonarqube_extensions
```

**Note:** The volumes (`sonarqube_data`, `sonarqube_logs`, `sonarqube_extensions`) persist your SonarQube configuration, projects, and analysis history. They survive container stop/start cycles.

---

## Part C: Test Coverage Configuration ⚠️ CRITICAL ⚠️

**Estimated time:** 5 minutes

### Why this matters

SonarQube needs test frameworks to generate LCOV (or XML) coverage files. Without proper configuration, coverage will show as 0% even when tests run successfully.

**Symptoms of misconfiguration:**
- Tests run successfully with coverage output in console
- SonarQube scan shows: "No LCOV files were found using coverage/lcov.info"
- Coverage metric in SonarQube is 0.0%

### For Vitest (TypeScript/React/Vue)

Check if `vite.config.ts` or `vitest.config.ts` has coverage reporters configured:

```bash
grep -A 5 "coverage:" vite.config.ts vitest.config.ts 2>/dev/null
```

If missing or incomplete, add/update the coverage configuration:

```typescript
import { defineConfig } from 'vitest/config'  // ← Must use 'vitest/config' not 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    coverage: {
      provider: 'v8',  // or 'istanbul'
      reporter: ['text', 'lcov', 'html'],
      reportsDirectory: './coverage',
    },
  },
})
```

**Key points:**
- Import `defineConfig` from `'vitest/config'` not `'vite'` — otherwise TypeScript won't recognize the `test` property
- The `lcov` reporter is required — `text` and `html` are optional but useful
- The default `reportsDirectory` is `./coverage`, which matches SonarQube's default `coverage/lcov.info` path

### For Jest (TypeScript/React)

Check `jest.config.js` or `package.json`:

```javascript
module.exports = {
  coverageReporters: ['text', 'lcov'],
  coverageDirectory: './coverage',
}
```

### For pytest (Python)

Install and configure `pytest-cov`:

```bash
pip install pytest-cov
```

Run with coverage:

```bash
pytest --cov=src --cov-report=xml
```

Update `sonar-project.properties`:
```properties
sonar.python.coverage.reportPaths=coverage.xml
```

### Verify coverage files exist

After running tests with coverage, confirm the LCOV/XML file was generated:

```bash
# Vitest/Jest
ls -lh coverage/lcov.info

# pytest
ls -lh coverage.xml
```

If the file doesn't exist, SonarQube will show 0% coverage regardless of test results.

---

## Part D: Auto-Scan on File Edit (Optional)

**Estimated time:** 2 minutes

This hook runs `analyze_code_snippet` via the MCP server automatically after every file edit — catching issues in real time without invoking `/sonar-check` manually.

**Note:** This is an optional enhancement. The `/sonar-check` skill works perfectly without this hook.

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'File edited — run analyze_code_snippet on changed file via sonar-check skill if quality issues are suspected'"
          }
        ]
      }
    ]
  }
}
```

> For full automated analysis on every edit, replace the echo with a call to `sonar analyze sqaa` if you have the SonarQube CLI installed (`sonar` binary from the official plugin).
