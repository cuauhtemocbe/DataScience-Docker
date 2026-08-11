# Trivy Setup

Step-by-step installation guide. Claude executes commands that do not require user intervention.

---

## Step 1: Check if already installed

```bash
trivy --version
```

If it responds with a version → setup complete, continue with the normal `trivy-scan` flow.

If the command fails → continue with Step 2.

## Step 2: Choose installation method

Ask the user:

> **"Do you prefer to install Trivy locally or use it via Docker without installing anything?"**

- If they choose **Docker** → go to Step 3b.
- If they choose **local** (or do not respond) → go to Step 3a.

## Step 3a: Local installation

Detect the operating system:

```bash
uname -s
```

**macOS:**
```bash
brew install trivy
```

**Linux — via apt (recommended):**
```bash
sudo apt-get install wget apt-transport-https gnupg -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install trivy -y
```

**Linux — via snap (alternative if apt fails):**
```bash
sudo snap install trivy
```

Verify installation:

```bash
trivy --version
```

If the version appears → installation successful. Continue with the normal `trivy-scan` flow.

## Step 3b: Use Trivy via Docker (no installation)

No additional setup required. The scan runs directly with:

```bash
docker run --rm -v $(pwd):/workdir aquasec/trivy:latest fs /workdir --scanners vuln,secret --severity CRITICAL,HIGH,MEDIUM --quiet
```

Confirm with the user that Docker is available:

```bash
docker --version
```

If Docker is not available → go back to Step 3a for local installation.

---

## CI/CD — Vulnerability database caching

Trivy downloads its vulnerability database on each cold run (~30 MB). In CI/CD, cache the DB directory to avoid the download on every run:

```bash
# Pre-warm the DB (run once per day / cache by date)
trivy image --download-db-only

# Then scan without re-downloading
trivy fs . --skip-db-update --scanners vuln,secret --severity CRITICAL,HIGH,MEDIUM
```

Cache the directory `~/.cache/trivy` (Linux) or `$TRIVY_CACHE_DIR` between pipeline runs.
