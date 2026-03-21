---
name: omt-compound-log
description: Use during omt-execute-task step 6 (log) to capture learnings in implementation.md for future work
---

# Compound Log

## Overview

Document learnings, patterns, and gotchas in `implementation.md` so each unit of work makes future work easier. This is the "compound" in Compound Engineering.

## When to Use

- After completing any task (execute-task Step 6)
- After discovering a useful pattern or a gotcha
- Before ending a session
- **Not** for end-of-feature reflection (use `omt-reflect` skill)

## What to Log

| Category | What to capture | Example |
|----------|----------------|---------|
| **Daily Log** | Timestamp, task ID, changes, divergence, outcome | Table row in implementation.md |
| **Sharp Knives** | Patterns that worked well, with context + file:line | "Zod validation — better TS inference than Joi" |
| **Landmines** | Gotchas with root cause + prevention | "UserContext loads async — check isLoading first" |
| **Divergences** | Changes from tech-spec with reason + approval | "Used Zod instead of Joi — approved by user" |
| **Patterns** | Reusable code patterns with location | "Discriminated union for API responses" |
| **Refactoring Debt** | Deferred improvements with effort + priority | "Extract validation to module — 30 min, low priority" |

## Process

1. Ask implementing agent (or yourself): What worked well? What was difficult? Any patterns? Divergences?
2. Update the relevant section(s) in `implementation.md`
3. Include file:line references for discoverability
4. Be specific — "Zod catches type errors at compile time" not "validation works"

## Common Mistakes

- Logging too late (details forgotten)
- Generic entries without file references
- Not updating refactoring debt when deferring work
- Forgetting to note divergences from tech-spec
