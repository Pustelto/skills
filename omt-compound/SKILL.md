---
name: omt-compound
description: Quick capture learnings to _implementation.md during work. Auto-invoked by agents when discovering patterns, friction, or useful knowledge. Migrated to organized notes by omt-reflect.
---

# Compound Quick Capture

## Overview

Append learnings to `_implementation.md` (in repo root) during work sessions with zero friction. No YAML frontmatter, no organization decisions — just capture and move on. `omt-reflect` organizes it later.

## When to Use

**Auto-invoked by agents:**

- During `omt-execute-task` when discovering patterns
- During debugging when hitting friction points
- When finding reusable code patterns
- When discovering refactoring opportunities

**Manual invocation:**

```
/omt-compound "Quick note about X"
/omt-compound "CSV import needs Zod validation"
/omt-compound "Auth flow is confusing — needs diagram"
```

## Process

### 1. Accept Input

**With argument (explicit capture):**

```
/omt-compound "Quick note about X"
```

Input can be:

- Free text: "Found that error responses need discriminated unions"
- Structured: "Pattern: use Zod for validation. See: src/api/validation.ts:23"
- Mixed: Whatever the agent or user types

**Without argument (extract from conversation):**

```
/omt-compound
```

If invoked with no argument:

1. Read current conversation
2. Extract key learnings/patterns discussed:
   - Code patterns discovered
   - Friction points encountered
   - Solutions that worked
   - Refactoring opportunities identified
     - THIS IS SUPER IMPORTANT: focus on suboptimal architecture and bad patterns, that make navigation in the codebase, maintenance or testing hard. Note those things and add a short suggestion/idea how to eventually solve it with software engineering best practices - we should accumulate this knowledge and use it later to run regular refactors
     - Favor clear APIs & interfaces, follow "screaming architecture" principle when thinking about refactoring opportunities
   - Places where you were stuck
   - Situations where user has to correct you
   - Focus on documentation, process, architecture holes so future steps are easier
   - Non obvious things
3. Generate concise note summarizing the learning
4. Ask user to confirm before capturing (optional, can be skipped if obvious)

Example scenario:

```
User: "How do we handle CSV validation?"
Agent: "Looking at the code, we use Zod schemas..."
[Discussion about validation patterns]
User: "/omt-compound"
Agent: Extracted learning:
  "CSV validation pattern: Use Zod schemas for type-safe parsing.
   All parsers follow same pattern with schema definition.
   See: src/services/import/*.ts"

  Capture this? (y/n)
```

**Auto-extraction rules:**

- Only extract if something actionable was discovered/discussed
- Include file references if code was read/modified
- Summarize in 2-4 sentences max
- If nothing clear to extract, ask user: "What should I capture?"
- Reusability for the future is a key: Later those findings will be distilled to permanent notes and knowledge. So they should provide high value

### 2. Format Entry

```markdown
## [{TIMESTAMP}] {First line or auto-generated title}

{Full content}

{File references if mentioned}

---
```

Example:

```markdown
## [2026-02-23 14:30] Error handling pattern discovered

Found that API responses need discriminated unions for type safety.
Without them, TypeScript can't narrow error types properly.

Pattern:
type ApiResponse<T> =
| { success: true; data: T }
| { success: false; error: string };

See: src/api/handlers/user.ts:45-67

---
```

### 3. Append to \_implementation.md

```bash
# Read existing _implementation.md
# Append new entry
# Save
```

**Key:** Just append, no validation, no categories, no decisions.

### 4. Confirm

Quick confirmation:

```
✓ Added to _implementation.md: "Error handling pattern discovered"
```

No ceremony. Back to work immediately.

## With vs Without Argument

| Invocation             | Behavior                         | Best For                              |
| ---------------------- | -------------------------------- | ------------------------------------- |
| `/omt-compound "text"` | Direct capture of provided text  | When you know exactly what to capture |
| `/omt-compound`        | Extract from recent conversation | After discussing a pattern/solution   |
| Auto-invoked by agent  | Agent decides what to capture    | During discovery in execute-task      |

## Conversation Extraction Examples

### Example 1: Pattern Discovery

**Conversation:**

```
User: "Why are we using discriminated unions for API responses?"
Agent: "Looking at src/api/handlers/*.ts, I see a consistent pattern..."
Agent: [Explains the pattern with code examples]
User: "/omt-compound"
```

**Extracted:**

```markdown
## [2026-02-23 14:30] API response pattern - discriminated unions

API responses use discriminated unions with success boolean for type safety.
Pattern: type ApiResponse<T> = {success: true; data: T} | {success: false; error: string}

Allows TypeScript to narrow types without manual guards.

See: src/api/handlers/user.ts, src/api/handlers/product.ts

---
```

### Example 2: Friction Discovery

**Conversation:**

