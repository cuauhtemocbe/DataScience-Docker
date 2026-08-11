---
name: user-stories
description: Use when the user asks to write, refine, or review User Stories, acceptance criteria, Definition of Done, or build an agile backlog. Also use when the user asks to create issues from user stories, publish stories to GitHub Issues or GitLab Issues, or manage the backlog in any issue tracker.
---

Use this skill to write or review User Stories that are clear, actionable, and meet the method's attributes. The goal is not to fill a template — it is to spark the right conversation between product and development.

It also allows publishing the stories as issues in the project tracker (GitHub or GitLab, auto-detected).

## Fundamental rule

**A story CANNOT be accepted if its acceptance criteria are not validated by automated tests.**

It does not matter if they are unit, integration, E2E, or BDD tests — what matters is that each criterion has at least one test that demonstrates it. Without a test, there is no evidence. Without evidence, there is no acceptance.

This is non-negotiable. "I tested it manually", "it looks good in the browser", and "I trust it works" are not accepted. If the criterion does not have a test that fails when it breaks, the criterion is not covered.

---

## Pre-check

Before writing, understand:

- **Who is the real user?** Not the dev, not the system — the person executing the action. If the story spans multiple roles, split it.
- **What visible value does it generate?** If there is nothing observable for the Product Owner, it is not a complete US.
- **Is it manageable?** A well-written US is completed in 2 to 5 days. If it is larger, split it.
- **Is it in domain language?** No technical implementation terms. The _what_, never the _how_.

### Persona depth

"User" is not a persona. Before writing the story, define:

| Attribute | Example |
| --------- | ------- |
| Role      | "cashier at a retail store" |
| Context   | "handles 50+ transactions per shift" |
| Goal      | "minimize keystrokes per operation" |
| Pain      | "currently re-enters the same discount code each transaction" |

The more specific the persona, the tighter the story and the more useful the acceptance criteria. If you cannot name the persona's pain, you do not understand the story well enough to write it.

---

## User Story format

```
As <role>
I want <action>
In order to <value obtained>  <- optional for small features
```

**The "in order to" is mandatory only when the value is not obvious.** In small or technical features, forcing it produces empty text.

### Technical context (optional)

For technical backlogs (migrations, refactors, infrastructure), add a **Technical Context** section that justifies the story from the system perspective, not the business. Example: number of duplications, technical debt, dependencies.

---

## INVEST validation

After drafting a story, run it through the INVEST checklist before writing acceptance criteria. A story that fails INVEST is not ready to estimate.

| Letter | Criterion    | Check                                                                  | If it fails         |
| ------ | ------------ | ---------------------------------------------------------------------- | ------------------- |
| **I**  | Independent  | Can it be delivered without another story being done first?            | Reorder or split    |
| **N**  | Negotiable   | Is it a conversation starter, not a fixed contract?                    | Remove over-detail  |
| **V**  | Valuable     | Does it deliver value to the user or business directly?                | Rephrase or discard |
| **E**  | Estimable    | Can the team size it? Is there enough clarity to give an effort?       | Add context or spike |
| **S**  | Small        | Completable in one sprint (2–5 days)?                                  | Split with SPIDR    |
| **T**  | Testable     | Can you write a failing test before implementation?                    | Rewrite or discard  |

A story that fails **V** is waste. A story that fails **T** is guesswork. These two are the most critical.

---

## Prior analysis — before writing criteria

Before drafting Gherkin scenarios, analyze the problem in depth. Do not jump straight to criteria.

### Step 1: Understand the domain

- What entities are involved? What is their current state?
- What business rules apply? Are there invariants that cannot be violated?
- What already exists in the system? Read the relevant code before assuming.

### Step 2: Identify edge cases with ZOMBIES

Systematically go through each category:

| Letter | Category        | Key questions                                              |
| ------ | --------------- | ---------------------------------------------------------- |
| **Z**  | Zero            | What happens with 0? With empty lists? With empty strings? |
| **O**  | One             | What happens with a single element? With the first use?    |
| **M**  | Many            | What happens with many? Are there limits? Pagination?      |
| **B**  | Boundaries      | Values at the boundary (min, max, exactly the limit)?      |
| **I**  | Interfaces      | What happens between components? Permissions? Different roles? |
| **E**  | Exceptions      | Network errors? Corrupt data? Concurrency? Timeout?        |
| **S**  | Simple/Security | Simplest possible case? Are there security risks?          |

### Step 3: Map paths

List explicitly before writing Gherkin:

