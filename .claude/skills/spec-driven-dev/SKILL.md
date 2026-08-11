---
name: spec-driven-dev
description: Use when the user wants to design a feature or application using spec-driven development. Guides the workflow from idea → specification → GitHub Issue → implementation plan → tasks. Creates minimal, agent-ready spec files that enable autonomous development.
---

Use this skill to transform ideas into structured, implementable specifications following the Spec-Driven Development (SDD) methodology. The goal is to create clear, parseable specs that both humans and AI agents can use to build software systematically.

## When to use this skill

- User has an idea for a new feature or application
- User wants to refine requirements before implementation
- User asks to "spec out" or "design" a feature
- User wants a structured approach to development
- User asks about spec-driven development or SDD workflow

## Fundamental principles

1. **Specs are source of truth** — code is regenerable, specs live longer
2. **Agent-ready from day one** — write specs that AI agents can implement from
3. **Gated workflow** — each phase requires human approval before advancing
4. **Minimal but complete** — just enough documentation, no more
5. **GitHub-integrated** — specs sync with issues for tracking

---

## The 4-Phase SDD Workflow

Each phase is a gate. Do not advance to the next phase without explicit user approval.

### Phase 1: SPECIFY

**Goal**: Transform a rough idea into a structured, complete specification.

**Input**: User's initial idea, feature request, or problem statement.

**Process**:

1. **Clarify the idea** through conversation:
   - Who is this for? (persona, role)
   - What problem does it solve? (pain point, need)
   - What does success look like? (measurable outcome)
   - What are the boundaries? (what's out of scope)

2. **Create spec file** using the standard template:
   - File location: `specs/{feature-name}.md`
   - Use kebab-case for filename
   - Follow the template structure (see Templates section)

3. **Write each section**:
   - **Objective**: 1-3 sentence summary of what and why
   - **Context**: Background, problem statement, user needs
   - **Requirements**: Functional and non-functional requirements
   - **Architecture**: High-level components, data model, dependencies
   - **User Stories**: Reference or embed stories (use `/user-stories` skill)
   - **Testing Strategy**: How we'll verify it works
   - **Boundaries**: What's explicitly out of scope
   - **Success Criteria**: Measurable outcomes that define "done"

4. **Validate spec quality**:
   - Is it clear enough for an agent to implement?
   - Are success criteria measurable?
   - Are boundaries explicit?
   - Are technical constraints documented?

5. **Show spec to user** for approval before advancing.

**Output**: `specs/{feature-name}.md` file with status: `draft`

**Gate**: User must approve spec before Phase 2.

---

### Phase 2: PLAN

**Goal**: Convert the approved specification into a concrete implementation plan.

**Input**: Approved spec from Phase 1.

**Process**:

1. **Analyze the spec** to identify:
   - Major components to build
   - Dependencies and ordering
   - Potential risks or unknowns
   - Verification checkpoints

2. **Create implementation plan**:
   - File location: `specs/{feature-name}-plan.md`
   - Break down into implementable chunks
   - Identify dependencies between chunks
   - Estimate complexity (XS/S/M/L/XL)
   - Call out risks or assumptions

3. **Plan structure**:
   - **Components**: What needs to be built
   - **Dependencies**: Build order and external deps
   - **Risks**: Technical unknowns, assumptions to validate
   - **Milestones**: Verification checkpoints
   - **Effort estimate**: Overall timeline

4. **Show plan to user** for approval before advancing.

**Output**: `specs/{feature-name}-plan.md` file

**Gate**: User must approve plan before Phase 3.

---

### Phase 3: TASKS

**Goal**: Break the implementation plan into discrete, independently implementable tasks.

**Input**: Approved plan from Phase 2.

**Process**:

1. **Convert plan chunks into tasks**:
   - Each task should be completable in isolation
   - Each task should have clear acceptance criteria
   - Each task should be testable independently

2. **Task format** (in plan file or separate task list):
   ```markdown
   - [ ] Task name
     - **Acceptance**: What defines done
     - **Files**: Expected files to create/modify
     - **Tests**: What tests to write
     - **Effort**: XS/S/M/L
   ```

3. **Order tasks** by dependencies:
   - Foundation first (data models, core logic)
   - Features second (business logic)
   - Integration third (API, UI)
   - Polish last (UX improvements, optimizations)

4. **Create GitHub Issues** (optional but recommended):
   - Use detected platform (GitHub/GitLab)
   - Create one issue for the overall feature (links to spec)
   - Optionally create sub-issues for major tasks
   - Use labels to track status

5. **Show task breakdown** to user for approval.

**Output**: Task list in plan file + optional GitHub Issues

**Gate**: User must approve tasks before Phase 4.

---

### Phase 4: IMPLEMENT

**Goal**: Execute tasks one-by-one, implementing the feature.

**Input**: Approved task list from Phase 3.

**Process**:

This phase is typically handed off to an implementation agent or executed by the user. The spec-driven-dev skill can:

1. **Guide implementation** task-by-task:
   - Read spec and plan for context
   - Implement one task at a time
   - Write tests first (TDD) using `/testing` skill
   - Verify against acceptance criteria
   - Update task status

2. **Verify against spec**:
   - Does implementation match requirements?
   - Are success criteria met?
   - Are all tests passing?

3. **Update status**:
   - Update spec frontmatter: `status: in-progress` → `status: completed`
   - Update GitHub Issue status
   - Link PR to spec file

**Output**: Working implementation, passing tests, closed GitHub Issue

---

## Spec File Template

All specs follow this structure for consistency and agent-readability:

```markdown
---
title: Feature Name
status: draft | approved | in-progress | completed
created: YYYY-MM-DD
updated: YYYY-MM-DD
issue: #123
---

# Feature Name

## Objective

[1-3 sentence summary: What we're building and why it matters]

## Context

[Background information, problem statement, user needs, business justification]

## Requirements

### Functional Requirements

- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

### Non-Functional Requirements

- [ ] Performance: [specific metric, e.g., "P95 response time < 200ms"]
- [ ] Security: [specific requirement, e.g., "All inputs sanitized against XSS"]
- [ ] Scalability: [specific requirement, e.g., "Handle 10k concurrent users"]
- [ ] Accessibility: [specific requirement, e.g., "WCAG 2.1 AA compliance"]

## Architecture

### Components

[High-level components and their responsibilities]

```
[Optional: diagram or component list]
```

### Data Model

[Key entities, relationships, schema]

### External Dependencies

- [Library/API 1]: [Purpose, version]
- [Library/API 2]: [Purpose, version]

## User Stories

[Link to user stories or embed them here. Use `/user-stories` skill to write detailed stories]

## Testing Strategy

### Unit Tests
[What units to test, coverage target]

### Integration Tests
[What integrations to test]

### E2E Tests
[What user flows to test]

### Performance Tests
[Load testing, benchmarking approach]

## Boundaries & Constraints

### In Scope
- [What we're building]

### Out of Scope
- [What we're explicitly NOT building]

### Technical Constraints
- [Language, framework, platform requirements]
- [Performance, security, compliance constraints]

## Success Criteria

- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

## Implementation Plan

[Link to {feature-name}-plan.md or embed plan here]
```

---

## Implementation Plan Template

```markdown
# Implementation Plan: [Feature Name]

**Spec**: [Link to spec file]  
**Created**: YYYY-MM-DD  
**Status**: draft | approved | in-progress | completed

## Components

### 1. [Component Name]
- **Purpose**: [What it does]
- **Files**: [Expected files]
- **Effort**: XS/S/M/L/XL

### 2. [Component Name]
- **Purpose**: [What it does]
- **Files**: [Expected files]
- **Effort**: XS/S/M/L/XL

## Dependencies

### Build Order
1. [Component A] (foundation)
2. [Component B] (depends on A)
3. [Component C] (depends on A, B)

### External Dependencies
- [Library/API]: [Why needed, when to integrate]

## Risks & Assumptions

### Risks
- **Risk 1**: [Description, mitigation]
- **Risk 2**: [Description, mitigation]

### Assumptions
- [Assumption 1 that needs validation]
- [Assumption 2 that needs validation]

## Milestones

- [ ] Milestone 1: [Verification checkpoint]
- [ ] Milestone 2: [Verification checkpoint]
- [ ] Milestone 3: [Verification checkpoint]

## Tasks

### Foundation (Build First)
- [ ] **Task 1**: [Description]
  - **Acceptance**: [What defines done]
  - **Files**: [Expected files]
  - **Tests**: [What to test]
  - **Effort**: XS/S/M/L

### Features (Build Second)
- [ ] **Task 2**: [Description]
  - **Acceptance**: [What defines done]
  - **Files**: [Expected files]
  - **Tests**: [What to test]
  - **Effort**: XS/S/M/L

### Integration (Build Third)
- [ ] **Task 3**: [Description]
  - **Acceptance**: [What defines done]
  - **Files**: [Expected files]
  - **Tests**: [What to test]
  - **Effort**: XS/S/M/L

## Effort Estimate

**Total Estimated Days**: [X-Y days]

| Phase | Effort |
|-------|--------|
| Foundation | [X days] |
| Features | [Y days] |
| Integration | [Z days] |
| Testing & Polish | [W days] |
```

---

## GitHub Issues Integration

### Platform Detection

Before creating issues, detect the platform and verify MCP server availability:

1. **Detect platform**: Run `git remote get-url origin` and parse:
   - `*github.com*` → GitHub
   - `*gitlab.com*` → GitLab

2. **Verify MCP server**: Use `ToolSearch` to check for MCP tools:
   - GitHub: search `+github issue`
   - GitLab: search `+gitlab issue`

3. **If MCP not available**: Search for setup instructions and show user how to configure it. Do not continue until MCP is configured.

### Issue Creation

When creating a GitHub Issue from a spec:

**Title**: Feature name (concise, ~80 chars max)

**Body**:
```markdown
## Specification

See full spec: `specs/{feature-name}.md`

## Objective

[Copy from spec]

## Success Criteria

[Copy from spec]

## Implementation Plan

See: `specs/{feature-name}-plan.md`

## Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

[Or link to task breakdown]

---

📋 Spec-Driven Development workflow  
Created with /spec-driven-dev skill
```

**Labels**: Infer from spec content:
- Type: `feature`, `enhancement`, `bug`, `chore`
- Area: Based on affected components
- Status: `spec-approved`, `in-development`, etc.

### Linking

After issue creation:

1. **Update spec frontmatter** with issue number:
   ```yaml
   issue: #123
   ```

2. **Link in plan file** to issue

3. **When creating PR**: Reference issue and spec in PR description

---

## Workflow Examples

### Example 1: Simple Feature

**User**: "I want to add dark mode to my app"

**Specify Phase**:
1. Clarify: What triggers dark mode? System preference or manual toggle? What components need theming?
2. Create `specs/dark-mode.md` with:
   - Objective: Add dark mode support with automatic detection and manual override
   - Requirements: System preference detection, manual toggle, all components themed
   - Success criteria: No visual glitches, preference persists, smooth transitions

**Plan Phase**:
1. Create `specs/dark-mode-plan.md`:
   - Components: Theme provider, CSS variables, toggle component
   - Build order: CSS variables → theme context → toggle → apply to components
   - Risks: Third-party components may not support theming

**Tasks Phase**:
1. Break into tasks:
   - Define CSS variables for light/dark themes
   - Create theme context and provider
   - Build toggle component
   - Apply theme to existing components
   - Add system preference detection
   - Persist user preference

**Implement Phase**:
Execute tasks, write tests, verify against success criteria.

---

### Example 2: Complex Application

**User**: "I want to build a task management app with collaboration features"

**Specify Phase**:
1. Clarify through conversation:
   - Who: Team leads and team members
   - What: Create/assign tasks, track progress, comment/collaborate
   - Why: Current tools too complex or expensive
   - Boundaries: No time tracking, no gantt charts, no budget features

2. Create `specs/task-management-app.md`:
   - Break into major areas: Auth, Tasks, Comments, Notifications
   - Reference multiple user stories (use `/user-stories` skill)
   - Architecture: React frontend, Node backend, PostgreSQL
   - Success criteria: 10 users can collaborate on 100 tasks smoothly

**Plan Phase**:
1. Create `specs/task-management-app-plan.md`:
   - Split into milestones:
     - Milestone 1: Auth + basic task CRUD
     - Milestone 2: Assignment + status tracking
     - Milestone 3: Comments + real-time updates
     - Milestone 4: Notifications
   - Identify each milestone as separate specs if too large

**Tasks Phase**:
1. For Milestone 1, create tasks:
   - Set up project structure
   - Implement auth (register/login)
   - Create task model and API
   - Build task list UI
   - Write tests

**Implement Phase**:
Execute milestone 1, then return to planning for milestone 2.

---

## Quality Checklist

Before advancing from **Specify** phase, verify:

- [ ] Objective is clear in 1-3 sentences
- [ ] Success criteria are measurable
- [ ] Boundaries are explicit (in scope, out of scope)
- [ ] Technical constraints are documented
- [ ] Non-functional requirements have metrics
- [ ] An agent could implement from this spec alone

Before advancing from **Plan** phase, verify:

- [ ] Components are identified and ordered
- [ ] Dependencies are explicit
- [ ] Risks are called out with mitigations
- [ ] Effort estimate is realistic
- [ ] Milestones provide verification checkpoints

Before advancing from **Tasks** phase, verify:

- [ ] Each task is independently implementable
- [ ] Each task has clear acceptance criteria
- [ ] Tasks are ordered by dependencies
- [ ] Each task is sized appropriately (prefer smaller)

---

## Integration with Other Skills

### `/user-stories`
Use when spec needs detailed user stories with acceptance criteria in Gherkin format. Reference user stories in spec's "User Stories" section.

### `/testing`
Use during implementation to write tests following TDD. Reference in spec's "Testing Strategy" section.

### `/commit-writer`
Use when committing implementation work to follow commit conventions.

### `/trivy-scan`
Use for security scanning if spec has security requirements.

### `/sonar-check`
Use for code quality validation if spec has quality metrics.

---

## Directory Structure

Recommended project structure:

```
project-root/
├── specs/
│   ├── feature-1.md
│   ├── feature-1-plan.md
│   ├── feature-2.md
│   ├── feature-2-plan.md
│   └── README.md (index of all specs)
├── src/
├── tests/
└── README.md
```

The `specs/` directory is the single source of truth for all features. Keep it in version control alongside code.

---

## Anti-Patterns

| Bad | Good |
|-----|------|
| Skipping phases or gates | Complete each phase, get approval before advancing |
| Vague success criteria ("should be fast") | Measurable criteria ("P95 < 200ms") |
| No boundaries documented | Explicit in-scope and out-of-scope |
| Implementation details in spec | High-level components, not specific code |
| No plan, jump to coding | Spec → Plan → Tasks → Implement |
| Spec and code out of sync | Update spec when requirements change |
| Creating issues without MCP | Verify MCP first, guide user to set up if missing |

---

## Tips for Agent-Ready Specs

1. **Be explicit**: Don't assume shared context. An agent reading this spec for the first time should understand completely.

2. **Use structured formats**: Checklists, tables, code blocks make specs parseable.

3. **Separate concerns**: Functional requirements separate from non-functional, architecture separate from implementation.

4. **Measurable outcomes**: Every success criterion should be verifiable (test, metric, demo).

5. **Link liberally**: Reference related specs, user stories, documentation. Context helps agents make better decisions.

6. **Update status**: Keep frontmatter current so agents know what's safe to implement vs. what's still draft.

---

## Maintenance

### When to Update Specs

Update specs when:
- Requirements change during development
- New constraints are discovered
- Architecture decisions change
- Success criteria need adjustment

### How to Update

1. Edit the spec file directly
2. Update `updated` date in frontmatter
3. Document changes in a "Changelog" section if major
4. Update related GitHub Issue with changes
5. Get approval for significant changes

### Archiving Completed Specs

When a feature is complete:
1. Update status to `completed`
2. Link to merged PR(s)
3. Keep spec in `specs/` directory (don't delete)
4. Specs serve as historical documentation
