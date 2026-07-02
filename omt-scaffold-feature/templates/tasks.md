---
feature: {{FEATURE_NAME}}
jira_id: {{JIRA_ID}}
status: {{STATUS}}
created: {{DATE}}
type: tasks
prd_reference: prd.md
tech_spec_reference: tech-spec.md
---

# Tasks: {{FEATURE_NAME}}

**Tech spec:** `tech-spec.md`
**PRD:** `prd.md`

---

## General Requirements (apply to EVERY task)

> **Write simple, boring code.** Easy to read, easy to review, easy to change. No surprises, no clever tricks, no hidden side effects. If a junior developer can't understand it in 30 seconds, simplify it.

### Coding Principles

- **Immutability** — never mutate objects or arrays. Always create new copies
- **Pure functions & composition** — extract logic into pure functions. Compose them
- **No hidden side effects** — a reader should trace every value without jumping across files
- **Easy to test** — inject dependencies, extract pure functions, keep components thin
- **Clean architecture** — separate business logic from UI and infrastructure
- **Screaming architecture** — folder structure screams the domain, not the framework

### Branching & Delivery

- **Small MRs** — max ~1000 lines per branch. Split into stacked branches if larger
- **Stacked branches** — each independently mergeable to main without breaking production
- **Feature flags** — hide unfinished UI and logic. Partially shipped code behind FF is fine

### Workflow

1. **Read context first** — before starting any task, read tech-spec for interfaces/contracts and check `.memo/_scratch.md` for learnings from previous tasks
2. **Commit often** — small, focused commits
3. **Use TDD (Red → Green → Refactor)** — write test first, see it fail, implement to pass, clean up
4. **Prove your changes work** — verify it compiles and tests pass. Actually run the check
5. **Review your own code** — re-read every changed file. Check: unused imports, missing null handling, pattern inconsistency
6. **Run full check before completion** — test suite, zero failures

### Completion Protocol

When a task is fully done (code committed, tests passing, self-reviewed):

1. **Mark the task title with COMPLETE prefix** — `## T1: ...` → `## COMPLETE T1: ...`
2. **Capture learnings** via `/omt-compound` (patterns, friction, refactoring opportunities)

---

## Milestones

_Each milestone = one independently mergeable MR. Each task ≤20 min, 1 task = 1 commit._

| Milestone | Repo | Tasks | Goal | Mergeable? |
|-----------|------|-------|------|------------|
| M1: Tracer Bullet | BE | T1 | End-to-end skeleton proving architecture | Yes (behind FF) |
| M2: _name_ | BE | T2, T3, T4 | _functional increment_ | Yes (behind FF) |
| M3: _name_ | FE | T5, T6, T7 | _functional increment_ | Yes (FF removal) |

### Constraints

- **One repo per milestone (HARD RULE)** — each milestone is FE *or* BE, never both. A cross-repo feature splits into BE milestone(s) that serve the contract (first) and FE milestone(s) that consume it (depend on the BE one). The agent harness runs one repo at a time and reads the `Repo` column to pick tasks.
- **20-min max** per task (including tests). 1 task = 1 commit
- **Feature flags** for all partial work — invisible to users until ready
- **Each milestone works on main** — no broken intermediate states
- **Standalone?** column in task overview marks which tasks are independently mergeable vs. need companions

---

## Task Dependency Graph

```
┌─── M1: Tracer Bullet ───┐
│ T1 (e2e skeleton)        │
└──────────┬───────────────┘
           │
┌─── M2: Core ────────────┐
│ T2 ──→ T3               │
└──────────┬───────────────┘
           │
┌─── M3: Polish ──────────┐
│ T4 ──→ T5               │
└──────────────────────────┘
```

## Task Overview

> **`Repo`** (FE/BE) is read by the agent harness to scope a run to one repository — every row needs it, and it must match the row's milestone repo. **`Mode`** is `AFK` (autonomous) or `HITL` (needs a human). The `Jira` column is filled only if the breakdown is synced to Jira.

| Task | Title           | Milestone | Repo | Mode | Depends On | Standalone? | Status      | Jira |
| ---- | --------------- | --------- | ---- | ---- | ---------- | ----------- | ----------- | ---- |
| T1   | _tracer bullet_ | M1        | BE   | AFK  | —          | Yes         | In progress | —    |
| T2   | _title_         | M2        | BE   | AFK  | T1         | No (T2+T3)  | Pending     | —    |
| T3   | _title_         | M2        | BE   | HITL | T2         | No (T2+T3)  | Pending     | —    |

---

## T1: Tracer Bullet — [End-to-End Slice Description]

> **This is always the first task.** Wire the full vertical path with trivial/hardcoded implementation. Proves the architecture works end-to-end behind a feature flag.

**Repo:** _BE | FE_ (matches the milestone repo)

### Goal

_One sentence: what end-to-end path this proves._

### Interfaces Implemented

_Which contracts from tech-spec.md this task wires up (even with stub/trivial impl)._

### Feature Flag

- Flag name: `FF_<feature_name>`
- Default: `off`
- Wrap: _what is behind the flag_

### Files to Modify

- `path/to/existing/file.ext` — _what changes and why_

### Files to Create

- `path/to/new/file.ext` — _purpose_
- `path/to/new/file.test.ext` — _tests for above_

### Implementation Details

_Specific instructions: what code to write, patterns to follow, references to existing code._

### Tests to Write

- _Test 1: description of what to assert (through public interface)_
- _Test 2: edge case_

### Acceptance Criteria (Definition of Done)

> Each criterion: verifiable **through the real entry point** (name it), backed by a check that **actually runs** (not just compiles), with **named proof**. New code must be reachable in production, not only in tests.

- [ ] _End-to-end path runs through the real entry point `<name it>` (trivial impl OK)_
- [ ] _Feature flag gates the new behavior — verified on + off_
- [ ] _The proving check actually ran (not just compiled); proof captured_
- [ ] _No regressions_

### Deliverables

- _Code: `<paths touched>`_
- _Evidence: `<proof artifact — test transcript / screenshot / query result>` under the run's `results/`_

---

## T2: [Next Task Title]

**Repo:** _BE | FE_ (matches the milestone repo)

### Goal

_One sentence: what this task achieves._

### Interfaces Implemented

_Which contracts from tech-spec.md this task implements or extends._

### Feature Flag

_How this task uses the feature flag. "Extends existing FF" or "No new FF needed"._

### Files to Modify

- `path/to/existing/file.ext` — _what changes and why_

### Files to Create

- `path/to/new/file.ext` — _purpose_
- `path/to/new/file.test.ext` — _tests for above_

### Implementation Details

_Specific instructions for a coding agent in one context window._

### Tests to Write

- _Test 1: description of what to assert_
- _Test 2: edge case_

### Acceptance Criteria (Definition of Done)

> Each criterion: verifiable **through the real entry point** (name it), backed by a check that **actually runs**, with **named proof**. New code must be reachable in production, not only in tests.

- [ ] _Specific verifiable outcome through the real entry point `<name it>`_
- [ ] _The proving check actually ran; proof captured_
- [ ] _No regressions_

### Deliverables

- _Code: `<paths touched>`_
- _Evidence: `<proof artifact>` under the run's `results/`_

---

## Completion Checklist

- [ ] All tasks marked COMPLETE
- [ ] All milestones independently mergeable
- [ ] All tests passing
- [ ] Feature flag tested (on + off)
- [ ] Learnings captured via `/omt-compound`
- [ ] Code reviewed
- [ ] PRD success metrics verified

---

**Next step:** After all tasks complete → Run `omt-reflect` to capture learnings