1. **Happy path** — the main flow the user expects
2. **Alternative paths** — valid variations (different role, different configuration)
3. **Error paths** — invalid inputs, inconsistent states, insufficient permissions
4. **Edge cases** — those discovered with ZOMBIES that are relevant

Discard those that do not provide real value. Not all edge cases deserve a scenario — only those that represent a concrete risk or behavior the user needs to trust works.

### Include in the issue

Document the analysis in the **Technical Context** section of the issue:

- Affected files with relative paths
- Current state vs. desired state
- Edge cases identified and decision to cover or discard
- Dependencies with other components or stories

---

## Acceptance Criteria — Gherkin required

All acceptance criteria are written in valid **Gherkin format**, ready to copy and paste into a `.feature` file. No exceptions.

### Format

Gherkin keywords in English, descriptions in English.

```gherkin
Feature: <story name>

  Scenario: <criterion description>
    Given <precondition>
    When <action>
    Then <observable result>

  Scenario: <another criterion>
    Given <precondition>
    And <another precondition>
    When <action>
    Then <observable result>
    And <another result>

  Scenario Outline: <criterion with multiple examples>
    Given <precondition with <variable>>
    When <action>
    Then <result>

    Examples:
      | variable | expected_result |
      | value1   | result1         |
      | value2   | result2         |
```

Step content should be natural English: `When the user enters a negative amount` or `Then they see an error message`. What matters is that it is valid Gherkin that a parser can read.

### Rules for criteria

- **Observable behavior, not implementation.** "Then the user sees a confirmation message" — not "Then `save()` returns `true`".
- **Happy path first, then edge cases.** Order the scenarios: happy path → alternatives → errors → boundaries.
- **3 to 7 scenarios** per well-split story. If you have 10+, the story is too large — split it.
- **Each scenario = one path.** Do not mix happy path with errors in the same scenario.
- **Concrete edge cases, not generic ones.** "When the amount is 0" is concrete. "When there is an error" is generic — specify _which_ error.
- **Use `Scenario Outline` + `Examples`** when the same flow repeats with different data. Ideal for boundaries and input variations.
- **`Background`** for preconditions shared among all scenarios.

### Each criterion MUST have a test to back it

```
Acceptance criterion  <->  Automated test
        1            :      1 (minimum)
```

If you write a Gherkin scenario, there must be a step definition that executes it, or a unit/integration test that covers that same behavior. **The story is not closed until every scenario has its passing test.**

### Anti-patterns

| Bad                                    | Good                                                    |
| -------------------------------------- | ------------------------------------------------------- |
| "The `save()` function returns `true`" | "Then the user can save without seeing an error"        |
| "Must be fast"                         | "Then the response arrives in less than 500ms"          |
| ACs in free prose                      | Valid Gherkin with `Given/When/Then`                    |
| Criterion without test                 | Criterion with automated test that demonstrates it      |
| "I tested it manually and it works"    | Automated test that fails if the criterion breaks       |

---

## Definition of Done

The DoD is a **team quality checklist**, not story criteria. It is defined once for the entire project.

Typical components:

- **All Gherkin scenarios have passing tests** (this is non-negotiable)
- Lint / build green
- Code review approved
- Minimal documentation if applicable
- Deployed to staging if appropriate

**Do not mix DoD with ACs.** If something belongs to the global DoD, do not copy it into each story.

---

## Non-Functional Requirements (NFRs)

NFRs describe _how_ the system behaves, not _what_ it does. They are often deferred and discovered in production — that is a preventable failure.

### Where each NFR lives

| Scope | Where to put it | Example |
| ----- | --------------- | ------- |
| Applies to **one story** | Acceptance criterion in that story | "Then the search result appears in under 300ms" |
| Applies to **all stories** | Definition of Done | "All endpoints respond in under 500ms" |
| Large enough to be standalone | Its own technical story | "As an ops engineer, I want response time alerts configured so that SLA breaches page on-call" |

### Writing testable NFR criteria

Never write a vague NFR. Always attach a measurable threshold and a tool:

| Category       | Vague (bad)           | Testable (good)                                              | Verification tool          |
| -------------- | --------------------- | ------------------------------------------------------------ | -------------------------- |
| Performance    | "must be fast"        | "Then P95 response time is under 500ms under 100 concurrent users" | k6, JMeter, Lighthouse     |
| Accessibility  | "must be accessible"  | "Then the page scores 100 on Lighthouse accessibility audit" | Lighthouse, axe-core        |
| Security       | "must be secure"      | "Then OWASP ZAP active scan reports 0 high/critical findings" | OWASP ZAP, Snyk            |
| Reliability    | "must not crash"      | "Then the service recovers within 30s after a pod restart"   | Health check + integration |