```
Agent: "I'm setting up CSV validation for the third time..."
Agent: "Same 50 lines of boilerplate each time"
User: "/omt-compound"
```

**Extracted:**

```markdown
## [2026-02-23 15:45] CSV validation boilerplate friction

Repetitive validation setup across CSV parsers (3rd occurrence).
Each parser needs ~50 lines for reading, parsing, validation, error handling.

Friction: error-prone, tedious
Suggested: extract shared CSVValidator<T> pipeline

Files: src/services/import/csv-parser.ts, user-import.ts, invoice-import.ts

---
```

### Example 3: Nothing Clear to Capture

**Conversation:**

```
User: "What's the status of the tests?"
Agent: "All tests passing"
User: "/omt-compound"
```

**Response:**

```
No clear learning or pattern to capture from recent conversation.

What would you like to capture? Or provide text:
/omt-compound "your note here"
```

## Entry Types

### Sharp Knife (Pattern That Worked)

```markdown
## [2026-02-23 10:15] Zod validation — better inference than Joi

Using Zod for API validation gives better TypeScript inference.
No manual type definitions needed.

Pattern: Define schema once, infer types.

See: src/api/validation/user-schema.ts:12-30

---
```

### Landmine (Gotcha/Friction)

```markdown
## [2026-02-23 11:45] CSV import boilerplate

Every CSV import requires same 50 lines of validation setup.
Hit this 3rd time on file parsers.

Friction: repetitive, error-prone
Suggestion: extract shared validation pipeline

See:

- src/services/import/csv-parser.ts:45-95
- src/services/import/user-import.ts:67-115

---
```

### Architecture Note

```markdown
## [2026-02-23 13:20] Auth flow needs visual diagram

Auth flow spans 4 files and is hard to follow.
Took 30 min to understand JWT validation chain.

Need: Mermaid sequence diagram showing flow

Files:

- src/auth/middleware.ts
- src/auth/jwt-validator.ts
- src/api/guards/\*.ts

---
```

### Divergence from Plan

```markdown
## [2026-02-23 15:00] Used Zod instead of Joi (tech-spec said Joi)

Tech-spec suggested Joi, but Zod has better TS inference.
Discussed with team, approved the swap.

Reason: Better DX, less boilerplate
Approval: User (Slack thread #eng-123)

---
```

## Auto-Invocation Pattern

For agents that support auto-invocation:

**In omt-execute-task:**

- After discovering a pattern → auto-invoke omt-compound
- After hitting friction → auto-invoke omt-compound
- After finding refactoring opportunity → auto-invoke omt-compound

**Pattern:**

```
Agent implements task...
Agent discovers: "This validation pattern is used 3x now"
Agent auto-invokes: /omt-compound "Validation pattern repeated 3x, see files..."
Agent continues work...
```

## Scratch File Management

### During Session

`_implementation.md` grows with timestamped entries. This is fine — it's temporary.

### At Session End

`/omt-reflect` will:

1. Read all entries
2. Organize into proper notes (standards/, runbooks/, etc.)
3. Update INDEX.md
4. Clear \_implementation.md

So the file is always cleaned up — never accumulates long-term.

## Multiple Sessions

If session ends without reflection:

- `_implementation.md` keeps growing
- Next session continues appending
- Eventually `/omt-reflect` processes ALL entries

This is fine. It can accumulate across sessions if needed.

## _implementation.md vs. Direct Notes

| Use _implementation.md (omt-compound) | Use direct notes (omt-knowledge-update) |
| ------------------------------------- | --------------------------------------- |
| During active work                    | After work, manual maintenance          |
| Quick capture, no thinking            | Deliberate documentation                |
| Will be organized later               | Already organized                       |
| Encouraged — captures context         | Rare — only for corrections             |

**Default to _implementation.md.** It's faster and context gets preserved.

## For Non-OMT Workflows

This skill works outside OMT:

- During any debugging session
- During any feature work
- During code review

Just capture to `_implementation.md`, reflect later.

## Common Patterns

### Quick Win

```
/omt-compound "Use Array.flatMap instead of map+flat. More readable."
```

### With Context

```
/omt-compound "PostHog event names must match product_event_action pattern.
See: src/analytics/events.ts for examples.
Docs: https://docs.posthog.com/naming"
```

### Friction Point

```
/omt-compound "Test setup requires 40 lines of mocking.
Every test file has same boilerplate.
Files: src/**/*.test.ts
Severity: medium, Occurrences: 8+"
```

## Validation

None. Scratch is free-form. Validation happens during `omt-reflect`.

## Common Issues

- **_implementation.md huge** → Run `/omt-reflect` to migrate and clear
- **Forgot to capture during work** → Manually add to `_implementation.md` before reflect
- **Agent over-capturing** → Fine, reflect will consolidate
