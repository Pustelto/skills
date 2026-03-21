---
name: omt-knowledge-search
description: Search .memo/ knowledge base for relevant standards, patterns, past friction. Auto-invoked during planning (omt-start-prd, omt-create-tech-spec). Manual: /omt-search <query>
---

# Knowledge Search

## Overview

Find relevant knowledge in `.memo/` before starting work. Searches INDEX.md, filenames, frontmatter tags, and note content. Tracks usage to identify helpful notes.

**Auto-invoked** during planning phases to surface relevant standards and past learnings.

## When to Use

**Auto-invocation (no user action needed):**
- Start of `omt-start-prd` — search for relevant standards and past friction
- Start of `omt-create-tech-spec` — search for architectural patterns and decisions

**Manual invocation:**
```
/omt-search "error handling"
/omt-search "CSV import"
/omt-search "auth flow"
/omt-search "PostHog tracking"
```

## Process

### 1. Accept Search Query

Query can be:
- Topic: "error handling", "validation", "testing"
- Problem: "CSV import", "auth issues", "slow queries"
- Technology: "PostHog", "React", "Zod"
- Mixed: "React component testing patterns"

**For auto-invocation:**
Extract keywords from feature description:
- Feature: "Add user authentication with JWT" → ["auth", "jwt", "user"]
- Feature: "Fix CSV import errors" → ["csv", "import", "error"]

### 2. Multi-Strategy Search

Run searches in parallel, then merge results:

#### Strategy 1: INDEX.md Scan

Read `.memo/INDEX.md` (and submodule INDEX.md if relevant):
- Search note titles
- Search summaries (most important — detailed context)
- Grep for query keywords

Example:
```markdown
| Note | Summary |
|------|---------|
| [error-handling-api-responses](./standards/error-handling-api-responses.md) | Three patterns we use for API errors: discriminated unions (type-safe), Result type (explicit), and error boundaries (React). Includes Zod integration. |
```

Query "error api" → Match found in title AND summary.

#### Strategy 2: Filename Scan

List all `.md` files in `.memo/` folders:
```bash
find .memo/ -name "*.md" -not -name "_scratch.md" -not -name "INDEX.md"
```

Grep filenames for keywords:
- `error-handling-api-responses.md` matches "error"
- `csv-import-excessive-boilerplate.md` matches "csv import"

**SEO-optimized names help here** — consistent keywords make search reliable.

#### Strategy 3: Frontmatter Scan

Grep YAML frontmatter for:
- `title:` field
- `tags:` array

Example:
```bash
grep -r "tags:.*error" .memo/ --include="*.md"
```

#### Strategy 4: Content Grep

Grep note body content:
```bash
grep -r "error handling" .memo/ --include="*.md" -A 2 -B 2
```

Returns context around matches.

#### Strategy 5: QMD (if available)

If qmd is installed and configured:
```bash
qmd query "error handling" --collection memo --json
```

Uses hybrid BM25 + vector search for semantic matching.

### 3. Rank Results

Combine results and rank by relevance:

| Score | Match Type |
|-------|-----------|
| 10 | INDEX.md summary match (most specific) |
| 8 | Filename exact match |
| 6 | Title match in frontmatter |
| 5 | Tag match |
| 3 | Content match |
| 2 | Partial filename match |

Example:
- Query "error handling api"
- `error-handling-api-responses.md` scores: 8 (filename) + 10 (INDEX summary) = 18
- `testing-error-cases.md` scores: 2 (partial filename) + 3 (content) = 5

### 4. Return Top Results

Return top 5-10 results with:
- Note title and path
- Matched summary from INDEX.md
- Matched tags
- Relevance score
- Why it matched

Example output:
```
Found 3 relevant notes:

1. error-handling-api-responses.md (score: 18)
   Category: standards
   Summary: Three patterns we use for API errors: discriminated unions
            (type-safe), Result type (explicit), and error boundaries (React).
   Tags: [api, error, response, typescript, zod]
   Matched: filename + INDEX summary

2. csv-import-excessive-boilerplate.md (score: 12)
   Category: refactoring
   Summary: CSV import requires too much boilerplate for validation setup;
            suggests shared validation pipeline to reduce duplication.
   Tags: [csv, import, boilerplate, dx]
   Matched: filename + tags

3. testing-error-cases.md (score: 8)
   Category: runbooks
   Summary: How to test error cases in API handlers with mock responses.
   Tags: [testing, error, api]
   Matched: content
```

