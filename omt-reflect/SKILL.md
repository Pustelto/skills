---
name: omt-reflect
description: Migrate .memo/_scratch.md to organized notes at session end. Agent auto-decides placement (category + level) with reasoning. Updates INDEX.md. Clears scratch. Run after tasks done or session ending.
---

# Reflect & Organize Knowledge

## Overview

Read `.memo/_scratch.md`, organize entries into proper notes (standards, runbooks, architecture, refactoring), update INDEX.md, and clear scratch. This is the "Codify" step of compound engineering.

**Agent auto-decides** where each note belongs and provides reasoning. Human reviews in PR.

## When to Use

- **Full reflection:** All tasks in `tasks.md` done — feature complete
- **Partial reflection:** Session ending mid-feature
- **Anytime:** When scratch is getting long (20+ entries)

## Process

### 1. Read Scratch File

Read `.memo/_scratch.md` — extract all timestamped entries.

### 2. Read Existing Knowledge

Read `.memo/INDEX.md` at all relevant levels (global + submodules if applicable).

This helps agent determine:
- If similar note already exists (update vs create)
- Current knowledge gaps
- Naming patterns to follow

### 3. For Each Entry, Auto-Decide

Agent decides for each scratch entry:

**Category:**
- **standard** — convention, pattern, rule to follow
- **runbook** — step-by-step procedure
- **architecture** — system design, flow, diagram
- **refactoring** — friction point, improvement idea

**Level (scope):**
- **global** — `.memo/` (used across entire codebase)
- **submodule** — `packages/{name}/.memo/` (specific to one package)

**Action:**
- **create** — new note doesn't exist
- **update** — related note exists, add to it
- **skip** — already documented or too minor

**Reasoning:**
Agent MUST provide reasoning for each decision:

```
Entry: "Error handling pattern — discriminated unions"
Decision: CREATE .memo/standards/error-handling-api-responses.md
Reasoning: Error handling is global concern (used in all API handlers),
fits standards category (convention we follow), no existing note found.
```

```
Entry: "CSV import boilerplate — too repetitive"
Decision: CREATE .memo/refactoring/csv-import-excessive-boilerplate.md
Reasoning: Friction point hit 3 times, medium severity, specific suggestion
included. Refactoring category (improvement idea, not current standard).
```

```
Entry: "Auth flow needs diagram"
Decision: UPDATE .memo/architecture/auth-flow.md (add Mermaid diagram)
Reasoning: Architecture note already exists, entry is enhancement not new topic.
```

### 4. Create or Update Notes

For each decision:

**If CREATE:**
- Generate SEO-optimized filename (e.g., `error-handling-api-responses.md`)
- Use appropriate YAML frontmatter (generic vs refactoring)
- Structure body: Problem/Context → Solution/Approach → Code References
- Include diagrams (Mermaid, ASCII) if entry mentions flows
- Generalize examples (avoid overly specific code)
- Add file:line references from scratch entry

**If UPDATE:**
- Read existing note
- Add new example/section
- Bump `updated` date
- Increment `occurrences` if refactoring note
- Maintain existing structure

**If SKIP:**
- Note in summary why skipped

### 5. Staleness Check

For notes touched by this feature:
- Check if affected_files have changed significantly
- Verify examples still exist at referenced file:line
- Flag for review if stale (add to summary)

### 6. Update INDEX.md

For each created/updated note:
- Add or update row in appropriate category section
- Include detailed summary (more than just filename)
- Update Change Log section with today's date

Example INDEX.md update:

```markdown
## Standards

| Note | Summary |
|------|---------|
| [error-handling-api-responses](./standards/error-handling-api-responses.md) | Three patterns we use for API errors: discriminated unions (type-safe), Result type (explicit), and error boundaries (React). Includes Zod integration and examples from user/product handlers. |
```

### 7. Track Usage (if applicable)

If any notes were referenced during planning/work:
- Increment `usage_count`
- Update `last_used` date

### 8. Update CLAUDE.md (optional)

Only for critical, cross-cutting learnings that every agent needs immediately:
- Fundamental conventions (e.g., "Always use Zod for validation")
- Critical gotchas (e.g., "UserContext loads async — check isLoading")
- Security requirements

Tag with source: `**From:** {{JIRA_ID}}`

**Default:** Most learnings go to `.memo/` only, not CLAUDE.md. Keep CLAUDE.md lean.

### 9. Clear Scratch

After successful migration:
- Clear `.memo/_scratch.md` completely
- Leave empty file for next session

### 10. Present Summary

Show user:

