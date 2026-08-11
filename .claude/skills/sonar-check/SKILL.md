---
name: sonar-check
description: Code quality analysis with SonarQube. Use it when the user asks to verify quality, review the Quality Gate, analyze code smells, fix issues, or before pushing.
---

Verify code quality with SonarQube and ensure the Quality Gate is **PASSED** before recommending a push. Never loop more than **3 fix-scan cycles**.

---

## Prerequisites

**Before using this skill, verify:**

1. ✅ **SonarQube MCP server configured** (see `skills/sonar-check/setup.md` → Part A)
2. ✅ **SonarQube Docker container running** (standalone pod, see `skills/sonar-check/setup.md` → Part B)
3. ✅ **Test coverage properly configured** (see `skills/sonar-check/setup.md` → Part C)

**Quick check:** 
- Call `ping_system` — if it returns `pong`, you're ready to proceed.
- Verify container: `docker ps --filter "name=sonarqube" --format "{{.Status}}"`

**If prerequisites are incomplete:**
- Read `skills/sonar-check/setup.md` and complete the missing parts
- MCP is MANDATORY — without it, this skill cannot function

---

## Workflow

### Step 1: Quick scan on changed files

Get the list of modified files:

```bash
git diff --name-only HEAD
```

For each changed source file, call:

```
analyze_code_snippet(filePath="<path>", language="<ts|py|java|js>")
```

This gives immediate issue feedback without starting the Docker scanner. Fix all BLOCKER and CRITICAL issues before continuing — this avoids wasted scanner runs.

Before fixing any issue, call `show_rule(key="<ruleId>")` to understand the root cause and the correct fix pattern. Do not guess.

### Step 2: Run tests with coverage

Check which coverage script is available:

```bash
# Try common script names
pnpm test:coverage 2>/dev/null || pnpm test:cov 2>/dev/null || npm run test:coverage 2>/dev/null || npm run test -- --coverage
```

If tests fail, **stop here**.

### Step 3: Full scan (updates server state and coverage)

Run once after fixes are clean to push results to the SonarQube server:

```bash
source .env && docker run --rm --network host \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v $(pwd):/usr/src -w /usr/src \
  sonarsource/sonar-scanner-cli:latest \
  sonar-scanner -Dsonar.host.url=http://localhost:9000
```

### Step 4: Read results via MCP (parallel calls)

After the scan, call these tools in parallel — no curl, no shell parsing:

| Goal | MCP call |
|---|---|
| Quality Gate status | `get_project_quality_gate_status(projectKey="<key>")` |
| Open issues (new code) | `search_sonar_issues_in_projects(projects=["<key>"])` |
| Low-coverage files | `search_files_by_coverage(projectKey="<key>", maxCoverage=80)` |
| Security hotspots | `search_security_hotspots(projectKey="<key>", sinceLeakPeriod=true)` |

If `SONARQUBE_PROJECT_KEY` is set in the MCP server env, omit `projectKey` from every call.

### Step 5: Triage and fix

Fix in severity order — do not start lower until higher is resolved:

| Priority | Severity | Action |
|---|---|---|
| 1 | BLOCKER | Fix immediately — blocks push |
| 2 | CRITICAL | Fix immediately — blocks push |
| 3 | MAJOR | Fix before pushing |
| 4 | Low coverage | **Blocker** — generate unit tests |
| 5 | Security hotspots | Investigate; mark resolved or fix |
| 6 | MINOR / INFO | Fix if quick; otherwise note in report |

Always call `show_rule(key="<ruleId>")` before fixing. Fix root design issues, not symptoms — a surface-level patch often triggers a secondary rule violation on re-scan.

Only fix **new code issues** (introduced in this branch). Pre-existing project-wide violations are not blockers unless the user asks.

### Step 6: Iterate (max 3 cycles)

- **Cycles 1–2 (fix loop):** After edits, call `analyze_code_snippet` on changed files again — no Docker scan needed. Fast and cheap.
- **Cycle 3 (final):** Run full Docker scan + MCP gate check to confirm.
- **After 3 cycles with issues remaining:** Stop. Report each issue with severity, rule ID, file:line, and reason it was not resolved. Ask the user how to proceed.

When Quality Gate is **PASSED**:

> Quality Gate: PASSED. The code is ready to push.

---

## Rules

- **MCP is mandatory** — if `ping_system` fails, stop and guide the user to `skills/sonar-check/setup.md` → Part A
- **Never recommend pushing with Quality Gate in ERROR.**
- **Never exceed 3 fix-scan cycles.** Stop and report after 3.
- Low coverage is a blocker — generate tests, do not skip.
- Fix new-code issues only; ignore pre-existing project-wide violations.
- **Do not use `build.config/.env`** — it is a Helm template, not a valid env file.
- If `sonar-project.properties` is missing, read `skills/sonar-check/setup.md` → Part B.

---

## Quick Troubleshooting

If you encounter issues, refer to the detailed setup guide:

| Issue | Solution |
|---|---|
| **MCP not connected** (`ping_system` fails) | `skills/sonar-check/setup.md` → Part A |
| **Docker container not running** | `skills/sonar-check/setup.md` → Part B |
| **Coverage shows 0%** despite tests passing | `skills/sonar-check/setup.md` → Part C |
| **Missing `sonar-project.properties`** | `skills/sonar-check/setup.md` → Part B, Step 5 |
