---
name: testing
description: Guide for writing, reviewing, and running tests. Use it when the user asks to write tests, review coverage, design test cases, or define a testing strategy.
---

> **Testing exists to generate useful information for making decisions, not just to increase coverage.**

**Running tests:** always use the `pnpm` scripts defined in `package.json`. Do not use `nx`.

| Script | What it runs |
|---|---|
| `pnpm test` | All tests (jest --runInBand) |
| `pnpm test:unit` | Unit tests only (excludes integration and acceptance) |
| `pnpm test:integration` | Integration tests only |
| `pnpm test:acceptance` | Acceptance tests only |
| `pnpm test:bdd` | BDD tests in `test/BDD/` |
| `pnpm test:cov` | All tests with coverage |
| `pnpm test:watch` | Watch mode |
| `pnpm test:mutation` | Mutation testing with Stryker |

## General principles

1. **Clear purpose:** each test validates a single functional behavior of the domain, not an internal implementation.
2. **Minimum functional coverage:** prioritize main paths with representative inputs — one typical value, one boundary, one invalid. Maximum three distinct values per parameterization.
3. **No redundancy:** one test per behavior, not per data variation.
4. **Ignore what the framework guarantees:** do not test validations, serialization, or standard errors from Pydantic, Python, or Jest.
5. **AAA structure:** Arrange → Act → Assert.
6. **Simplicity first:** prefer a compact test over multiple fragmented ones. Do not use classes in tests.
7. **No trivial cases:** do not test obvious outputs (empty lists, empty dictionaries, Pydantic defaults) unless there is custom logic.
8. **Clarity over quantity:** tests should read like documentation of expected behavior.

## What to test

Prioritize:
- Business rules and critical happy paths.
- Edge cases and boundary values.
- Integration points between components.
- Historically fragile areas.

Avoid:
- Trivial getters/setters with no logic.
- Internal implementation details with no observable impact.

## TDD workflow

Use **red-green-refactor** when building new features or fixing regressions:
1. **Red** — write a failing test that describes the desired behavior.
2. **Green** — write the minimum code to make it pass.
3. **Refactor** — improve the implementation while keeping tests green.

Use TDD for: business rules, domain logic, bug fixes (write a failing reproduction first).  
Skip TDD for: exploratory spikes, quick prototypes, UI layout with no logic.

## Test design (before coding)

Before writing a test, define:
1. Test objective.
2. Test type (unit, integration, e2e, etc.).
3. Clear preconditions.
4. Representative data.
5. Explicit expected result.

## Test names

**TypeScript:** natural phrase in English
```
should <expected result> when <condition>
```

**Python:** snake_case
```
should_<expected_result>_when_<condition>
```

## Independence and isolation

- Tests must not depend on each other or assume execution order.
- Each test creates and cleans up its own state.
- Use mocks and stubs only when they add clarity; avoid over-mocking.
- **Tests always connect to the real database.** Do not mock the repository or DB connection.

## Determinism

An automated test must be **100% reproducible**. Avoid:
- Real time/date without control.
- `random` without seed.
- Real external dependencies in unit tests.

## Assertion quality

- **Be specific:** `expect(result.status).toBe('active')` beats `expect(result).toBeDefined()`.
- **One assertion per behavior**, not one assertion per test.
- **Include context:** when an assertion fails it should be obvious what was expected and why it matters.
- **Avoid snapshot tests** for business logic — they hide intent and break on irrelevant changes. Use them only for stable serialized outputs (e.g. CLI help text, generated SQL).
- **Property-based testing:** use when a rule must hold across many combinations of inputs (e.g. "total is always ≥ 0"). Use `fast-check` (TS) or `hypothesis` (Python).

## Async and E2E testing

- Always await async operations; never use arbitrary `setTimeout` as a wait strategy.
- For E2E / browser tests: prefer `data-testid` selectors over CSS classes or text. CSS and class names change; test IDs signal intent.
- Wait for meaningful state (`networkidle`, element visible, API response) — not arbitrary time.
- Clean up created test data after each test (teardown hooks, not manual cleanup inside the test body).

## Coverage targets (risk-based)

Coverage is a signal, not a goal. Apply thresholds by risk:

| Zone | Example | Statement | Branch |
|---|---|---|---|
| **Critical** | payment logic, auth, data migrations | ≥ 95% | ≥ 90% |
| **Core domain** | business rules, service layer | ≥ 80% | ≥ 75% |
| **Supporting** | utilities, formatters, adapters | ≥ 60% | ≥ 50% |
| **UI / presentation** | animations, layout helpers | best-effort | best-effort |

Track coverage trends over time (CI reports), not just snapshots.

## Mutation testing (Stryker)

Run `pnpm test:mutation` to measure assertion quality, not just execution coverage.

Interpret Stryker results:
- **≥ 90% mutation score** → strong test suite; assertions catch real bugs.
- **60–89%** → tests run but assertions are weak — tighten `expect` calls.
- **< 60%** → critical gap; many bugs would pass undetected.

Run mutation testing after reaching 80%+ statement coverage. Focus on files with the most business logic first, not 100% of the codebase.

## Test types and when to run them

| Type | Key question | When to run | Requirement | Typical tools |
|---|---|---|---|---|
| **Unit** | Does this unit work in isolation? | Every commit / early CI | Must pass 100% | Jest, pytest |
| **Integration** | Do these components work together? | CI post-unit, pre-merge | All green; failures analyzed | Jest + Supertest, pytest |
| **Functional / E2E** | Does the system fulfill user flows? | Before release / nightly | Not always 100%; impact evaluated | Playwright, Cypress |
| **Performance** | Does the system respond within limits? | Before major releases | Trends and SLAs analyzed | k6, Artillery |
| **Security** | Does the system resist malicious use? | Before production / audits | Not all failures block; must be documented | OWASP ZAP, Semgrep |
| **Mutation** | Do assertions catch real bugs? | After coverage reaches 80%+ | Score targets by risk zone | Stryker |

**Recommended execution order:** unit → integration → functional/E2E → non-functional → mutation.

## Gates vs sensors

- **Gates:** block progress (e.g. unit tests, critical mutation score).
- **Sensors:** inform and alert (e.g. performance baselines, secondary E2E, mutation score outside critical paths).

## Pre-submit checklist

Before finalizing a test, verify:

- [ ] The test fails when the behavior it covers is broken.
- [ ] The test passes for reasons related to the behavior, not side effects.
- [ ] The failure message explains what was expected and why it matters.
- [ ] The test does not replicate the implementation.
- [ ] The test is not fragile against irrelevant refactors (names, formatting, logs).
- [ ] The test would still make sense to someone reading it 6 months from now.

## Final decision rule

Before generating a test, ask:
1. What type of test is it?
2. What risk does it cover?
3. At what level does it provide the most value?
4. When should it be run?
5. Should it block or just inform?

If these questions cannot be answered, you probably **should not generate that test**.

> **Not all tests must always pass. All tests must provide information.**
