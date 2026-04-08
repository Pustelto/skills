---
name: omt-create-tasks
description: Use when tech-spec is approved and needs task breakdown into vertical slices. Run after omt-create-tech-spec, before omt-execute-task. Creates tasks.md with tracer-bullet-first ordering
---

# Create Tasks

## Overview

Takes an approved `tech-spec.md` and `prd.md`, creates `tasks.md` with **small, granular tasks** (max 20 min each, 1 task = 1 commit) following tracer-bullet and walking-skeleton approach. Tasks are grouped into MR-sized milestones that are independently mergeable. Requires explicit user approval before execution begins.

**Cardinal rule:** Many small, easy-to-verify tasks > fewer large tasks. When in doubt, split further.

## When to Use

- Tech-spec is approved (check approval checkboxes in tech-spec.md)
- Before any coding starts
- **Not** when tech-spec is incomplete — run `omt-create-tech-spec` first
- **Not** for execution — run `omt-execute-task` after tasks are approved

## Process

### 1. Verify Tech-Spec Approved

Check for "Architecture approved" in tech-spec.md. If not approved, stop.

### 2. Locate Feature Folder

Find the feature folder (in order):
1. `OMT_TASK_CONTEXT` env var → path to task folder
2. `.omt-context` file in repo root → read path from it
3. Ask user

### 3. Load Context

Read from feature folder:
- `prd.md` — requirements, acceptance criteria, scope
- `tech-spec.md` — architecture, interfaces, phases, feature flags

Extract key inputs:
- **Interfaces/contracts** from tech-spec (tasks implement these)
- **Phases** from implementation plan (map to milestones)
- **Feature flags** (tasks wire these from T1)
- **Module boundaries** (tasks respect these)

### 4. Create Tasks File from Template

If not existing:
- Resolve template: `<tasks-vault>/_templates/tasks.md` if exists, otherwise `<skills-repo>/templates/tasks.md`
  - Tasks vault path: `$HOME/.omt.config` (plain text, single line). Fallback: `$HOME/omt-tasks/`
  - Skills repo path: derive from this SKILL.md file's location — go up one directory
- Replace placeholders (`{{FEATURE_NAME}}`, `{{JIRA_ID}}`, `{{STATUS}}`, `{{DATE}}`)
- Write `tasks.md` to feature folder

### 5. Design Task Breakdown

Apply these principles in order:

#### 5a. Tracer Bullet First (T1 is ALWAYS this)

The very first task is a **tiny end-to-end slice** that proves the architecture:
- Wires the full vertical path: entry point → through all layers → output
- Uses hardcoded/trivial implementation behind the interfaces defined in tech-spec
- Deploys behind a feature flag
- Result: a working skeleton you can demo, even if it does almost nothing

Example: "Wire API endpoint → service → repository → DB query → response. Hardcoded filter, single field. Behind FF. Proves the data flow works."

#### 5b. Task Sizing — 20 Minutes Max

**Each task MUST be completable in ≤20 minutes** (including tests). This is the single most important constraint.

**1 task = 1 commit.** A task is the unit of work that produces exactly one focused commit.

**Splitting litmus test — if ANY of these are true, the task is too big:**
- Task has more than 3-4 acceptance criteria
- Task touches more than 2-3 files (excluding test files)
- Task bundles two distinct UI concerns (e.g., "preview panel + impact banner" → split into two tasks)
- Task includes a multi-step wizard → each step is its own task
- Task description needs sub-headers to explain different parts
- You need more than a short paragraph to describe the implementation

**How to split large tasks:**
- **By UI concern:** "Add button + wire handler" is one task, "Add dialog content" is another
- **By data flow layer:** "Add GraphQL query + hook" is one task, "Wire hook into component" is another
- **By wizard step:** Each step of a multi-step wizard is its own task
- **By behavior:** "Create form with validation" → split to "Create form shell" + "Add validation logic"
- **By state:** "Add Zustand store + wire to UI" → split to "Create store with actions" + "Connect store to component"

#### 5c. Walking Skeleton / Vertical Slices

