---
name: commit-writer
description: Generates commit messages. Use it when the user asks to make a commit, summarize git changes, or needs a message for git commit.
---

## Step 1: Read the diff

Run `git diff --staged`. If nothing is staged, run `git diff`. If both are empty, tell the user there is nothing to commit.

## Step 2: Atomic commit check

Before generating the message, check whether the staged changes represent a **single logical change**. If they clearly span more than one type (e.g. a new feature plus a bug fix in unrelated areas), generate one commit per type and say so. If everything is the same type, generate a single commit.

## Step 3: Generate the message

### Format

```
<type>(<optional scope>): <subject>

[optional body]

[optional footer]
```

### Subject line rules

- **Imperative mood** — write as a command: `add`, `fix`, `remove`, not `added`, `fixed`, `removed`
- **50 characters recommended, 72 absolute maximum** — GitHub truncates beyond 72
- **Capitalize** the first word of the subject
- **No period** at the end
- Do not invent context that is not in the diff

### Body (include when the why is not obvious)

- Separate from subject with a blank line
- Wrap at 72 characters per line
- Explain **why** the change was made, not what — the diff already shows what
- Include relevant context: constraints, trade-offs, prior behavior

### Footer

- Issue/ticket references: `Closes #42`, `Refs: PROJ-123`
- If the branch name contains a ticket ID (e.g. `feat/PROJ-123-login`), extract it and add `Refs: PROJ-123` automatically
- Breaking changes: `BREAKING CHANGE: <description>`

## Allowed types

- `feat`     → new feature
- `fix`      → bug fix
- `docs`     → documentation only
- `style`    → formatting, no logic change
- `refactor` → refactoring without feat or fix
- `perf`     → performance improvement
- `test`     → adding or fixing tests
- `build`    → build system or external dependencies
- `ci`       → CI/CD configuration changes
- `chore`    → maintenance tasks, deps, config

## Breaking changes

Use `!` after the type/scope for breaking changes, and add a `BREAKING CHANGE:` footer:

```
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: /api/v1/* routes have been removed. Migrate to /api/v2/*.
```

## Rules

- Do not add `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- Do not stage or commit files that look like secrets (`.env`, credentials, tokens)
- If changes cover more than one type, generate one commit per type — never mix types
- Never fabricate context not present in the diff

## Examples

Simple (subject only):
```
feat(auth): add JWT refresh token support
```

With body:
```
fix(payments): prevent double charge on network timeout

The payment service was retrying requests without idempotency keys,
causing duplicate charges when the network dropped mid-request.
Added idempotency key derived from order ID + timestamp.
```

With breaking change:
```
feat(api)!: replace session tokens with JWTs

BREAKING CHANGE: The Authorization header now expects a Bearer JWT.
Existing session tokens are no longer valid.
```

With issue reference:
```
fix(reports): correct timezone offset in date range filter

Closes #187
```