### 5. Track Usage

For each note returned that user/agent references:
- Increment `usage_count` in frontmatter
- Update `last_used` to today's date

This happens when:
- Agent says "Following pattern from error-handling-api-responses.md"
- User opens the note
- During reflection, agent mentions "Used X note"

**Tracking is silent** — no user confirmation needed.

### 6. Present Findings

**For auto-invocation:**
```
📚 Relevant knowledge found:

- error-handling-api-responses.md (standards)
  Use discriminated unions for type-safe API errors

- auth-flow.md (architecture)
  JWT validation flow with middleware chain

Continue with planning using these references.
```

**For manual search:**
```
Found 3 notes matching "error handling":

1. [standards] error-handling-api-responses.md
   Three patterns for API errors (discriminated unions, Result type, boundaries)

2. [runbooks] testing-error-cases.md
   How to test error cases with mock responses

3. [refactoring] api-error-logging-inconsistent.md
   Friction point: error logging varies across services

Use /read to view full notes.
```

## Search Patterns

### Planning Phase Search

**When:** Start of `omt-start-prd`

**Extract keywords:**
- Feature: "Add CSV export for user data"
- Keywords: ["csv", "export", "user", "data"]

**Search focus:**
- Standards (how we do CSV)
- Refactoring (known CSV friction)
- Runbooks (procedures for similar features)

**Why:** Surface relevant conventions BEFORE writing PRD.

### Tech Spec Phase Search

**When:** Start of `omt-create-tech-spec`

**Extract keywords:**
- Feature: "Implement real-time notifications"
- Keywords: ["realtime", "notifications", "websocket", "pubsub"]

**Search focus:**
- Architecture (how we handle realtime)
- Standards (notification patterns)
- Past decisions (ADRs if they exist)

**Why:** Surface architectural patterns BEFORE designing solution.

### Debug/Investigation Search

**Manual:**
```
/omt-search "CSV import error"
/omt-search "auth JWT validation"
```

**Why:** Find if this problem was solved before.

## Search Tips

### Effective Queries

| Query | Why It Works |
|-------|-------------|
| "error handling" | Matches common keywords |
| "CSV import" | Matches category + action |
| "React component patterns" | Matches tech + concept |
| "PostHog event tracking" | Matches specific tech |

### Ineffective Queries

| Query | Why It Fails |
|-------|-------------|
| "fix bug" | Too vague |
| "that thing we did" | No keywords |
| "how do we..." | Question format, no nouns |

**Best practice:** Use nouns and specific terms, not questions.

## Empty Results

If search finds nothing:

```
No existing notes found for "topic".

This might be a new area. Capture learnings during work:
1. Use /omt-compound for quick notes
2. Use /omt-reflect at session end to organize

Your work will create the first note for this topic!
```

## For Submodules

If working in a submodule:
- Search both global `.memo/` and submodule `.memo/`
- Prioritize submodule results (more specific)
- Show results from both with labels

Example:
```
Found 2 notes:

[global] error-handling-api-responses.md
  General API error patterns

[frontend] react-error-boundary-setup.md
  Frontend-specific error boundaries with Sentry
```

## QMD Integration

If qmd is available:

```bash
# Check if qmd is available
which qmd

# If yes, use for semantic search
qmd query "how to handle CSV import errors" --collection memo --json
```

QMD provides:
- Semantic matching (not just keyword)
- Better ranking
- 95% token reduction

But filename/INDEX search still runs (qmd supplements, doesn't replace).

## Performance

**Fast path (most common):**
1. INDEX.md scan (single file read)
2. Return matches from INDEX summaries
3. Total: <100ms

**Slow path (no INDEX matches):**
1. Full content grep across all notes
2. Read matched files
3. Total: <1s

**QMD path (if available):**
1. Semantic search via qmd
2. Total: <500ms

## Validation

Search never modifies files — read-only operation.

## Common Issues

- **No results but notes exist** → Check filename keywords (SEO optimization)
- **Too many results** → Refine query with more specific terms
- **QMD not working** → Falls back to grep automatically
