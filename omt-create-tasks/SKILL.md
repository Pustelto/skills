---
name: omt-create-tasks
description: Use when tech-spec is approved and needs task breakdown into vertical slices. Run after omt-create-tech-spec, before omt-execute-task. Creates tasks.md with tracer-bullet-first ordering
---

# Create Tasks

## Overview

Takes an approved `tech-spec.md` and `prd.md`, creates `tasks.md` with **small, granular tasks** following tracer-bullet and walking-skeleton approach. Tasks are grouped into MR-sized milestones that are independently mergeable. Requires explicit user approval before execution begins.

## When to Use

- Tech-spec is approved (check approval checkboxes in tech-spec.md)
- Before any coding starts
- **Not** when tech-spec is incomplete — run `omt-create-tech-spec` first
- **Not** for execution — run `omt-execute-task` after tasks are approved

## Key concepts

### Tracing bullet

Tracer bullet programming is a software development technique, introduced in The Pragmatic Programmer, where developers build a "skeletally thin" end-to-end slice of functionality to test architectural assumptions immediately. Unlike prototypes, tracer code is not intended to be thrown away; it is lean but permanent, allowing early integration, feedback, and validation of workflows.

#### Core Concepts of Tracer Bullets:

- Definition: Developing a direct, minimal path from the user interface through to the database to ensure the architecture holds up.
- Purpose: To gain immediate feedback on whether the code is hitting the intended "target" in terms of functionality and architecture.
- "Not Disposable": Unlike prototyping, which focuses on gathering intelligence (and is often thrown away), tracer code is designed to be part of the final application. Each subsequent task extends the skeleton.

#### Benefits of Tracer Bullet Development

- Early Feedback: Users see functionality early, and developers see how components interact immediately.
- Reduced Risk: Identifies architectural issues early, making it easier to adjust aim when the codebase is small.
- Reduced Bottlenecks: Enables development teams to move quickly without waiting for full specifications.
- Maintains Momentum: Provides a tangible "win" early in the development cycle.

### Learning tests

A "learning test" is a software development pattern where a developer writes automated tests to understand and explore a new API, library, or framework, rather than to test their own code. It acts as an executable documentation that verifies external code behaves as expected before integrating it into a larger project.

#### Key Aspects of Learning Tests

- Purpose: To gain understanding (learning) of unfamiliar software and confirm its behavior through experimentation.
- Process: Instead of reading documentation, you write tests that "poke and prod" the new tool.
- Benefits:
  - Validated Knowledge: Ensures you understand the API correctly.
  - Future Compatibility: If the library updates, your learning tests will fail, alerting you to changes.
  - Safety Net: Provides confidence when integrating new, complex dependencies.
- Example: When learning a new library to read JSON, you write a test creating a sample JSON string and assertion to verify it parses correctly.

#### Learning Tests vs. Unit Tests

While learning tests use the same tools as unit tests (e.g., JUnit, PyTest), their focus is on exploring external code, not validating internal code. They are usually not intented to be run in CI or used long-term.

#### Origin

The concept was popularized by Kent Beck in Test-Driven Development: By Example as part of the "Red bar patterns" to learn new technologies efficiently.

## Process to follow

1. Verify you have enough context and information to split the given task/feature to small units. If not ask user to do a refinement first
2. Check for "Architecture approved" in tech-spec.md. If not approved, stop.

### 3. Locate Feature Folder

Find the feature folder (in order):

1. `OMT_TASK_CONTEXT` env var → path to task folder
2. `.omt-context` file in repo root → read path from it
3. Ask user

### 4. Load Context

Read from feature folder:

- `prd.md` — requirements, acceptance criteria, scope
- `tech-spec.md` — architecture, interfaces, phases, feature flags

Extract key inputs:

- **Interfaces/contracts** from tech-spec (tasks implement these)
- **Phases** from implementation plan (map to milestones)
- **Feature flags** (tasks wire these from T1)
- **Module boundaries** (tasks respect these)
- **Acceptance criteria**

**Scope rule:** the work in `tasks.md` covers exactly what's in the PRD's acceptance criteria — no more, no less. There is no "v1 / v2 / quality phase" framing imposed by this skill. If something isn't required by the PRD, it doesn't appear in tasks. If a future iteration is needed, that's a separate PRD with its own task breakdown. Tasks-grouped-into-milestones is the only structure.

