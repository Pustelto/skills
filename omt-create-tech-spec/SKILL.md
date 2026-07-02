---
name: omt-create-tech-spec
description: Use when PRD is approved (or session has enough technical context) and you need a tech-spec written. Step 3 of omt workflow — run after omt-start-prd, before omt-create-tasks. Creates tech-spec.md ONLY (no tasks).
---

# Create Tech Spec

## Overview

Acts as a **Senior Staff Engineer** with years of experience building scalable, production-ready systems. Gathers context (codebase + selectively the web), thinks hard about multiple solutions weighed for long-term maintainability and reversibility, leads a free-form dialog with the user to converge on a design, and writes a `tech-spec.md` with interfaces, data flow, integration boundaries, and a testing strategy.

This skill **runs in the main thread** — the conversation with the user happens here directly. Subagents are dispatched **only for parallel research bursts**, never for the dialog or the final write.

## When to Use

- PRD is approved (preferred entry point)
- OR session has accumulated enough technical context that a refinement makes sense without a PRD (escape hatch — see Step 0)
- Before any task breakdown or coding
- **Not** for task creation — run `omt-create-tasks` after the spec is approved

## Mindset

- **Senior staff engineer**, not transcriber. Don't take the first idea that comes to mind. Hold multiple options in your head, weigh them, then propose.
- **Long-term maintainability is the prize.** Code lives in production for years; the spec optimizes for that horizon.
- **Reversibility is a property of the design.** Note explicitly which decisions close doors and which keep them open.
- **Push back when warranted.** The user is not always right; if their preference contradicts evidence (codebase patterns, integration risk, tested industry approach), defend your position with that evidence. Don't agree just because the user pushed.
- **Architectural defaults** live in `arch-defaults.md` (next to this skill). Read them. Apply unless the codebase has an established conflicting convention — pattern reuse beats purity.
- **Free-form dialog only.** Do **NOT** use the `AskUserQuestion` tool in this skill. Chat naturally — that's how senior engineers refine designs together.

## Important principles to always keep in mind

- Record all technical decisions with details, all considered options and pros and cons so we can later translate those decision to ADRs in the repository to capture the architecture evolution and reasoning behind it.
- Hard problems and unknowns are always solved first.

## Process

### 0. Verify Context & Locate Folders

**PRD check:**

1. Read `prd.md` in the feature folder
2. Look for "Product Owner reviewed" / approval checkboxes
3. If PRD is missing or not approved:
   - **Tell the user** clearly: "PRD is not approved. Recommended path: run `/omt-start-prd` first."
   - If the user persists ("proceed anyway", "skip PRD"), continue. Gather extra context from the session conversation, recent files touched, and the user directly. Note in the eventual spec that it was written without an approved PRD so future readers know.

**Locate feature folder** (in order):

1. `OMT_TASK_CONTEXT` env var → path to task folder
2. `.omt-context` file in repo root → read path from it
3. Ask user

**Locate target repository.** If multi-repo, ask which repo and confirm whether other repos are in scope (cross-repo dependencies are first-class — see Step 2).

### 1. Clarify If Needed (free-form)

If the PRD or session context is insufficient for technical refinement, **stop and ask**. Examples of insufficient context:

- Acceptance criteria is missing or ambiguous
- Non-functional requirements (perf, scale, latency, security) absent but obviously matter
- Scope boundary unclear (what's in vs. out)
- Stakeholder constraints unstated (deadlines, regulatory, team capacity)
- Integration points named but undefined (which auth, which transport, which data shape)

Ask **one focused question at a time** in plain prose. Do NOT use `AskUserQuestion`. If everything is clear, skip this step and move on.

### 2. Codebase Research (parallel subagents)

Dispatch in **parallel** via the Agent tool — one message, multiple tool calls. Use these specialized agents. Their definitions are **bundled with this skill** in `agents/` (next to this `SKILL.md`); they are also installed globally under `~/.claude/agents/`. If a `subagent_type` below isn't registered in your environment, install the bundled copy into your agents directory first.

| Agent                     | Purpose                        | Prompt focus                                      |
| ------------------------- | ------------------------------ | ------------------------------------------------- |
| `codebase-locator`        | Where does relevant code live? | Files, directories, modules touching this feature |
| `codebase-analyzer`       | How do current systems work?   | Trace data flow, list entry points with file:line |
| `codebase-pattern-finder` | What similar things exist?     | Concrete examples of related implementations      |

**Goals of this research:**

- **Reuse opportunities** — what's already built that we should call into?
- **Placement** — where does this new code most naturally belong? (best place ≠ shortest path)
- **Risks & incompatibilities** — what existing assumptions might this break?
- **Conventions** — naming, structure, error handling, testing patterns the codebase already uses
- **Cross-repo dependencies** — if the feature spans repos, list every cross-repo touchpoint. If you don't have access to a needed repo, **ask the user for it** before continuing — don't guess at the contract.

Spawn 2–4 agents in parallel based on what's needed. Wait for all to complete before synthesizing.

### 3. Web Research (CONDITIONAL, parallel subagents)

**Trigger web research when one or more is true:**

- The problem is a **common-domain pattern** with established industry solutions:
  permissions/RBAC, authentication flows, API design (rate limiting, pagination, idempotency), caching, distributed transactions, multi-tenancy, eventing, framework-specific patterns (state management, routing, ORM idioms), search/indexing, queueing, observability, performance for known categories
- Working with a specific library/framework where conventions matter and getting it wrong has compounding cost
- The user or PRD explicitly asks for it
- You're about to introduce a novel pattern — sanity-check via "is this already a solved problem?"

**When to skip:** small internal feature with no fresh integration, well-trodden code path, minor enhancement to existing module.

If you decide to research, dispatch **multiple `web-search-researcher` agents in parallel** (this agent is also bundled in `agents/` next to this skill) — each on a focused angle (one for "how does framework X recommend doing Y", one for "industry approaches to Z", one for "comparable apps that solve this"). Goal: don't reinvent the wheel, don't invent in-house abstractions when industry has a name for it.

### 4. Solution Analysis (in main thread, no subagent)

With all context gathered, you (the senior staff engineer) think.

**Generate 2–4 candidate approaches.** For each:

- One-sentence summary
- High-level shape (component boundaries, data flow)
- Which existing codebase patterns it reuses vs. invents
- Long-term maintainability profile
- **Reversibility:** what doors does this close? what doors does it open later?
- Testability profile (where seams go, what test level fits each concern)
- Trade-offs

**Apply `arch-defaults.md`.** Override only when codebase conventions point another way; when overriding, note the deviation and reason.

**Build the Integration Boundary Inventory.** List every new wire the design activates:

- Service-to-service hops
- External APIs / third-party integrations
- Auth surfaces
- Database / queue / cache / search-index dependencies
- Cross-repo touchpoints (mark these explicitly)
- Local-dev wiring (Docker freshness, profile config, secret loading) — yes, local-dev counts; if `M4` of the api-clone example (below) taught us anything, it's that local integration boundaries hide three failures at once

For each, score risk = uncertainty × cost-of-being-wrong. High-risk boundaries become tracer-bullet candidates that the tasks skill (omt-create-tasks Principle 0/B/B.1) will schedule first.

**Plan the testing strategy.** For each interface in the chosen approach:

- What behaviors must be verified
- What test level is the highest-value choice (don't push everything to e2e; don't unit-test what only matters at integration)
- What infrastructure the tests need (fixtures, fakes, real services in containers, test accounts)
- **Trace every PRD acceptance criterion to at least one behavior verified through the real entry point** (HTTP/GraphQL resolver, CLI, UI handler) — not an inner unit called with a hand-built object. This mapping is what the downstream Definition of Done (`omt-create-tasks`) and the reviewer's criterion→test coverage check rely on; a criterion with no entry-point test is a gap to flag now, not later.

(Repo/FE-BE structure is **not** a tech-spec concern — the spec defines interfaces and owners; how work is sliced into FE vs BE milestones is decided in `omt-create-tasks`.)

Now pick the approach you'd recommend. Be ready to defend it.

### 5. Quiz the User (free-form, NO AskUserQuestion)

Lead the conversation in **two passes**.

**Pass 1 — High-level shape.** Present the recommended solution:

- Component overview diagram (mermaid or ASCII)
- Data flow diagram with numbered steps
- One paragraph on why this approach over the others
- Brief mention of the rejected alternatives (one line each — full pros/cons stays in the eventual spec)

Then ask the user, in your own words, whether the shape feels right. Open invitation: "before I drill into details, does this overall shape make sense, or do you want to start somewhere else?"

**Pass 2 — Piece-by-piece dialog.** Walk the user through these areas one at a time. Don't dump them all at once. Lead the conversation:

1. **Touched modules and system boundaries** — which modules change, which stay, where the new code goes
2. **Test scenarios and types of tests** — what we'll test, at what level, what we need to deliver those tests
3. **Interfaces and API shape** — request/response, internal contracts, data models
4. **Data flow** — through the system, including error paths
5. **Edge cases** — what's not the happy path
6. **Domain validations / assertions** — what invariants the domain holds, where they're enforced
7. **Trade-offs** — what doors close, what we gain
8. **Integration boundary inventory** — confirm the high-risk wires that the tasks skill will schedule first

**Push back when warranted.** If the user proposes something that contradicts evidence — codebase patterns, integration risk, established industry approach, the architectural defaults — say so and defend with evidence. Don't agree just because they pushed. The senior staff engineer's job here includes saying "I think we should do X, here's why" and meaning it. If the user has a reason you didn't see, update your view; if they don't, hold the line.

Iterate until the user agrees on the shape, **explicitly**.

### 6. Write `tech-spec.md`

Only after the user agrees:

1. If `tech-spec.md` doesn't exist: copy from the canonical template `../omt-scaffold-feature/templates/tech-spec.md` (owned by the `omt-scaffold-feature` skill), replace placeholders (`{{FEATURE_NAME}}`, `{{JIRA_ID}}`, `{{STATUS}}`, `{{DATE}}`)
2. Fill in the sections per the dialog. The template includes Testing Strategy and Integration Boundary Inventory sections — populate both.
3. **Cross-repo dependencies** in the integration boundary inventory must be flagged (separate "Cross-repo?" column).
4. Mark Q&R items as `PENDING` or `RESOLVED` based on what was decided.
5. Present the spec summary, ask the user to read and tick the approval checkboxes.

## Quick Reference

| Constraint                     | Rule                                                                             |
| ------------------------------ | -------------------------------------------------------------------------------- |
| Where does the skill run       | Main thread — subagents only for research bursts                                 |
| User-facing tool for questions | Free-form chat — **never** `AskUserQuestion`                                     |
| Codebase research              | `codebase-locator` + `codebase-analyzer` + `codebase-pattern-finder` in parallel |
| Web research                   | `web-search-researcher` (parallel angles) — only when triggered                  |
| Architectural defaults         | `arch-defaults.md` — codebase conventions override                               |
| Senior mindset                 | Multiple approaches; reversibility weighed; push back with evidence              |
| Spec contains                  | Testing Strategy + Integration Boundary Inventory (with cross-repo flag)         |
| Interfaces first               | Define contracts before implementation details                                   |
| Diagrams                       | Component overview + data flow at minimum (mermaid/ASCII)                        |
| Few large modules              | Deep modules with clear APIs over many tiny boxes                                |
| Pattern reuse                  | Don't invent new patterns when existing ones work                                |
| Trade-offs explicit            | Document doors closed and doors opened                                           |
| Spec length                    | Reviewable by another senior — not exhaustive                                    |
| YAGNI                          | Remove anything not strictly needed by PRD                                       |
| User gate                      | Explicit agreement on shape before writing the spec                              |

## Worked failure example — what an Integration Boundary Inventory catches

Consider a project that clones an upstream API for local dev (the api-clone example). Its tech-spec did not list "backend ↔ clone local-dev wiring (Spring profile config, network, outbound auth, Docker image freshness)" as an integration boundary. It looked like internal config work. The tasks skill scheduled this milestone (M4) by build-up dependency order, putting it after three milestones of internal feature work.

When M4 ran, three independent failures fired at once:

- a stale Docker image silently served outdated stubs
- the backend's Kubernetes SA-token auth strategy couldn't read the token file on macOS
- Spring profile property overrides for the mock URL didn't take effect without a `--cmdline` arg

Each was 1–4 hours individually. Hitting all three simultaneously, after three milestones of work had been built on the assumption that the local integration would just work, meant a debugging detour and rework folded back into the milestone.

If the tech-spec had listed this as a boundary with a "High" risk score, the tasks skill (Principle 0 / B.1) would have scheduled an M1 tracer bullet — a 30-line stub clone, backend wired, click "Add rule" in the frontend, confirm one GraphQL request reaches the clone — and surfaced all three failures within an hour, before any feature work was committed.

**Lesson for tech-spec authors:** integration boundaries are not just production-cluster service-to-service hops. They include local-dev wiring, profile config, container freshness, secrets-loading paths, and cross-repo schema dependencies. If the wire has never been exercised before, it is an integration boundary. List it.

## Common Mistakes

- **Spawning a single subagent for the whole skill** — kills dialog quality. Main thread leads; subagents for research only.
- **Using `AskUserQuestion` for the quiz** — turns refinement into a form. Use free-form chat.
- **Skipping codebase research and going straight to design** — every spec written this way reinvents existing patterns or misses constraints. Always research first.
- **Inventing patterns the codebase doesn't use** — "purity over pattern reuse" creates friction and surprises future readers. Override `arch-defaults.md` when the codebase has its own answer.
- **Web-research-by-default for every spec** — research is for genuinely common-domain or framework-specific problems. A small internal enhancement doesn't need it.
- **Missing the Integration Boundary Inventory** — see the api-clone failure above. Every new wire (service hop, auth surface, infra dep, cross-repo, local-dev wiring) goes in the inventory with a risk score.
- **Treating local-dev wiring as "config, not integration"** — it's an integration boundary. List it.
- **Skipping cross-repo dependencies** — if the feature spans repos, every touchpoint is a contract that needs flagging. Ask for repo access before guessing the contract.
- **Implementation details before contracts** — define interfaces (request/response, module boundaries, data shapes) before writing how they'll be implemented.
- **Skipping the testing strategy section** — if the spec doesn't say how this will be tested, the executing agent will guess (poorly). Behavior-level test cases per interface, before implementation.
- **Over-decomposition into many small modules** — few large modules with clear APIs are easier to maintain than many tiny boxes. Resist breaking things up just because you can.
- **Spec too long** — should be reviewable in a sitting by another senior engineer. Cut anything not load-bearing.
- **Agreeing with the user when they're wrong** — the senior staff engineer holds the line when evidence supports it. Don't say yes just because they pushed.
- **Creating tasks in this skill** — tasks are a separate skill (`omt-create-tasks`) with its own approval gate.

## Output

When complete: "Tech spec approved. Next: run `omt-create-tasks` to break work into tasks."