```
✅ Reflection complete — knowledge organized

Created 2 notes:
- .memo/standards/error-handling-api-responses.md
  Reasoning: Global concern (all API handlers), convention to follow

- .memo/refactoring/csv-import-excessive-boilerplate.md
  Reasoning: Friction point (3 occurrences), medium severity

Updated 1 note:
- .memo/architecture/auth-flow.md (added Mermaid diagram)
  Reasoning: Enhanced existing doc with visual flow

Skipped 1 entry:
- "Use Array.flatMap" — already documented in standards/array-methods.md

Updated .memo/INDEX.md with summaries.
Cleared .memo/_scratch.md for next session.

Changes ready for commit.
```

### 11. Commit Changes

```bash
git add .memo/ CLAUDE.md (if updated)
git commit -m "docs: reflect on {{JIRA_ID}} learnings

Created:
- standards/error-handling-api-responses.md (API error patterns)
- refactoring/csv-import-excessive-boilerplate.md (friction point)

Updated:
- architecture/auth-flow.md (added flow diagram)

Updated INDEX.md with detailed summaries."
```

## Note Creation Details

### Generic Note (standard/runbook/architecture)

```yaml
---
title: "Error handling for API responses"
tags: [api, error, response, typescript, zod]
created: 2026-02-23
updated: 2026-02-23
usage_count: 0
last_used: ""
---

# Error Handling for API Responses

## Problem/Context
One sentence: APIs need type-safe error handling for frontend to narrow types.

## Solution/Approach
Use discriminated unions with `success` boolean:

\`\`\`typescript
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string };
\`\`\`

Benefits:
- TypeScript narrows types correctly
- No manual type guards needed
- Works with Zod for runtime validation

## Code References
- `src/api/handlers/user.ts:45-67` — user handler example
- `src/api/handlers/product.ts:32-48` — product handler example

## See Also
- Zod integration guide
```

### Refactoring Note

```yaml
---
title: "CSV import requires excessive boilerplate"
tags: [csv, import, boilerplate, dx, validation]
created: 2026-02-23
severity: medium
friction_score: 7
occurrences: 3
affected_files:
  - src/services/import/csv-parser.ts
  - src/services/import/user-import.ts
suggested_approach: "Extract shared validation pipeline"
effort: medium
---

# CSV Import Requires Excessive Boilerplate

## Problem
Every CSV import requires ~50 lines of identical validation setup, making it error-prone and tedious.

## Current State
Three parsers (user, product, invoice) all duplicate:
- File reading
- CSV parsing
- Row validation
- Error collection

See files in affected_files above.

## Suggested Direction
Extract shared validation pipeline:
- Generic CSVValidator<T> class
- Reusable error formatting
- Common file reading utils

## Gains
- 40 lines saved per parser (~120 total)
- Single source of truth for validation
- Easier to test (test pipeline once)
- Reduced bug surface
```

## Partial Reflection (Session Ending Mid-Feature)

If session ends before feature complete:

1. Still migrate scratch → notes (don't lose learnings)
2. Don't update feature status (still in-progress)
3. Add note to `tasks.md` or feature folder: "Session ended at task X.Y"

Learnings are preserved, feature continues next session.

## Agent Decision Guidelines

**When to place in standards/ vs refactoring/:**
- **standards/** — we already do this, documenting the convention
- **refactoring/** — we should change this, documenting the friction

**When to place global vs submodule:**
- **global** — used in 2+ packages or fundamental to repo
- **submodule** — specific to one package's domain

**When to create vs update:**
- **create** — new topic not covered by existing notes
- **update** — adds example/case to existing note

**When to include diagram:**
- Flows (auth, data, user)
- Multi-step processes
- Architectures with components

## Reflection Questions (Self-Check)

| Category | Questions |
|----------|-----------|
| **Patterns** | What patterns emerged? Which should be standard? |
| **Friction** | What was painful? How many times? How to improve? |
| **Architecture** | What flows/designs need documentation? |
| **Gaps** | What wasn't documented? What questions recurred? |

## Validation

After reflection:
- All notes have valid YAML frontmatter
- All notes have file:line references
- INDEX.md is valid markdown
- Scratch is cleared
- No secrets in notes (grep check)

## Common Mistakes

- **Not providing reasoning** — Agent must explain placement decisions
- **Too specific examples** — Generalize code, don't copy-paste
- **Skipping diagrams** — Always add for flows/architecture
- **Forgetting INDEX.md summaries** — Summaries must be detailed
- **Not checking for existing notes** — Always check before creating