If you cannot attach a threshold and a verification tool, the NFR is not ready to be written as a criterion — clarify it first.

---

## How to split a large User Story — SPIDR

If a US fails the **S** (Small) check in INVEST, apply SPIDR to find the split. These five patterns cover almost every case.

| Letter | Pattern        | Split by                                                        | Example |
| ------ | -------------- | --------------------------------------------------------------- | ------- |
| **S**  | Spike          | Unknown — run a time-boxed investigation first, then implement  | "Research OAuth2 providers" → spike, then implementation story |
| **P**  | Paths          | User workflows — base flow first, then variations and errors    | "Pay with card" → happy path / declined card / expired card |
| **I**  | Interfaces     | Delivery channel or UI variant — one per story                  | "Upload file" → web UI / mobile / API |
| **D**  | Data           | Data type, format, or volume — one per meaningful variant       | "Import contacts" → CSV / vCard / manual entry |
| **R**  | Rules          | Business rule — one rule or rule group per story                | "Apply discount" → employee discount / promo code / bulk discount |

**Pick the letter that produces the smallest independently deployable slice.** Always prefer a vertical slice (end-to-end, even if limited) over a horizontal slice (layer-by-layer). A vertical slice delivers value on its own; a horizontal slice delivers nothing until all layers are merged.

Additional splitting patterns when SPIDR is insufficient:

- **CRUD operations**: create / read / update / delete as distinct stories
- **Without design vs. with design**: functionality first, detailed UI later

---

## Effort sizing

Use T-shirt sizes in the issue. Match to working days (not story points — days are concrete).

| Size | Days     | Signal |
| ---- | -------- | ------ |
| XS   | < 0.5    | Single change, one file, obvious path |
| S    | 0.5–1    | Small feature, 1–3 files, clear path |
| M    | 2–3      | Multiple files or components, some uncertainty |
| L    | 4–5      | Spans systems or requires coordination |
| XL   | > 5      | Should be split — do not accept XL into a sprint as-is |

An XL story is a signal to apply SPIDR before putting it on the board.

---

## Complete example

```gherkin
# As a developer of bots that handle location
# I want to validate geographic coordinates from build-core
# In order to eliminate the 71 local copies of validateCoordinates
#
# Technical Context:
# - 71 bots have validateCoordinates duplicated in generalFunctions.js
# - Pure function with no dependencies, ideal for direct migration
# - Input arrives as text from WhatsApp

Feature: Geographic coordinate validation

  Scenario: The function is available as a public export
    Given I have build-core installed
    When I import isValidCoordinates from build-core
    Then it compiles and runs without errors

  Scenario Outline: Accepts valid geographic coordinates
    Given a string "<coordinates>" with lat in [-90,90] and lon in [-180,180]
    When I call isValidCoordinates with "<coordinates>"
    Then it returns true

    Examples:
      | coordinates    |
      | 0,0            |
      | -33.45,-70.66  |
      | 90,180         |
      | -90,-180       |

  Scenario Outline: Rejects invalid input or out-of-range values
    Given an input "<input>" with incorrect format or out-of-range values
    When I call isValidCoordinates with "<input>"
    Then it returns false

    Examples:
      | input     |
      | 91,0      |
      | abc,def   |
      | 33,44,55  |
      | 33        |

  Scenario Outline: Never throws an exception on unexpected input
    Given an unexpected input "<input>"
    When I call isValidCoordinates with "<input>"
    Then it returns false without throwing an exception

    Examples:
      | input     |
      | null      |
      | undefined |
      |           |

# Definition of Done:
# - Implementation in src/Address.ts with JSDoc
# - Tests for ALL scenarios above (ZOMBIES)
# - Module coverage >= 90%
# - Lint and tests green
# - Exported from the package's public index
#
# Effort: S (1-2 hours)
```

---

## Platform and repository detection

Before creating or managing issues, automatically detect the platform, the repository, and verify that the platform CLI is available and authenticated. Run once per session and cache the values.

### Step 1: Detect platform and repository

Run `git remote get-url origin` and parse:

| Remote pattern                              | Platform |
| ------------------------------------------- | -------- |
| `*github.com*`                              | GitHub   |
| `*gitlab.com*` or domain with `gitlab`      | GitLab   |

Extract `owner` and `repo` from the path (SSH `:<owner>/<repo>.git` or HTTPS `/<owner>/<repo>.git`). Remove `.git` if present. If the platform cannot be determined, ask the user.

### Step 2: Use the platform CLI (preferred)

Prefer the platform's official CLI over an MCP server:

| Platform | CLI    | Auth check          |
| -------- | ------ | ------------------- |
| GitHub   | `gh`   | `gh auth status`    |
| GitLab   | `glab` | `glab auth status`  |

If the CLI is installed and authenticated → use it. It needs no per-session
configuration, works identically across every repo, and its failures are legible
(a non-zero exit and a real error message) rather than a silent tool absence.

**Always pass issue bodies with `--body-file`, never `--body`.** Story bodies contain
fenced Gherkin blocks, pipe tables, backticks and non-ASCII text; inlining them into a
shell argument invites quoting and escaping corruption. Write the body to a scratchpad
file first, then:

```bash
gh issue create \
  --title "<title>" \
  --body-file /path/to/body.md \
  --milestone "<milestone title>" \
  --label <label> --label <label>
```

Verify after creating, do not assume — list the issues back and confirm the titles,
labels and milestone landed as intended:

```bash
gh issue list --milestone "<milestone title>" \
  --json number,title,labels \
  --jq '.[] | "#\(.number)  \(.title)  [\(.labels|map(.name)|join(", "))]"'
```

Cross-references between stories can only be written once the issue numbers exist.
Create the issues first, then `gh issue edit <n> --body-file <updated>` to fill in
`**Depends on:** #N` / `**Blocks:** #N` lines. Do not leave placeholder text in a
published body.

### Step 3: If the CLI is unavailable

Fall back in this order:

1. **MCP server** — use `ToolSearch` to look for tools for the detected platform
   (`+github issue` / `+gitlab issue`). If found, use them and cache the tool names.
2. **Ask the user to install the CLI.** Show the command and stop; do not continue with
   issue creation.

```
I could not find the <gh|glab> CLI installed or authenticated, and no
<GitHub|GitLab> MCP server is configured.

To enable the CLI:
  <install command for the platform>
  <gh|glab> auth login

Since `gh auth login` is interactive, run it yourself — type `! gh auth login`
in the prompt so its output lands in this session.

Once authenticated, ask me to create the issues again.
```

**If the user explicitly asks for one mechanism over the other, honor that** — an
explicit instruction outranks this default.

---

## Dry-Run Review Gate

Runs automatically after a story's Gherkin criteria are drafted and before it is shown to the user for final validation (step 2 of the Publish workflow below). This gate exists to catch design problems before code is written, not after — it applies to every story regardless of size.

**Do not touch code in this gate.** Read only — the goal is to simulate implementation, not perform it.

### Step 1: Read the real code

Before judging anything, read the files the story would actually touch (from Technical Context, or search the codebase for the affected area/module). Evaluate the story against what is actually there, not an imagined architecture.

### Step 2: Dry-run the implementation

Narrate, scenario by scenario, how each Gherkin scenario would be implemented against the current code — without writing it. For each scenario, walk the path: which function/component receives the input, where the new logic would live, what it would return, what existing pattern it should follow.

If a scenario's "When/Then" doesn't map cleanly onto anything in the real code path, that is a finding — the scenario is underspecified or technically wrong, not just "needs more code."

### Step 3: Feasibility verdict per scenario

Classify every scenario as one of:

| Verdict | Meaning |
| ------- | ------- |
| **Feasible** | Maps directly onto existing code/patterns |
| **Feasible with caveat** | Works, but requires a decision the story doesn't make explicit (name it) |
| **Not feasible as written** | Contradicts how the system actually works — rewrite before publishing |

### Step 4: Gap re-check

The dry-run surfaces things the original ZOMBIES pass couldn't see, because it didn't yet have the real code in view. Ask again: did tracing the actual implementation reveal an edge case, a dependency, or a piece of shared state that the story doesn't account for?

### Step 5: Simplicity vs. robustness

Identify two solutions:

- **Simplest path**: the smallest change that satisfies the acceptance criteria exactly as written today.
- **More robust path** (if one exists): a solution that also handles adjacent cases, scales better, or removes duplication — but costs meaningfully more effort than the story's current size.

Default to recommending the simplest path for *this* story. Never silently upgrade scope mid-story.

### Step 6: Fork a follow-up story if warranted

If the robust path is real and worth doing, draft it as a **separate** story for the next iteration, using this skill's normal US format (persona, Gherkin, DoD, effort). Note in its Technical Context that it follows the original story and why the simpler version ships first. Do not create it as an issue yet — show it alongside the dry-run summary, and offer to publish it only after the user confirms the current story.

### Output

Show the user, before asking "should I create it as an issue?":

