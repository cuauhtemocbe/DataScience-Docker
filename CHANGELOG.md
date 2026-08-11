# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-08-10

### Added

- Reproducible Docker dev environment with Python 3.13 and Poetry
- JupyterLab integration via `make notebook`
- Pre-commit hooks for lint and format checks
- CI workflow with test, lint, format-check, typecheck, lock-check, and Trivy scan jobs
- Dependabot configuration for weekly pip and GitHub Actions updates
- Supply-chain hardening: pinned actions to commit SHAs, least-privilege permissions

[0.1.0]: https://github.com/cuauhtemocbe/DataScience-Docker/releases/tag/v0.1.0