### 5. Design Task Breakdown

Apply these principles in order. Principles 0 (risk-first ordering) and A–B (spikes, tracer bullets) define **what each milestone is for**; principles C onward define **how each milestone is sliced**.

#### 0. Order milestones by risk, not by build-up. Integrations are usually the risk.

The single most important question at task-creation time: **what does this plan assume but not yet prove?** The early milestones exist to retire those assumptions. Every project has a build-up reflex — "first the foundation, then the walls, then the roof." That reflex is wrong when the foundation is well-trodden ground and the roof is the unknown. **Risk lives where uncertainty is highest, not where the dependency tree starts.** Schedule risk-first.

##### The practical heuristic: integrations are the risk

Don't run an elaborate risk inventory by default. The shortcut that catches most projects:

- **Integration with another system** (a service, a library you don't control, an external API, an auth provider, a database, a queue) — **high-risk**. This is where roadblocks live. Schedule first.
- **Infrastructure or dev tooling** (Docker, CI, deploy targets, environment-specific config like Spring profiles, secrets) — **high-risk**. Schedule first.
- **Feature implementation inside a single system** (UI flows, business logic, internal state, validation, formatting) — **usually low-risk**. Schedule after the integration unknowns are retired.

The exceptions to "feature implementation is low-risk" are real but rare: genuinely novel algorithms, hard performance constraints, unfamiliar UX patterns. Flag those explicitly when they appear; default-treat feature work as the cheap part.

When you see a milestone planning chart, ask: **how many integration boundaries does this milestone cross?** If the answer is "one or more, and at least one of those is new to the team or the project," that milestone is high-risk and belongs early. If the answer is "zero — it's all internal feature work," it can wait.

##### When you need a more careful inventory

The integration-first heuristic is enough most of the time. Use the explicit hypothesis-scoring fallback when:

- Two or more milestones each cross multiple integration boundaries — you need to choose which goes first.
- A milestone has no obvious integration boundary but still feels risky (novel algorithm, performance constraint, unproven UX assumption).
- Stakeholders disagree about ordering and you need an artifact to compare against.

The fallback method, in three steps:

1. **List each hypothesis** the plan assumes but doesn't prove. One line per hypothesis.
2. **Score each by `uncertainty × cost-of-being-wrong`.** Uncertainty = how confident is the team this works? (1 = trodden ground; 5 = genuinely unknown). Cost = how much rework if wrong? (1 = small refactor; 5 = invalidates the architecture).
3. **Order milestones to retire the high × high hypotheses first.** Each later milestone takes a known-working slice and extends it.

##### Distinguishing "biggest unknown" from "biggest scope"

Build-up scheduling sequences by **dependency** (what depends on what). Risk-first sequences by **uncertainty** (what's unknown). They're different axes. Volume of scaffolding is not the same as risk. Scaffolding is rarely the riskiest part of a project — it's just the most visible. The riskiest part is usually the integration where the system meets reality (auth, network, an external API, a real user flow).

##### Concrete worked example — an API-clone project got this wrong, here's the fix

Consider a project that builds a local **clone** of an upstream API (call it `api-clone`) so a backend service can talk to a controllable local stand-in during development. Its original milestones were:

- M1: First authenticated `getRule` test against the live upstream API
- M2: Show one captured rule via the clone end-to-end (in-process tests)
- M3: Serve all 3 queries from real captures
- M4: Connect the local backend and frontend to the clone
- M5+: Assignments, evaluation, real filters

This is build-up. M1 attacked one real unknown (live-upstream contract + auth) but a co-equal unknown — **"can the backend, running under its local profile, reach an HTTP service we control?"** — was deferred to M4. By M4, three milestones of work were committed on the assumption that the local-dev integration would work. When M4 ran, three independent failures fired simultaneously: (a) a stale Docker image silently served outdated stubs, (b) the backend's Kubernetes service-account token auth strategy couldn't read the SA token file on macOS, (c) local profile property overrides for the mock-upstream URL didn't take effect without a `--cmdline` arg. None of these were exercised before M4. Each individually was 1–4 hours to fix. Fixing them inside M4 meant unwinding assumptions baked into M2/M3.

**The integration boundaries inventory at project start should have been:**

| #   | Boundary                                                                                        | Type                         | Risk                                         |
| --- | ----------------------------------------------------------------------------------------------- | ---------------------------- | -------------------------------------------- |
| U1  | Clone ↔ live upstream API (auth + GraphQL contract)                                             | External integration         | High — first ever connection to that surface |
| U2  | Backend ↔ clone (local-dev wiring: profile config, network, outbound auth, Docker freshness)    | Infra + integration          | High — combines two risky categories         |
| U3  | Captured-response replay parity (wire-shape mismatch between live and clone)                     | Internal feature             | Medium                                       |
| U4  | Backend `upstream.enabled=true` side-effects                                                     | Infra-touching investigation | Medium                                       |
| U5  | Standalone frontend picker                                                                       | Internal feature             | Low                                          |

The integration-first heuristic flags U1 and U2 immediately as the high-risk items: both cross system boundaries the project has never touched. U3–U5 are progressively more "feature work in one system" and can wait. The corrected M1 retires both:

- **M1.T1.1**: Scaffold clone repo (unavoidable scaffolding).
- **M1.T1.2**: First authenticated `getRule` against the live upstream API (retires U1).
- **M1.T1.3**: **Hello-world clone deployed in Docker, returning a hardcoded `{"data": {"ruleNode": {...}}}` response. Backend wired via its local profile + property overrides. Click "Add rule" in the frontend and confirm the backend successfully fetches the stub.** (Retires U2 — the actual M4 disaster, surfaced in week 1 with a 30-line stub.)

M2+ then build on a known-working integration: capture a rule (M2), serve all queries (M3), refactor the frontend picker (M4), assignments (M5), evaluation (M6), filter parity (M7). Each milestone takes a slice known to work end-to-end and extends it.

**Net cost of doing this right: ~1 extra task in M1.** Net benefit: every later milestone runs on retired-risk foundations.

##### When build-up is acceptable

If a project has only one high-risk axis and the rest is well-trodden ground, build-up around that one axis is fine. The risk-first rule kicks in when there are two or more co-equal unknowns; the trap is letting one unknown dominate the schedule and pushing the others to the end.

#### A. Spikes for unknowns

If the tech-spec contains open `PENDING` questions or risks that block confident task design, prioritize a Slice 0 spike: 1–few small tasks with potentially disposable code that resolve assumptions before committing to the implementation shape. Spikes that don't produce running code MUST produce a written artifact (`findings.md`, decision note) so they're independently mergeable. Tools: _Tracer bullets_, _Learning tests_.

If there are no blocking unknowns, skip Slice 0.

#### B. The first slice closes the smallest possible end-to-end loop

The very first vertical slice should ideally be **one task** (two only if scaffolding is unavoidable) that closes the smallest possible end-to-end loop. Reason: if the first slice has 5 tasks, the architecture isn't validated until task 5 — that defeats the point of a tracer bullet. Fail-fast pressure compounds across the project; failing fast at task 1 is worth a lot.

**Bad first slice:** scaffold repo → add framework → add config → add types → add first endpoint (5 tasks before any signal).
**Good first slice:** scaffold + first endpoint that hits the real thing it's meant to integrate with (immediately answers "does the architecture work").

#### B.1. The tracer-bullet rule applies to EVERY new-integration milestone, not just M1

Principle 0 (risk-first ordering) tells you which milestones come first. Principle B.1 tells you what each integration milestone's first task is. They reinforce each other: the riskiest unknowns drive the earliest milestones, and within each integration milestone the first task is a thin end-to-end probe.

Whenever a milestone introduces a new external boundary — a new service-to-service hop, a new external API, a new infrastructure dependency, a new auth surface — the **first task of that milestone must be a thin end-to-end probe** of the integration. Not the implementation. Not preparatory config. The probe.

The probe can return a stubbed "hello world", an expected failure with a known status code, or an empty success — what matters is that it runs the full network/auth/serialization path. Polish (real handlers, full feature behavior, FE work) layers on after the integration is known-working.

**Why this matters more than principle B:** principle B is about the project's first slice (M1). B.1 is about every later milestone that introduces fresh integration risk. New integration risk doesn't only live at project start — it lives at every new wire-up point. Each one needs its own tracer bullet.

**How to spot a milestone that needs this rule:** ask "what new wire is this milestone activating for the first time?" If the answer names a service/API/auth surface that wasn't talking to ours before, the milestone needs an integration-probe first task.

**Concrete failure case (T4.5 in the api-clone project):**

M4 connected the backend (Spring Boot) to a new local clone (a small Node GraphQL server) via a local Spring profile. The original task split was:

- T4.1: Add the local profile config
- T4.2: Investigate `upstream.enabled=true` side-effects
- T4.3: Investigate two boot-time services' startup dependencies
- T4.4: Build the frontend rule-picker modal in the web app
- T4.5: Manual smoke — open the picker, see seeded rules

Each task was small and well-shaped individually. The architecture risk was concentrated at T4.5: did the backend's outbound auth work locally? Did the Docker image actually run current code? Did Spring profile property overrides resolve correctly? **All three had to work for T4.5 to demo.** None had been exercised before T4.5. When T4.5 ran, all three failed simultaneously and the milestone hit a wall after 4 tasks of preparatory work.

The correct shape was a tracer bullet first:

- **M4.0 (new): "Boot the backend with the local profile against the clone and confirm a single GraphQL request reaches the clone (any response — empty list, stub, even a known-status error)."** This would have surfaced (a) stale Docker image reuse, (b) Kubernetes SA token unavailability on macOS, (c) Spring profile property override quirk — all within 30–60 minutes, before any frontend work.
- M4.1+: T4.1 profile, T4.2/T4.3 investigations, T4.4 frontend — each layering on a known-working integration.

The price of skipping the M4.0 probe: 4 tasks of work (~10 hours) committed before the auth blocker surfaced, then a debugging detour, then folding the fix back into T4.5 retroactively. The probe would have been the cheapest task in the milestone.

**Concrete success case (M1 in the same project):** T1.2 ("run first authenticated `getRule` learning test against the live upstream API") was correctly designed as a tracer bullet — it integrated everything new (auth, GraphQL transport, response shape) in one task before any clone-side resolver work. M1 worked. The principle was applied to M1 but not propagated to M4.

**Apply this rule at task-creation time** by asking: "what new wire does this milestone activate? what's the cheapest end-to-end probe of it?" If you can't write that probe as the first task, the milestone is missing its tracer bullet.

#### C. Task sizing

**Each task MUST be a reasonably small but completable self-sufficient unit.** Focus on one specific concern. Move work forward in a size that allows progress, verification, and merge to main. Small enough to complete in a single agentic run without context compaction.

**1 task = 1 commit.** A task is the unit of work that produces exactly one focused commit.
**Task must be standalone mergeable** — main must not break after the commit lands.

**Splitting litmus test — if ANY of these are true, the task is too big:**

- More than 3–4 acceptance criteria
- Bundles two distinct concerns (e.g., "preview panel + impact banner" → split)
- Description needs sub-headers to explain different parts
- The Goal sentence is two sentences instead of one

**How to split large tasks:**

- **By UI concern:** "Add button + wire handler" is one task; "Add dialog content" is another
- **By data flow layer:** "Add GraphQL query + hook" is one task; "Wire hook into component" is another

#### D. Vertical slices, not horizontal layers

Each task should deliver a narrow but COMPLETE path through every layer it touches (schema, API, UI, tests). A completed slice is demoable or verifiable on its own. Prefer many thin vertical slices over a few thick horizontal ones.

**Horizontal-vs-vertical check (apply to each milestone before locking):** look at the tasks in the milestone. If they form a chain of layers (e.g., `lexer → parser → evaluator → wire-up`), that's horizontal — nothing is demoable until the last task. Re-slice into vertical tasks that each touch multiple layers and deliver a small slice of behavior. If the chain is unavoidable for a single piece of internal mechanism, fold the chain into a single task or push the whole mechanism into a later milestone where it becomes a vertical slice in its own right.

Hardcoded / trivial implementation behind the interfaces defined in the tech-spec is fine and expected (those stubs get replaced in a later task that has a behavior-driven reason to exist). Deploys behind a feature flag where applicable.

Example:

- ❌ Bad: do all UI work in one task, then API integration in another. (Horizontal — nothing works end-to-end until both land.)
- ✅ Good: wire one small UI element to the real API, end to end. Verify it works, learn lessons, then move to the next task.

#### E. Name tasks by behavior unlocked, not artifact produced

After drafting the task list, rename each task starting with a _user-visible verb_ describing what becomes possible after the task lands. **"Show one rule via clone"** beats **"Wire NodeSerializer to Query.rule resolver."** If you can't write a behavior-flavored name, the task is too internal — bundle it into a parent task (whose name describes the behavior the parent unlocks) or rephrase.

This catches infrastructure-only tasks that should be folded into the slice they enable. "Build auth module" is a smell. "Run first authenticated test against live API" is the actual goal — and naturally absorbs the auth module as part of the work.

#### F. Define jargon in the Goal

When a task title uses domain jargon (e.g., "DSL parser," "mock-mode override"), the **Goal sentence MUST define the jargon in one plain-language clause**. A reviewer should not need to read prior context to understand the task. If the Goal can't accommodate the definition without becoming two sentences, the task title is too dense — rename.

#### G. Order tasks by demo unlock, not completeness

When deciding whether a task lands in an early milestone or a later one, ask: **"If we don't ship this task, does the milestone's demo still happen?"** If yes, the task belongs in a later milestone — even if the early milestone's behavior is rough or partial. Tracer-bullet shipping prefers rough end-to-end working over polished partial working. The order is determined by what enables each demo, not by what feels "complete."

This is not a scope decision (everything in the PRD is in scope). It's an ordering decision.

#### H. Milestone grouping (= MR boundaries)

Group tasks into milestones. Each milestone = one mergeable MR. Each milestone:

- Is independently mergeable to main (with a feature flag if needed)
- Contains multiple small tasks that together form a functional increment
- Has clear acceptance criteria
- **MUST have a "Demo:" line stating in one sentence what becomes visible/demoable at the end of the milestone.** If the demo is "a passing test" or "infrastructure exists," the milestone is wrong — fold it into the next one or split into something that closes a loop. The first milestone is the only one allowed to demo "a passing first contract test" because that _is_ the tracer bullet.

#### I. One repo per milestone (HARD RULE)

**Each milestone targets exactly ONE repository (FE *or* BE). A milestone must never mix frontend and backend work.** This is a hard rule, not a preference — there is no escape hatch. If a milestone would touch both repos, split it.

Why this is non-negotiable:

- **It's how the work is actually run and merged.** Each milestone is one MR in one repo. The agent harness runs **one repo at a time** — a BE run only picks BE tasks, an FE run only picks FE tasks. A mixed milestone cannot be driven or merged cleanly by either.
- **The FE↔BE contract is the integration boundary — i.e. the risk** (Principle 0). Keeping repos in separate milestones forces the contract to be an explicit, testable hand-off instead of an implicit assumption. (A real shipped bug: an FE that queried fields a BE never served, because both lived in one "milestone" and nobody tested the seam end-to-end.)

How to split a cross-repo feature:

1. **BE contract milestone(s) come FIRST.** The backend serves the shared contract (REST/GraphQL schema, the interface the tech-spec defines) and proves it end-to-end through the real entry point. This is the tracer bullet for the integration boundary (Principle B.1).
2. **FE milestone(s) come AFTER and depend on the BE contract milestone** — list the BE milestone in "Depends On". The FE consumes the now-real contract.
3. **The contract itself is owned by the tech-spec** (its interface/owner tables). Tasks don't invent it; they implement against it. If the contract is unclear, that's a tech-spec gap — resolve it there first.
4. If a single task appears to need both repos, it is really **two tasks in two milestones** with the contract between them.

**Tag every milestone and every task with its repo (FE/BE).** This tag is load-bearing: it drives which tasks each repo's run picks. A milestone's repo is the repo all its tasks share.

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each milestone, show:

- **Repo:** FE or BE (one only — see principle I)
- **Demo:** what becomes visible/demoable at the end (one sentence)
- **Tasks** (numbered): each with a behavior-flavored title, mode (HITL/AFK), and blocked-by

For each task, show:

- Title (verb-led, behavior-flavored — see principle E)
- Repo: FE / BE (matches the milestone's repo)
- Mode: HITL (Human In The Loop) / AFK (Away From Keyboard)
- Blocked by: which other tasks (if any) must complete first
- PRD acceptance criteria covered: which line(s) of the PRD's acceptance criteria this task moves forward

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- **Is each milestone single-repo (FE or BE, never both)? Does each FE milestone depend on the BE milestone that serves its contract?** (principle I)
- Are dependency relationships correct?
- Should any tasks be merged or split further?
- Is each milestone's "Demo:" line genuinely demoable, or is it disguised infrastructure?
- Are HITL/AFK marks correct?
- Iterate until the user approves the breakdown.

### 6. Write tasks.md

If not existing:

- Read from the canonical template `../omt-scaffold-feature/templates/tasks.md` (owned by the `omt-scaffold-feature` skill)
- Replace placeholders (`{{FEATURE_NAME}}`, `{{JIRA_ID}}`, `{{STATUS}}`, `{{DATE}}`)
- Write `tasks.md` to feature folder

**Task Overview table — required columns:** `Task | Title | Milestone | Repo | Mode | Depends On | Status` (plus optional `Standalone?` and, after a Jira sync, `Jira`). `Repo` is `FE` or `BE` (the agent harness reads this column to decide which tasks a repo's run picks — get it right). `Mode` is `AFK` (autonomous) or `HITL` (needs a human). Use bare milestone labels (`M1`, `S2`).

For each task, include:

- **Repo** — `FE` or `BE` (must match the task's milestone repo — principle I)
- **Goal** (one sentence — if you need two sentences, the task is too big)
- **Feature flag** — how this task uses FF (wire new / extend existing / not needed)
- **Implementation details** — a short paragraph, not sub-sections. If you need sub-headers, split the task
- **Tests to write** — TDD: test describes behavior through public interface
- **Acceptance criteria (Definition of Done)** — max 3-4 verifiable checkboxes. This block is the contract the reviewer audits, so each criterion MUST be:
  - **Verifiable through the real entry point** the user/caller hits (HTTP/GraphQL resolver, CLI command, UI handler) — NOT an inner function called with a hand-built object. "Editing a reference shows impact via the `recordChangeImpact` resolver" beats "ModifyProducer returns the right subject."
  - **Backed by a check that actually RUNS** — "compiles", "type-checks", or a test that's written-but-skipped is NOT done. If a new type/case is added, it must be **constructed/reachable in production code**, not just in tests (no dead code).
  - **Named proof** — say what evidence proves it (e.g. "request+response transcript", "screenshot", "query result rows"). Unit tests alone rarely suffice; prefer integration/roundtrip evidence.
- **Deliverables** — the concrete artifacts this task produces (code paths touched, the evidence file under the run's `results/`, a migration, a doc). One line.
- **Dependencies on other tasks** - what tasks are needed to start working on this one, what tasks are blocked by this one. (FE tasks depend on the BE contract milestone — principle I.)

### 7. (Optional) Sync to Jira

After `tasks.md` is written and approved, **ask the user whether to sync the breakdown to Jira** (default: no). Only proceed on an explicit yes. If yes:

- Follow the **`using-jira-cli`** reference for all `jira` CLI usage (custom fields, strict priority names, multi-line description handling, the agent-vs-human create policy). Jira work is **best-effort and non-blocking** — a failure is logged and the run continues; never block task creation on Jira.
- **Parent epic** = the feature's `jira_id` (frontmatter). If it's `NO-TICKET`/missing, ask the user for the epic key (or whether to create one) before proceeding.
- **One Jira issue per milestone** (Story/Task), created under the feature epic. Tasks become **sub-tasks** of the milestone issue by default; if the user prefers, render them as a checklist inside the milestone description instead.
- **Each milestone issue MUST be self-contained** — an agent or human must be able to complete the milestone from Jira alone, without opening the vault. Embed in the description:
  - Milestone **Repo (FE/BE)**, Goal, and Demo line.
  - The **tech-spec context** this milestone needs: the interfaces/contracts it implements (copy the relevant rows from tech-spec §3.3), the integration boundaries it crosses (tech-spec §4), and its slice of the test strategy (tech-spec §5).
  - For **each task**: Goal, Files to modify/create, Implementation details, Tests to write, **Acceptance Criteria (Definition of Done)**, Deliverables, Dependencies — the same content as `tasks.md`. The Jira issue is a mirror, not a summary.
  - Keep the Acceptance Criteria under a clear `Acceptance Criteria` / `Definition of Done` heading so it stays machine-extractable if the harness later runs from Jira (jira-source mode).
- **Write keys back** into `tasks.md`: set frontmatter `jira_id` to the epic, record each milestone's issue key (in the Milestones table), and — if using sub-tasks — each task's sub-task key in the Task Overview (`Jira` column).
- **Idempotent:** before creating, search for an existing issue for this feature/milestone (a stable marker — the milestone label in the summary, or a label like `omt:<feature-slug>:<milestone>`). Update it instead of creating a duplicate.

## Common Mistakes

- **Tasks too large** — bundling multiple concerns (e.g., "preview panel + impact banner"). Split by concern.
- **Multi-step wizard as one task** — each wizard step should be its own task.
- **Store + UI in one task** — split: create store → wire store to component.
- **Form + validation + submit as one task** — split into form shell, validation logic, submit handler.
- **Starting with infrastructure/models** instead of tracer bullet. The first slice must close an end-to-end loop, not lay foundations.
- **Horizontal slicing** (all repos, then all services, then all UI) — re-slice into vertical paths through every layer.
- **Horizontal layer chains inside a milestone** (e.g., `lex → parse → eval → wire`) — nothing demos until the last task. Apply the horizontal-vs-vertical check (principle D).
- **Naming tasks by artifact, not behavior** — "Build NodeSerializer" is wrong; "Show one rule via clone" is right. Apply the rename test (principle E).
- **Imposing v1/v2 phasing the PRD didn't ask for** — scope is exactly what's in the PRD; tasks-grouped-into-milestones is the only structure. If something feels like "future quality work," check whether it's actually in PRD scope. If not, drop it. If yes, just order it to the right milestone.
- **A milestone whose "Demo:" reads "passing tests" or "infrastructure exists"** — except for the very first tracer-bullet milestone, milestones must demo a behavior. Re-slice or fold into the next milestone.
- **Five-task first slice** — fail-fast pressure dictates 1–2 tasks for the very first slice. Apply principle B.
- **No tracer bullet at the start of an integration milestone** — even if M1's tracer bullet was correct, every later milestone that introduces a new external boundary (new service hop, new auth surface, new infra dependency) needs its own tracer bullet as task 1. Apply principle B.1. Concentrating integration risk at the END of the milestone (e.g. via a "manual smoke" final task) means N-1 tasks of preparatory work before architecture is validated.
- **Build-up milestone ordering when there are co-equal unknowns** — sequencing milestones by the dependency tree ("foundation → walls → roof") feels natural but defers risk to the end. If two or more hypotheses are co-equal at high uncertainty × cost, schedule them as parallel-or-sequential probes in M1, not at opposite ends of the project. Apply principle 0. The api-clone example: the live-upstream contract (U1) AND backend-reaches-an-HTTP-service-we-control (U2) were both high-risk; only U1 was probed in M1, U2 was deferred to M4 and surfaced three independent failures simultaneously.
- **Confusing "biggest scope" with "biggest unknown"** — a milestone with a lot of scaffolding is not the same as a milestone with a lot of risk. Scaffolding is volume; uncertainty is the chance the design holds up under reality. Schedule by uncertainty, not by volume.
- **Jargon in task title with no plain-language definition in the Goal** — apply principle F.
- **Investigation tasks not producing an artifact** — spikes that don't run code must produce `findings.md` or a decision note so they're independently mergeable.
- **Tasks too vague for a coding agent** — be specific about files, behavior, verification.
- **Forgetting feature flags** — partial work landing on main must be invisible to users when applicable.
- **Not annotating task mergeability** — companion tasks (e.g., a feature-flag wiring + the behavior behind it) must be explicit about their merge order.
- **Mixed-repo milestone** — a milestone with both FE and BE tasks. Hard rule violation (principle I): split into a BE milestone (serves the contract, first) and an FE milestone (consumes it, depends on the BE one).
- **FE milestone not depending on its BE contract milestone** — the FE consumes a contract the BE must serve first. The FE milestone must list the BE contract milestone in "Depends On", or it'll be built against an unproven seam (the FE↔BE mismatch class).
- **Missing or wrong `Repo` tag** — every task and milestone needs `FE`/`BE`. The harness reads it to scope a run to one repo; a wrong/blank tag means a run picks the wrong tasks.
- **Weak acceptance criteria** — "tests pass" / "compiles" / a unit test on an inner function is NOT a Definition of Done. Each criterion must be verifiable through the real entry point, backed by a check that actually runs, with named proof (principle in step 6).
- **New code with no production caller** — a task that adds a type/case only constructed in tests ships dead code. The DoD must require it to be reachable in production.
- **Creating tasks before tech-spec is approved.**

## Output

When complete: "Tasks approved. Next: run `omt-execute-task` to begin implementation."
