---
name: omt-start-prd
description: Use when feature is scaffolded and needs PRD creation. Step 2 of omt workflow — run after omt-scaffold-feature, before omt-create-tech-spec
---

# Start PRD

## Overview

Spawns a Product Owner agent that interrogates the user to complete `prd.md`. PRD answers WHAT and WHY — no technical implementation. Keep it **high-level and digestible**. Target audience: senior engineers who will create the tech-spec.

## When to Use

- After `omt-scaffold-feature` created the feature folder
- PRD is empty or incomplete
- **Not** when PRD is already approved (check approval checkboxes)

## Process

### 1. Search Knowledge Base (Auto)

**Before starting PRD, auto-invoke `/omt-knowledge-search`** to find relevant knowledge:

Extract keywords from feature name/folder:

- Feature: `new-user-auth` → search "auth user"
- Feature: `csv-export-users` → search "csv export"

Present findings:

```
📚 Relevant knowledge found:

Standards:
- error-handling-api-responses.md - API error patterns
- validation-patterns.md - Input validation with Zod

Refactoring:
- auth-jwt-validation-complex.md - Known friction with JWT validation

Use these references when defining requirements.
```

If `.memo/` doesn't exist (not set up yet):

- Skip search
- Note: "Knowledge base not initialized. Run /omt-setup to enable."

### 2. Locate Feature Folder

Find the feature folder (in order):
1. `OMT_TASK_CONTEXT` env var → path to task folder
2. `.omt-context` file in repo root → read path from it
3. Find most recent `pending-*` in tasks-vault
4. Ask user

### 3. Read Current PRD

Read `prd.md` to see what's filled in

### 4. Spawn Product Owner Agent

Spawn via Task tool:

- `subagent_type="general-purpose"`, `name="product-owner"`
- Pass current prd.md content and feature folder path
- Agent asks painful questions one at a time (who, what, why, scope, metrics)
  - Agent also focuses on clear success/acceptance criteria, search for edge cases and definition of done.
- Agent fills Questions table (`PENDING`/`RESOLVED` status) and Assumptions table (`CONFIRMED`/`UNCONFIRMED`)
- Agent includes key file references if known from discussion
- Agent gets explicit user approval

4. **Verify completion** — prd.md filled, approval checkboxes marked

## Quick Reference

| Agent behavior | Expectation                                       |
| -------------- | ------------------------------------------------- |
| Tone           | High-level — WHAT/WHY only, no technical HOW      |
| Questions      | One at a time, multiple choice when possible      |
| Open questions | Captured in Questions table with `PENDING` status |
| Assumptions    | Captured with risk-if-wrong and validation method |
| Vague answers  | Probe deeper for specifics                        |
| Scope          | Explicit in-scope AND out-of-scope (YAGNI)        |
| Key files      | Reference known relevant files if discussed       |
| Approval       | Explicit user sign-off required                   |

## Common Mistakes

- Writing too much detail — PRD should be skimmable, not exhaustive
- Letting vague requirements pass ("make it better", "it should be fast")
- Skipping out-of-scope section (leads to scope creep)
- Discussing implementation details in PRD phase
- Not documenting assumptions with risk-if-wrong

## Output

When complete: "PRD approved. Next: run `omt-create-tech-spec` skill."
