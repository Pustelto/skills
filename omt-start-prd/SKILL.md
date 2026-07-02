---
name: omt-start-prd
description: Use when feature is scaffolded and needs PRD creation. Step 2 of omt workflow — run after omt-scaffold-feature, before omt-create-tech-spec
---

# Start PRD

## Overview

**Transforms already-resolved feature knowledge into `prd.md`** — it does not run a fresh interrogation. The expected flow: the user first stress-tests the idea with `/grill-me` (Matt Pocock's grilling skill) or an equivalent design discussion until the open questions are answered, then runs this skill to distill that shared understanding into a PRD.

PRD answers WHAT and WHY — no technical implementation. Keep it **high-level and digestible**. Target audience: senior engineers who will create the tech-spec. Runs in the **main thread** — no Product Owner sub-agent.

## When to Use

- After the feature has been grilled/discussed (e.g. via `/grill-me`) and the open questions are resolved
- After `omt-scaffold-feature` created the feature folder
- PRD is empty or incomplete
- **Not** when PRD is already approved (check approval checkboxes)
- **Not** as a substitute for grilling — if the idea hasn't been stress-tested yet, run `/grill-me` first, then come back here

## Process

### 1. Gather Relevant Context

**Before writing the PRD, pull in what's already known:**

- **The prior grilling / discussion.** This skill is normally run *after* a `/grill-me` session (or equivalent design discussion) has resolved the open questions. Treat that conversation as the primary source — the PRD transforms it, it doesn't re-derive it.
- **Project knowledge in `docs/`.** Look in the `docs/` folder at the project (repo) root for relevant standards, architecture notes, and runbooks. If `docs/INDEX.md` exists, read it first to find the relevant notes by keyword from the feature name (e.g. `new-user-auth` → "auth"; `csv-export-users` → "csv export"). Reference these when defining requirements and constraints.

If `docs/` doesn't exist, skip it — just proceed from the grilling/discussion and the user's input.

### 2. Locate Feature Folder

Find the feature folder (in order):
1. `OMT_TASK_CONTEXT` env var → path to task folder
2. `.omt-context` file in repo root → read path from it
3. Find most recent `pending-*` in tasks-vault
4. Ask user

### 3. Read Current PRD

Read `prd.md` to see what's filled in

### 4. Write the PRD (transform, in main thread)

Distill the resolved knowledge (grilling output + discussion + `docs/` context) into `prd.md`. Do this **yourself in the main thread** — do not spawn a Product Owner sub-agent and do not re-interrogate the user. The grilling already happened; your job is to capture its conclusions faithfully and structure them.

Fill the PRD:

- **Problem & Why now**, **Proposed solution / high-level flow**, **Scope (in + explicit out, YAGNI)** — from what was decided during grilling.
- An explicit, **numbered `## Acceptance Criteria` list** (separate from the prose Success Metrics). Each criterion must be:
  - **User-observable** — phrased as an outcome a user/caller sees, not an implementation step.
  - **Testable end-to-end** — verifiable through the real entry point (the screen, the API, the command), so the tech-spec and tasks can trace each one to an actual test. Avoid criteria that a partial/dead-code implementation could satisfy on paper (e.g. prefer "editing a reference shows the impacted tables" over "impact is computed").
  - **Numbered (AC1, AC2, …)** so the tech-spec's testing strategy and each task can reference them by id.
- **Questions table** (`PENDING`/`RESOLVED`) — most should already be `RESOLVED` from grilling; carry forward any that remain open.
- **Assumptions table** (`CONFIRMED`/`UNCONFIRMED`) with risk-if-wrong and validation method.
- **Key file references** if known from the discussion.

**Only ask the user focused questions if a genuine gap remains** after the grilling — a missing acceptance criterion, an unstated scope boundary, an unconfirmed assumption that matters. Don't restage a full interrogation.

### 5. Get Approval & Verify

- Present the drafted PRD and ask for explicit sign-off.
- **Verify completion** — prd.md filled, approval checkboxes marked.

## Quick Reference

| Aspect         | Expectation                                                  |
| -------------- | ----------------------------------------------------------- |
| Source         | Transform prior `/grill-me` output — don't re-interrogate   |
| Where it runs  | Main thread — no Product Owner sub-agent                    |
| Tone           | High-level — WHAT/WHY only, no technical HOW                |
| Open questions | Captured in Questions table with `PENDING` status           |
| Assumptions    | Captured with risk-if-wrong and validation method           |
| Remaining gaps | Ask focused questions only when grilling left a real gap    |
| Scope          | Explicit in-scope AND out-of-scope (YAGNI)                  |
| Key files      | Reference known relevant files if discussed                 |
| Approval       | Explicit user sign-off required                             |

## Common Mistakes

- Writing too much detail — PRD should be skimmable, not exhaustive
- **Re-interrogating the user** instead of transforming the grilling that already happened — restate the resolved conclusions, only ask about genuine gaps
- **Acceptance criteria that aren't testable end-to-end** — "impact is computed" can be satisfied by dead code; "editing a reference shows the impacted tables" names a user-observable outcome through the real entry point. Number them (AC1…) so the tech-spec and tasks trace to them.
- Letting vague requirements pass ("make it better", "it should be fast")
- Skipping out-of-scope section (leads to scope creep)
- Discussing implementation details in PRD phase
- Not documenting assumptions with risk-if-wrong

## Output

When complete: "PRD approved. Next: run `omt-create-tech-spec` skill."
