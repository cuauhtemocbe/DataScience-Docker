---
name: trivy-scan
description: Security scanning with Trivy. Use it when the user asks for a vulnerability analysis, security scan, secrets detection, IaC misconfiguration review, or to review vulnerable project dependencies.
---

Run a multi-scanner security scan with Trivy on the current project, analyze the results, and propose remediation for found vulnerabilities, exposed secrets, and IaC misconfigurations.

## Flow

### 0. Check prerequisites

```bash
trivy --version
```

If the command fails, read `skills/trivy-scan/setup.md` and guide the user step by step until Trivy is confirmed available. Do not continue until setup is complete.

### 1. Detect project context

Before scanning, check what targets are present to expand coverage automatically:

```bash
# Check for container images
ls Dockerfile* docker-compose* .dockerignore 2>/dev/null

# Check for IaC files
find . -maxdepth 3 \( -name "*.tf" -o -name "*.tfvars" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) | grep -E "(terraform|k8s|kubernetes|helm|cloudformation|infra)" | head -10

# Check for a trivy.yaml config
ls trivy.yaml .trivy.yaml 2>/dev/null
```

Use this to determine which scanners to enable:
- **Always**: `--scanners vuln,secret`
- **Add `misconfig`** if `.tf`, Kubernetes YAML, Helm charts, or Dockerfiles are found: `--scanners vuln,secret,misconfig`

### 2. Scan

**Default scan (filesystem — vulnerabilities + secrets):**

```bash
trivy fs . --scanners vuln,secret --severity CRITICAL,HIGH,MEDIUM --format table --quiet
```

**With IaC/misconfigurations detected:**

```bash
trivy fs . --scanners vuln,secret,misconfig --severity CRITICAL,HIGH,MEDIUM --format table --quiet
```

**With container image:**

```bash
trivy image <image-name> --severity CRITICAL,HIGH,MEDIUM --format table --quiet
```

**Options to offer the user:**

- Include LOW/INFO: remove `--severity` filter
- Skip unfixed vulnerabilities (less noise): add `--ignore-unfixed`
- SARIF output for GitHub Security tab: `--format sarif --output trivy-results.sarif`
- Generate SBOM: `trivy fs . --format cyclonedx --output sbom.cdx.json`

If a `trivy.yaml` config file exists, Trivy will pick it up automatically — no extra flags needed.

### 3. Present summary

After the scan, show a table with:

| Severity | Count | Fix Available | Examples (max. 3) |
|----------|-------|---------------|-------------------|
| CRITICAL | N     | X/N           | pkg@version → CVE |
| HIGH     | N     | X/N           | pkg@version → CVE |
| MEDIUM   | N     | X/N           | pkg@version → CVE |
| SECRETS  | N     | —             | type → file:line  |
| MISCONFIG| N     | —             | check → file      |

Group by type (vulnerabilities / secrets / misconfigurations). Only list CRITICAL and HIGH in detail — summarize MEDIUM counts.

### 4. Analyze critical and high findings

**For each CRITICAL/HIGH vulnerability:**

- **Affected package** and current version
- **CVE** with brief risk description
- **Fixed version** (if available) — state explicitly if no fix exists
- **Recommended action**: upgrade, replace, or alternative mitigation (e.g. WAF rule, disable functionality)

**For each secret finding:**

- **Type** (e.g. AWS key, GitHub token, private key)
- **File and line** where it was found
- **Recommended action**: rotate the credential immediately, move to environment variable or secrets manager, add to `.gitignore`

**For each CRITICAL/HIGH misconfiguration:**

- **Check ID** and description
- **Affected file**
- **Recommended fix**

### 5. Propose solution

Generate exact remediation commands:

```bash
# Example — npm
npm install lodash@4.17.21

# Example — pip
pip install urllib3==1.26.18

# Example — go
go get golang.org/x/net@v0.17.0 && go mod tidy
```

For accepted false positives or unfixable CVEs, propose creating a `.trivyignore.yaml` entry:

```yaml
# .trivyignore.yaml
vulnerabilities:
  - id: CVE-XXXX-XXXXX
    statement: "No fix available — monitoring for patch. Accepted by <name> on YYYY-MM-DD."
    expired_at: "YYYY-MM-DD"  # review date, max 90 days
```

Present all changes before executing. **Do not apply anything without confirmation.**

### 6. Wait for confirmation

Ask the user:

> Should I apply the proposed changes?

Do not continue until receiving explicit confirmation.

### 7. Implement

Execute the approved commands. Confirm that `package.json`, `requirements.txt`, `go.mod`, `.trivyignore.yaml`, or similar files were updated as expected.

### 8. Verify — max 3 cycles

Re-run Trivy to confirm remediated findings are gone:

```bash
trivy fs . --scanners vuln,secret --severity CRITICAL,HIGH --format table --quiet --skip-db-update
```

Then run the project tests to detect regressions:

```bash
pnpm test       # Node.js
pytest          # Python
go test ./...   # Go
```

If new findings appear after the fix, repeat from step 4. **Stop after 3 fix-scan cycles** and report remaining issues — do not loop indefinitely.

If tests fail, report the error and **do not** mark the task as done until resolved.

---

## Rules

- **Always confirm before modifying files.** The scan is passive; changes are not.
- If no fixed version exists, document the CVE in `.trivyignore.yaml` as "accepted" with justification and an expiration date. Do not silently ignore it.
- MEDIUM vulnerabilities are mentioned in the summary but do not block — the user decides whether to address them.
- LOW and INFO are only reported if the user explicitly requests them.
- Secrets findings are always CRITICAL regardless of the reported severity level — recommend immediate credential rotation.
- When suppressing with `--ignore-unfixed`, track the count of suppressed CVEs and report it ("N findings suppressed — no fix available").
- Maximum 3 fix-scan iteration cycles before escalating to the user.

---

## Extended coverage checklist

| Signal in project | Additional scan to run |
|---|---|
| `Dockerfile` or `docker-compose.yml` | `trivy image <image>` after building |
| `.tf` / `.tfvars` files | `trivy config .` (IaC misconfigurations) |
| `*.yaml` with `kind: Deployment` | Kubernetes manifests covered by `--scanners misconfig` |
| Helm `Chart.yaml` | `trivy fs . --scanners misconfig` picks it up |
| Running cluster | `trivy k8s --report summary cluster` |
| No `trivy.yaml` in repo root | Offer to create one for consistent team settings |
| GitHub Actions in `.github/` | `--scanners misconfig` covers GitHub Actions files |

---

## Suggested `trivy.yaml` for new projects

If no config file exists and the user wants consistent settings, offer to create one:

```yaml
# trivy.yaml
severity:
  - CRITICAL
  - HIGH
  - MEDIUM
scanners:
  - vuln
  - secret
  - misconfig
exit-code: 1
ignorefile: .trivyignore.yaml
format: table
```

This replaces CLI flags and ensures every developer and CI run uses the same settings.