1. Per-scenario feasibility verdicts (flag anything not **Feasible**)
2. Any new gaps found, and whether they changed the story's scope/ACs
3. The simplest-path recommendation
4. The follow-up story draft, if one was warranted

If any scenario is **Not feasible as written**, rewrite it before moving on — do not publish a story with a scenario the codebase can't actually support.

---

## Publish as issue

After writing or reviewing a user story, offer to create it as an issue. Always ask for confirmation before creating.

### Issue format

```markdown
## User Story

\`\`\`
As <role>
I want <action>
In order to <value obtained>
\`\`\`

## Technical Context

<only if applicable — technical justification, affected files, debt, dependencies>

## Acceptance Criteria

\`\`\`gherkin
Feature: <name>

Scenario: ...
Given ...
When ...
Then ...
\`\`\`

## Definition of Done

- All Gherkin scenarios have passing automated tests
- Lint and type-check green
- Code review approved
  <add story-specific items if applicable>

## Effort: <XS | S | M | L | XL>
```

### Issue title

- Concise and descriptive, no prefixes like "US:" or "Story:"
- Written in English
- Maximum ~80 characters

### Labels

Automatically assign labels based on the story context. Do not ask the user — infer from the content.

1. **Get existing labels** from the repository (once per session) — `gh label list` /
   `glab label list`.
2. **Infer type** (mutually exclusive):

| Signal in the story                                                      | Common labels            |
| ------------------------------------------------------------------------ | ------------------------ |
| Fixes incorrect behavior, regression, something that "does not work"     | `bug`                    |
| Adds new functionality, new flow, new screen                             | `enhancement`, `feature` |
| Refactor, migration, technical debt, performance, no user-facing change  | `chore`, `maintenance`   |

3. **Infer area** — map affected files/modules to area labels that exist in the repo.
4. **Only assign labels that exist** in the repository. Do not invent. If the type is not clear, default to `enhancement`.

### Workflow

1. Write/review the complete user story
2. Run the Dry-Run Review Gate — rewrite any scenario marked "Not feasible as written", fold in any newly found gaps, draft a follow-up story if warranted
3. Show the story (plus dry-run findings and any follow-up draft) to the user for validation
4. Ask: "Should I create it as an issue?" (and, separately, whether to publish the follow-up story too)
5. Detect platform and verify the CLI is authenticated (if not done before)
6. Create the milestone first if the stories belong to one, so issues can be filed
   straight into it
7. Write each body to a scratchpad file, then create the issue(s) with
   `--body-file` (use detected `owner` and `repo` if the CLI is not already
   scoped to the right repo)
8. Fill in cross-references (`Depends on` / `Blocks`) with `gh issue edit` now that
   the numbers exist
9. List the issues back to verify title, labels and milestone, then return the issue
   number(s) and URL(s)

### Create multiple issues (backlog)

1. Write all stories first
2. Show the summary (title + effort for each)
3. Ask for confirmation to create all
4. Create issues sequentially
5. At the end, list all created issues with their numbers and URLs

---

## Close a resolved issue

When the user asks to close an issue that has already been resolved, **do not close it directly**. First leave a closing comment with evidence, then close.

### Closing comment

```markdown
## Resolution

<brief summary of what was done — concrete changes, not generic>

### Main changes

- <change 1 with file or affected area>
- <change 2>
- ...

### Evidence

- <link to PR, commit, or concrete reference>
- <test results: which suite passed, coverage if applicable>
- <relevant screenshot or log if applicable>
```

### Rules

- **Summarize what was done, not repeat the story.** "How it was resolved", not "what needed to be done".
- **Be specific.** "Added validation in `expenses.service.ts`" — not "The fix was done".
- **At least one form of evidence:** merged PR, commits, passing tests, screenshot, or log.
- **If there are new tests, mention them.** What scenarios they cover and if they pass.

### Workflow

1. Draft the closing comment with the summary and evidence
2. Show it to the user for validation
3. If accepted, add the comment — `gh issue comment <n> --body-file <file>` /
   `glab issue note <n>`
4. Close the issue — `gh issue close <n>` / `glab issue close <n>`

---

## Signs a US is poorly written

- ACs are not valid Gherkin → rewrite them
- There are no tests for the criteria → the story is NOT done
- Uses words like "function", "method", "returns" in scenarios → it is technical, not domain-level
- Has more than 7 scenarios → probably 2 stories
- The "as" is "the system" → check who the real user is
- Something subjective without a metric ("must look good") → make it concrete or remove it
- Someone says "I tested it manually" → does not count, needs an automated test
- NFR has no threshold or verification tool → clarify before writing it
- Story is XL → apply SPIDR before estimating
