---
name: omt-create-tech-spec
description: Use when PRD is approved and ready for technical planning. Step 3 of omt workflow — run after omt-start-prd, before omt-create-tasks. Creates tech-spec.md ONLY (no tasks)
---

# Create Tech Spec

## Overview

Spawns a Tech Lead agent that deeply investigates the codebase, devises multiple architectural approaches, gets user approval on the selected approach, then writes a detailed `tech-spec.md` with interfaces and contracts. Does NOT create tasks — that is a separate skill (`omt-create-tasks`) with its own approval gate.

## When to Use

- PRD is approved (check approval checkboxes in prd.md)
- Before any task breakdown or coding
- **Not** when PRD is incomplete — run `omt-start-prd` first
- **Not** for task creation — run `omt-create-tasks` after tech-spec is approved

## Process

### 1. Search Knowledge Base (Auto)

**Auto-invoke `/omt-knowledge-search`** — extract keywords from PRD, find relevant architecture patterns, standards, known friction. Present findings briefly. If `.memo/` doesn't exist: skip, note "Knowledge base not initialized."

### 2. Verify PRD Approved

Check for "Product Owner reviewed" in prd.md. If not approved, stop.

### 3. Create Tech-Spec from Template

If not existing:
- Read from `/Users/tomas.pustelnik/Developer/tasks-vault/_templates/tech-spec.md`
- Replace placeholders (`{{FEATURE_NAME}}`, `{{JIRA_ID}}`, `{{STATUS}}`, `{{DATE}}`)
- Write `tech-spec.md` to feature folder

### 4. Locate Feature Folder & Target Repository

Find the feature folder (in order):
1. `OMT_TASK_CONTEXT` env var → path to task folder
2. `.omt-context` file in repo root → read path from it
3. Ask user

Ask user for target repository if multiple repos.

### 5. Spawn Tech Lead Agent

Spawn via Agent tool: `subagent_type="general-purpose"`, `name="tech-lead"`
Pass: prd.md content, feature folder path, repo path, knowledge base findings.

Agent workflow has TWO phases with a user gate between them:

#### Phase A: Investigate & Compare Approaches

1. **Deep codebase exploration** — spawn multiple Explore agents in parallel:
   - Map current architecture (modules, boundaries, data flow)
   - Find existing patterns relevant to the feature
   - Identify files and interfaces that will be affected
   - Understand how similar features are built today

2. **Devise 2-4 approaches** — each must include:
   - Name and one-sentence summary
   - High-level architecture diagram (mermaid or ASCII)
   - Which existing patterns it reuses vs. invents
   - Pros/cons evaluated against these criteria:

| Criteria | What to Evaluate |
|----------|-----------------|
| Screaming architecture | Does the structure reveal domain intent? |
| Stability & maintainability | Long-term cost of change? |
| Testability & composability | Pure functions? Clear boundaries? Easy to mock? |
| Parallel dev feasibility | Can BE and FE work independently with contracts? |
| Simplicity | Boring code? Simple data flow? Readable? |
| Trade-offs | What doors does this approach close? |

3. **Present comparison to user** — brief table format with recommendation. **WAIT for user to pick an approach.** Do not proceed until user explicitly approves one.

#### Phase B: Write Detailed Tech-Spec

After user selects approach:

1. **Start with interfaces** — define contracts between modules:
   - API schemas (request/response types)
   - Module boundaries and public APIs
   - Data models and state shapes
   - Event contracts (if applicable)
   - Goal: enable TDD, enable parallel BE/FE dev with mocks, enable AI dev with clear contracts

2. **Write tech-spec.md sections:**
   - Executive summary (key changes table, estimated effort)
   - Problem analysis (current state with code flows, gap table)
   - High-level design:
     - Component overview (few large modules with clear APIs — not many small boxes)
     - **Interface & API definitions** (the contracts — source of truth for TDD and parallel dev)
     - **Data flow diagram** (mermaid or ASCII with numbered steps)
     - **UI flow diagram** (user journey through screens — skip if no UI)
   - **Trade-off analysis** (what doors this closes, what we gain)
   - Implementation plan (phases, files to modify/create — each phase independently shippable)
   - Alternatives considered (from Phase A comparison)
   - Questions & risks

3. **Present open questions** (`PENDING` status) — user resolves them

4. **Update spec** with resolved answers

5. **Get explicit user approval** on the complete tech-spec

## Quick Reference

| Constraint | Rule |
|-----------|------|
| Research first | Use Explore agents (parallel) before writing anything |
| Multiple approaches | 2-4 approaches with pros/cons — user picks before detailed spec |
| Interfaces first | Define contracts before implementation details |
| Diagrams required | Component overview + data flow minimum (mermaid/ASCII) |
| Few large modules | Deep modules with clear APIs, not many tiny boxes |
| Pattern reuse | Do NOT invent new patterns if existing ones work |
| Trade-offs explicit | State what doors each decision closes |
| Spec length | Digestible — enough for review, not exhaustive |
| Iterative Q&A | Write spec → present questions → user answers → update |
| YAGNI | Remove anything not strictly needed by PRD |

## Common Mistakes

- Writing spec without exploring codebase first (use Explore agents)
- Committing to one approach without presenting alternatives to user
- Skipping interface definitions — these enable TDD and parallel dev
- Missing diagrams — at minimum: component overview + data flow
- Making spec too long — should be reviewable by another senior engineer
- Defining implementation details before contracts
- Creating tasks in this skill (tasks are a SEPARATE skill with separate approval)

## Output

When complete: "Tech spec approved. Next: run `omt-create-tasks` to break work into tasks."