Each subsequent task extends the skeleton:
- Never build a horizontal layer (all models, then all services, then all UI)
- Each task touches all layers needed for ONE small capability
- Each task leaves the system in a working state

#### 5d. Milestone Grouping (= MR Boundaries)

Group tasks into milestones. Each milestone = one mergeable MR. Each milestone:
- Is independently mergeable to main (with feature flag if needed)
- Contains multiple small tasks that together form a functional increment
- Delivers visible value (not just "infrastructure")
- Has clear acceptance criteria

**Task mergeability annotations:** A single task might NOT be independently mergeable (e.g., a store without UI that uses it). For each task, annotate:
- **Standalone mergeable?** Yes/No
- **If No → Required companion tasks:** list the minimum set of tasks needed for a mergeable unit
- Keep the number of required companion tasks to the absolute minimum

#### 5e. Task Ordering for Fastest Feedback

1. Tracer bullet (proves architecture)
2. Core happy path (proves value)
3. Edge cases and error handling
4. Polish, optimization, cleanup

### 6. Write tasks.md

For each task, include:
- **Goal** (one sentence — if you need two sentences, the task is too big)
- **Interfaces implemented** — which contracts from tech-spec this task implements
- **Feature flag** — how this task uses FF (wire new / extend existing / not needed)
- **Files** to modify and create (with test files) — max 2-3 production files per task
- **Implementation details** — a short paragraph, not sub-sections. If you need sub-headers, split the task
- **Tests to write** — TDD: test describes behavior through public interface
- **Acceptance criteria** — max 3-4 verifiable checkboxes. More = task is too big
- **Standalone mergeable?** — Yes or No. If No, list the minimum companion tasks required for a mergeable unit

### 7. Self-Check: Apply Splitting Litmus Test

Before presenting to user, review EVERY task against section 5b litmus test. Split any task that fails.

**Especially watch for FE tasks that bundle:**
- Multiple UI components in one task (split by component)
- Store creation + UI wiring (split by layer)
- Multi-step flows (split by step)
- Form + validation + submission (split into form shell, validation, submit handler)

### 8. Present to User for Approval

Show:
- Milestone overview (each milestone = one MR)
- Task dependency graph with milestone boundaries
- Task overview table with **Standalone mergeable?** column
- Highlight: tracer bullet (T1), milestone boundaries, feature flag gates, companion task groups

**WAIT for user to approve.** User may request re-ordering, splitting, or merging. Update and get final approval.

## Quick Reference

| Constraint | Rule |
|-----------|------|
| **20 min max per task** | **THE key constraint. If bigger, split. No exceptions** |
| 1 task = 1 commit | Each task produces exactly one focused commit |
| T1 = tracer bullet | Always. E2E slice, trivial impl, proves architecture |
| Vertical slices | Each task touches all layers for one small capability |
| Milestone = MR | Each milestone is one independently mergeable MR |
| Standalone mergeable? | Annotate each task. If No, list minimum companion tasks |
| Max 2-3 prod files | Per task (excluding test files). More = too big |
| Max 3-4 AC checkboxes | Per task. More acceptance criteria = task is too big |
| Feature flags | Wire FF from T1. All partial work behind flags |
| Interfaces from spec | Tasks implement contracts defined in tech-spec |
| Fastest feedback first | Tracer → happy path → edges → polish |
| TDD ready | Each task's tests describe behavior through public API |

## Common Mistakes

- **Tasks too large** — bundling multiple concerns (e.g., "preview panel + impact banner"). Split by concern
- **Multi-step wizard as one task** — each wizard step should be its own task
- **Store + UI in one task** — split: create store → wire store to component
- **Form + validation + submit as one task** — split into form shell, validation logic, submit handler
- Starting with infrastructure/models instead of tracer bullet
- Horizontal slicing (all repos, then all services, then all UI)
- Tasks too vague for a coding agent — be specific
- Forgetting feature flags — partial work must be invisible to users
- Not annotating task mergeability — companion tasks must be explicit
- Creating tasks before tech-spec is approved

## Output

When complete: "Tasks approved. Next: run `omt-execute-task` to begin implementation."
