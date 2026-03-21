---
name: omt-seed
description: Populate .memo/ with existing knowledge from CLAUDE.md, docs, and codebase patterns. Optional targeted search with prompt (e.g., "PostHog analytics"). Run after omt-setup.
---

# Seed Compound Memory System

## Overview

Migrate existing knowledge into `.memo/` by:
1. Reading CLAUDE.md, README.md, CONTRIBUTING.md
2. Searching codebase for patterns (low-hanging fruit or targeted)
3. Creating organized notes in appropriate `.memo/` folders
4. Updating INDEX.md

This is **optional** — you can build the knowledge base organically via `omt-reflect`, but seeding gives you a head start.

## When to Use

- After running `omt-setup` to populate initial knowledge
- When you want to document a specific area (targeted seeding)
- When migrating to compound memory system

## Usage Patterns

### Full Scan (Low-Hanging Fruit)

```
/omt-seed
```

Searches for obvious patterns:
- Error handling approaches
- Common validation patterns
- Test setup patterns
- API endpoint structures

### Targeted Search

```
/omt-seed "error handling"
/omt-seed "PostHog analytics"
/omt-seed "auth patterns"
/omt-seed "React component patterns"
```

Focuses on specific area:
- Grep for relevant files
- Extract patterns with context
- Document with file references

## Process

### 1. Parse Optional Prompt

If prompt provided:
- Extract focus area keywords
- Example: "PostHog analytics" → ["posthog", "analytics", "tracking", "event"]

If no prompt:
- Use default focus areas: error handling, validation, testing, API patterns

### 2. Read Existing Documentation

**CLAUDE.md:**
- Extract sections about:
  - Coding guidelines → `.memo/standards/`
  - Common gotchas → `.memo/standards/` or `.memo/refactoring/`
  - Patterns discovered → `.memo/standards/`
  - Architecture notes → `.memo/architecture/`

**README.md:**
- Extract conventions, setup patterns

**CONTRIBUTING.md:**
- Extract contribution patterns, testing guidelines

### 3. Search Codebase

**Strategy:**

If targeted prompt:
```bash
# Find files related to focus area
grep -r "posthog" --include="*.ts" --include="*.tsx"
# Read relevant files, extract patterns
```

If full scan (low-hanging fruit only):
```bash
# Look for common patterns
grep -r "error" src/ --include="*.ts" | head -20
grep -r "validation" src/ --include="*.ts" | head -20
grep -r "test" src/ --include="*.ts" | head -20
```

**What to extract:**
- Consistent patterns (repeated across 3+ files)
- Framework-specific approaches (e.g., Zod validation, React patterns)
- Common utilities and their usage
- NOT: One-off code, obvious framework usage, trivial patterns

### 4. Create Notes

For each pattern found:

**Determine category:**
- Conventions/patterns → `standards/`
- Procedures → `runbooks/`
- System design → `architecture/`
- Pain points → `refactoring/` (if friction detected)

**Determine level:**
- Used across entire codebase → global `.memo/`
- Specific to one package → `packages/{name}/.memo/`

**Create note:**

```yaml
---
title: "{Descriptive title}"
tags: [{relevant}, {keywords}]
created: {TODAY}
updated: {TODAY}
usage_count: 0
last_used: ""
---

# {Title}

## Problem/Context
One sentence: what this solves or when it's relevant.

## Solution/Approach
- Brief explanation
- Pattern extracted from code
- File references for examples

## Code References
- `src/api/handlers/user.ts:45-67` — example usage
- `src/api/handlers/product.ts:32-48` — similar pattern

## See Also
- Related patterns or external links
```

**Key principles:**
- **Generalize** — don't copy exact code, extract the pattern
- **Reference real code** — always include file:line for examples
- **Short** — 50-200 lines max
- **SEO keywords** — use consistent terms (error, test, auth)

### 5. Update INDEX.md

For each created note:
- Add row to appropriate category section
- Include note title + link
- Add detailed summary (more than just title)

Example:
```markdown
## Standards

| Note | Summary |
|------|---------|
| [error-handling-api-responses](./standards/error-handling-api-responses.md) | Three patterns we use for API errors: discriminated unions (type-safe), Result type (explicit), and error boundaries (React). Includes Zod integration. |
```

### 6. Present Summary

Show user:

```
✅ Seeded compound memory system

Created {N} notes:

Standards:
- error-handling-api-responses.md (from src/api/handlers/*.ts)
- react-component-composition.md (from src/components/*.tsx)

Runbooks:
- adding-new-api-endpoint.md (from CONTRIBUTING.md + src/api/)

Architecture:
- auth-flow.md (extracted from src/auth/ + docs/)

Refactoring:
- csv-import-excessive-boilerplate.md (found 3 occurrences)

Updated .memo/INDEX.md with summaries.

Next: Use `/omt-compound` during work to add more knowledge.
```

### 7. Commit Changes

```bash
git add .memo/
git commit -m "docs: seed compound memory from existing knowledge

Extracted patterns from:
- CLAUDE.md (coding guidelines)
- Codebase (error handling, validation, React patterns)
- README.md (setup conventions)

Created {N} initial notes across standards, runbooks, architecture.

Run with specific topics: /omt-seed \"topic name\""
```

## Extraction Examples

### Error Handling Pattern

**Found in multiple files:**
```typescript
// src/api/handlers/user.ts:45
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string };
```

**Creates:**
`.memo/standards/error-handling-api-responses.md`

### PostHog Tracking Pattern

**Targeted search:**
```
/omt-seed "PostHog analytics"
```

**Finds:**
```typescript
// src/analytics/events.ts
posthog.capture('button_clicked', { button_name: 'submit' })
```

**Creates:**
`.memo/standards/posthog-event-tracking.md` with conventions

## Safety & Limits

**Limits to prevent overwhelming:**
- Max 10 notes per category on full scan
- Max 20 notes total on full scan
- No limit on targeted search (but warn if >20 results)

**Safety:**
- Never extract secrets, API keys, credentials
- Skip generated files (dist/, build/, node_modules/)
- Skip vendor code
- Only extract if pattern appears 2+ times (or prompt-targeted)

## For Submodules

If `.memo/` exists in submodules:
- Seed those too (if relevant)
- Ask user: "Seed submodules? (y/n)"
- Place submodule-specific patterns in submodule `.memo/`

## Validation

After seeding:
- All notes have valid YAML frontmatter
- All notes have file references
- INDEX.md is valid markdown
- No secrets extracted (grep for common patterns)

## Common Issues

- **No patterns found** → Codebase too small/unique, build organically via reflect
- **Too many patterns** → Use targeted search to focus
- **Secrets detected** → Skip and warn user
