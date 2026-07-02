---
name: omt-execute-task
description: Use when implementing a task. Step 4 of omt workflow — run after omt-create-tasks, loops until all tasks done, then omt-reflect
allowed-tools: Read, Edit, Grep, Glob, Bash(pnpm:*), Bash(pnpm nx:*), Bash(nx:*), Bash(playwright-cli:*)
hooks:
  Stop:
    - matcher: ""
      hooks:
        - type: command
          command: "bash ~/.claude/scripts/omt-task-complete-gate.sh"
---

# Execute Task

FIRST read `.omt-context` file in repo root → read path from it to get a full path to `tasks.md`

Execute ONE atomic task from `tasks.md` following a strict phased protocol. Task is NOT complete until ALL phases pass.

**Violating the letter of the rules is violating the spirit of the rules.**

## When to Use

- Implementing the next unchecked task from `tasks.md`
- PRD and tech-spec are complete
- **Not** for planning or spec work

## ALWAYS DO:

- **Write simple, boring code.** Pure functions, composition, immutability. If it's clever, simplify it. Not many small boxes — few large modules with good interface APIs. Screaming architecture: the folder structure should scream the domain, not the framework.
- **TDD is extremely strongly recommended** for all behavioral changes. Use the /tdd skill for logic, state, data transformations, and integration boundaries. For mechanical changes (prop threading, type renames, config wiring) where the type system is already the safety net, TDD may be skipped — but you MUST document WHY in the task summary. When in doubt, write the test.
- Always run tests and other code quality tools before commit. **No proof = no commit.** If you can't show evidence the task works, you don't commit.
- Always check the task specification and acceptance criteria in tasks.md file before considering it done and make sure they are all met.
- Always report finished task using correct template — the summary template in Phase 4 is **mandatory**.
- Create a new branch when starting to work on a new task
- Always update tasks.md file with tasks status changes
- Always write results to the project folder, see `Store Results` section below
- **Commit after each task** — one completed task = one atomic commit with proof

## ASK FIRST:

- Ask before modifying database schemas.
- Ask before adding new dependencies.
- Ask before changing CI/CD configuration.
- Ask before rebasing the branch
- Ask user if you have to make changes that are against specification (eg. you find out something can't be done in a way described there and you have to change it)

## NEVER DO:

- Never call a task done, until you: reviewed your work thoroughly, compared the changes to the acceptance criteria
- Never commit secrets or API keys.
- Never edit node_modules/ or vendor/.
- Never remove a failing test without explicit approval.
- Never commit secrets

## Phase 0: Load Task Context

**Do this FIRST, before anything else. Build a complete mental model before touching any code.**

1. **Find active task context** (in order):
   - `OMT_TASK_CONTEXT` env var → path to task folder
   - `.omt-context` file in repo root → read path from it
   - Ask user which task folder to use
2. **Read context files** from the task folder:
   - `prd.md` — requirements and acceptance criteria
   - `tech-spec.md` — architecture, patterns, feature flags, interfaces
   - `tasks.md` — find the next unchecked task
   - `implementation.md` — past task learnings, decisions, and carryover issues
3. **Review git history** — run `git log --oneline -20` to understand recent changes and what was done in previous tasks
4. **Review last completed task** — read the most recent `results/task-*-summary.md` to understand what was done, what was learned, and any carryover issues
5. **Extract from tech-spec** (remember for all phases):
   - Feature flags defined → you MUST use them
   - Architecture patterns / module boundaries → enforce them
   - Interfaces and contracts → implement against them
   - Dependencies between tasks

If task folder not found: ask user. If no tech-spec exists: warn and proceed with PRD only.

## Phase 0.5: Mark Task In Progress

Update `tasks.md` — set the current task's status to **In progress** in the Task Overview table.

## Phase 1: Architecture, Interfaces & Test Strategy

**Before writing ANY code or tests, understand the architecture AND plan how you will test and prove this works.**

1. **Read existing tests** for the area you are touching — understand patterns and structure
2. **Identify interfaces and boundaries** this task touches:
   - What public API / contract does this task implement or extend?
   - What are the inputs and outputs?
   - What module boundaries does this cross?
3. **Plan your testing strategy** — think through BEFORE writing anything:
   - What are the dependencies/coupling points and how that affect test? How to eliminate such things? (take inspiration from hexagonal/clean architecture - API, DB, File reading are all infrastructure and implementation details that should be hidden behind interface)
   - How will you prove this task works end-to-end once done?
   - What are the key behaviors to test (through public interfaces, NOT implementation details)?
   - What is the highest-value proof you can produce? (integration test > unit test > manual)
   - What edge cases matter? What can go wrong?
   - Design tests that verify behavior and contracts, not internal wiring — tests should survive refactoring
4. **Clean Architecture check:** Few large modules with clear APIs between them. If tech-spec defines architecture → verify current code aligns. If misaligned, plan alignment as part of this task
5. **Walking skeleton:** If this is the first task in a group, establish the minimal end-to-end vertical path first. Wire the interfaces and data flow before filling in logic. Prove the skeleton works with a trivial implementation
6. **Feature flags:** If tech-spec specifies FF for this feature, wrap ALL new behavior behind the flag from the start. Test both FF-on and FF-off states

### Test Value Assessment

Before planning tests, classify each file change:

| Change Type                                       | TDD?    | Rationale                                               |
| ------------------------------------------------- | ------- | ------------------------------------------------------- |
| New logic / behavior / calculations               | **YES** | Logic can break silently, compiler won't catch it       |
| Integration boundary / API contract               | **YES** | Contracts need runtime verification                     |
| User-facing interaction (click, navigate, submit) | **YES** | Behavior must be proven end-to-end                      |
| Prop threading / thin wrapper / container         | **NO**  | Type system enforces correctness                        |
| Static config (column defs, route paths)          | **NO**  | Only changes intentionally, compiler catches mismatches |
| Type / interface shape change                     | **NO**  | Compiler already guarantees this                        |

For changes spanning multiple files as one logical change → write ONE integration test that verifies the end-to-end behavior, not per-file unit tests.

**Output:** Clear mental model of interfaces, boundaries, data flow, where your code fits, AND how you will test and prove it works. For each area, state whether TDD applies and why.

## Phase 2: TDD Implementation

Use /tdd skill when TDD applies (see Test Value Assessment above). If all changes are mechanical/type-only, skip to Phase 3.

**The core loop. Vertical slices ONLY — NEVER horizontal layers.**

### Gate Table

| Step     | Gate         | Pass Criteria                                                |
| -------- | ------------ | ------------------------------------------------------------ |
| RED      | Failing test | Test describes behavior through public interface. Test FAILS |
| GREEN    | Minimal impl | ONLY enough code to pass the test. No anticipation           |
| REFACTOR | Clean up     | Extract duplication, deepen modules. Tests still green       |

### TDD Rules (When TDD Applies)

- **One test at a time.** RED → GREEN → REFACTOR → next test. Never batch
- **Vertical slices:** Each RED-GREEN-REFACTOR cycle delivers a working slice through the full feature depth. Never build an entire layer before moving to the next
- **Tracer bullet first:** The very first test proves the end-to-end path works — from input through interfaces to output (even with trivial/hardcoded implementation)
- **Start from API/interface:** Write tests against the public contract defined in Phase 1. Implementation details come last
- **Read existing tests** before writing new ones — follow established conventions
- **Feature flags:** If FF is active, test both FF-on and FF-off code paths
- **One integration test over many unit tests:** For changes spanning multiple files as one logical change, prefer one integration test that verifies the end-to-end behavior over per-file unit tests

### During Implementation — Record Refactoring Opportunities

When you spot suboptimal code, tech debt, or architectural friction:

- **Small refactor** (< 30 min, same files you are touching): handle it in the REFACTOR step of this MR
- **Large refactor** (different modules, risky, holistic): invoke `/omt-compound "[REFACTOR] <description of opportunity and suggested approach>"` — captured to `implementation.md` for future scheduled work (later migrated to `docs/` by `omt-reflect`)

## Phase 3: Verify & Prove

### 3a. Lint & Full Test Suite

Run `npm run lint` → zero errors. Run `npm test` → all tests pass, zero regressions.

### 3b. Prove It Works

> "Your job is to deliver code you have PROVEN to work."

**Paste the actual command AND its output.** Choose the BIGGEST scope proof possible:

| Proof Type                         | When to Use         |
| ---------------------------------- | ------------------- |
| Roundtrip integration test output  | API/backend changes |
| GQL request + response             | GraphQL changes     |
| Screenshot via chrome-devtools MCP | UI changes          |
| Video recording                    | Complex UI flows    |
| `curl` command + response          | REST API changes    |
| Unit test output with edge cases   | Pure logic changes  |

**NOT proof:** "Tests pass" (without output), "I tested manually" (without evidence), "Should work based on code" (no execution), happy path only (no edge cases).

### 3c. Self-Verification Against Spec

**Go through EVERY requirement explicitly:**

1. Re-read the task description from `tasks.md`
2. Re-read relevant acceptance criteria from `prd.md`
3. Re-read architecture constraints from `tech-spec.md`
4. For each requirement: confirm **MET** or flag **UNMET**
5. List any spec items not addressed (with reason: out of scope, deferred, blocked)
6. Verify the implementation fits the overall codebase architecture and quality standards

### 3d. Code Review

Use `omt-review-with-codex` (preferred) or Claude self-review against PRD + tech-spec. CRITICAL findings must be fixed before continuing.

## Phase 4: Summary & Results

### Summary Template

Once you finished all the work and all mandatory checks, reply EXACTLY in this format:

```
# Task Summary: <task ID> - <one-line description>

**Repo:** <repo name>
**Branch:** <branch name>

## What Changed
- <file>: <what and why>

## Key Struggles
- <what was hard and how it was resolved>

## Checks
- Linting: <pass/fail + tool>
- Tests: <X passed, Y failed + command> OR <N/A — reason why tests don't add value beyond type system>
- Nex tests: <number of new tests added in this task>
- Self-review against PRD: <requirement → MET/UNMET for each>
- Self-review against tech-spec: <pattern → FOLLOWED/DEVIATED + reason>
- Code review: <Codex/Claude — findings found, fixes applied>

## Spec Alignment
| Requirement | Status | Notes |
|-------------|--------|-------|
| <from prd/tech-spec> | MET/UNMET/PARTIAL | <details> |

## Deviations and changes from spec

- describe what changes and why?

## Refactoring
- Done in this MR: <small refactors performed>
- Recorded for future: <large refactors captured to implementation.md>

## Proof of Work
<actual command + output — BIGGEST scope proof>
<edge cases tested>
<screenshots/videos if applicable>

TASK: COMPLETE
```

**IMPORTANT:** Proof of Work section goes at the VERY END to survive context compacting.

### TASK: COMPLETE Signal

**`TASK: COMPLETE` MUST appear at the very end of your output message, ONLY when:**

- The entire task passed to this skill has been fully executed and finished
- All acceptance criteria are met
- Code quality tools have been run and passed (spotless/detekt, lint/type-check — whatever applies)
- Code review has been performed (sub-agent review or self-review)
- Proof of work exists (test output, quality check results, screenshots)
- Summary has been written using the exact template above
- Results have been stored and tasks.md updated

**If the task is NOT complete** (blocked, partially done, needs user input), do NOT output `TASK: COMPLETE`. Instead, explain what remains.

This signal is **mandatory** — every successful task execution ends with it. It is the machine-readable marker that the task is done.

### Store Results

**Always store to task vault folder** (the folder from Phase 0):

1. Create `results/` subfolder in task folder if not present
2. Save summary as `results/task-<ID>-summary.md`
3. Save proof assets as `results/task-<ID>-<description>.jpg|mp4|json`

### Mark Task Done

Update `tasks.md` — set the current task's status to **Done** in the Task Overview table. Mark the task heading with `COMPLETE` prefix.

### Next Action

State: "Next: Task X.Y ready" or "All tasks complete. Run `omt-reflect`."

## Commit & Branching

- **Commit after each task** — one completed task = one atomic commit with task ID in message
- **No proof = no commit.** If you can't show evidence the task works (test output, screenshots, passing quality checks), you do not commit
- Run code quality tools (spotless, detekt, lint, type-check — whatever applies) before every commit
- Keep MRs under ~1000 lines. If exceeded, split into stacked branches — each independently mergeable
- Feature flags to hide unfinished UI/logic. Partially shipped code behind FF is fine

## Red Flags — STOP and Fix

| Rationalization                      | Reality                                                                                     |
| ------------------------------------ | ------------------------------------------------------------------------------------------- |
| "Too simple to test first"           | If it has logic, test it. If it's pure wiring the compiler checks, skip it and document why |
| "Let me build the whole layer first" | Vertical slices. Always. Never horizontal layers                                            |
| "I'll figure out testing as I go"    | Plan test strategy BEFORE coding. What you test and how you prove it matters                |
| "I'll define the interface later"    | Interfaces first. Always                                                                    |
| "I'll add proof later"               | Later never comes. Prove it now                                                             |
| "Tests pass so it works"             | Tests passing ≠ feature working. Prove end-to-end                                           |
| "Review slows me down"               | Review catches bugs that slow you down more                                                 |
| "Small refactor can wait"            | If it's in your files and < 30 min, do it now                                               |
| "No need to check spec again"        | Self-verify against spec. Every single time                                                 |
| "Feature flag is overkill here"      | If tech-spec says FF, use FF. No exceptions                                                 |

## Failure Handling

If ANY step fails: fix the issue, re-run that step. Do NOT proceed until it passes. Do NOT mark complete.

If stuck on same error 2-3 times: **STOP.** Summarize state clearly. Ask user how to proceed.
