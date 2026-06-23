---
name: omt-fix-bug
description: Use when fixing a bug from a Jira ticket or bug description. Alternative entry to omt workflow — condenses investigation, planning, and execution into one flow. Then omt-reflect.
hooks:
  Stop:
    - matcher: ""
      hooks:
        - type: command
          command: "bash ~/.claude/scripts/omt-task-complete-gate.sh"
---

# Fix Bug

## Overview

Investigate a bug, identify root cause with confidence scoring, create a condensed fix plan, and execute it with mandatory regression tests and proof. Replaces the full scaffold → PRD → tech-spec → tasks chain for bug fixes.

> **Write simple, boring code.** The fix should be minimal, focused, and easy to review. No refactoring side-quests.

## When to Use

- Fixing a bug (Jira ticket, bug report, or verbal description)
- Issue has a clear "it used to work / it should work but doesn't" nature
- **Not** for new features — use `omt-scaffold-feature` instead
- **Not** for refactoring — unless the refactor IS the fix

## Phase 1: Gather Information

1. **Get the bug report** — ask user for Jira ticket ID or description
2. **If Jira ticket**: pull ticket details (summary, description, steps to reproduce, expected vs actual behavior, environment, priority)
3. **If description**: ask user for:
   - Steps to reproduce
   - Expected behavior vs actual behavior
   - When it started (recent change? always broken?)
   - Severity / impact
4. **Document** what you know and what's missing

## Phase 2: Investigate Root Cause

**Follow CLAUDE.md debugging rules: identify root cause FIRST, don't fix based on assumptions.**

1. **Explore the codebase** — use Grep/Glob to find relevant code. Read full files, not just matches. Trace the data flow end-to-end
2. **Reproduce mentally** — walk through the code path that the bug follows. Where does it break?
3. **Identify root cause** with confidence level:

| Confidence | Meaning | Action |
|-----------|---------|--------|
| 1-2 | Guessing | Keep investigating. Do NOT propose a fix |
| 3 | Likely but not certain | Present findings, ask user to validate |
| 4-5 | Confident / certain | Propose fix |

4. **If confidence < 4**: continue investigation. Use MECE framework to eliminate possibilities systematically. Check recent git changes, related bugs, similar patterns
5. **Present root cause analysis** to user:

```
## Root Cause Analysis

**Bug:** [one-line description]
**Confidence:** [1-5] — [reasoning for this score]

**Root cause:** [clear explanation of what's wrong and why]

**Evidence:**
- [file:line — what's happening here]
- [file:line — how this causes the bug]

**Questions:**
| # | Question | Status |
|---|----------|--------|
| Q1 | [any uncertainties] | PENDING |

**Assumptions:**
| # | Assumption | Risk if wrong |
|---|-----------|---------------|
| A1 | [what you assumed] | [impact] |
```

## Phase 3: Plan the Fix

Once root cause is confirmed (confidence 4+), create a condensed fix plan:

```
## Fix Plan

**Approach:** [1-2 sentences — what will change and why]

**Regression test (RED):**
- File: `path/to/test.ext`
- What to assert: [the broken behavior that should start passing]
- Test type: [unit / integration / e2e]

**Fix:**
- File: `path/to/file.ext` — [what changes]
- [additional files if needed]

**Verification:**
- [ ] Regression test fails before fix (RED)
- [ ] Regression test passes after fix (GREEN)
- [ ] All existing tests still pass
- [ ] [FE only] Visual proof via `/verify-in-browser` bugfix mode
```

**Get user approval before executing.**

## Phase 4: Execute the Fix

Follow TDD strictly — this is non-negotiable for bug fixes:

### Step 1: Write Regression Test (RED)

Create a test that **captures the bug**. Run it. It MUST fail.

- **Backend**: unit or integration test that reproduces the broken behavior
- **Frontend**: prefer integration test (render component, trigger the bug scenario, assert the wrong behavior). If e2e needed, create a focused test that captures the user flow

**Paste the failing test output.** If the test passes before the fix, the test is wrong.

### Step 2: Fix the Bug (GREEN)

Implement the minimal fix. Run the regression test. It MUST pass now.

- Don't refactor while fixing — fix first, refactor later (if at all)
- Don't fix adjacent issues — one bug per fix

### Step 3: Verify No Regressions

Run the full test suite. Zero failures.

### Step 4: Prove It Works

**Mandatory proof — paste actual output:**

- Regression test: before (FAIL) and after (PASS) output
- Full test suite: all passing
- **Frontend**: run `/verify-in-browser` in bugfix mode for visual before/after proof
- Edge cases: show that related scenarios still work

### Step 5: Self-Review

Re-read every changed file. Check:
- Is this the minimal fix?
- No unrelated changes snuck in?
- No new coupling or complexity introduced?
- Would this fix survive if someone refactored the surrounding code?

## Phase 5: Summary

Present using this format:

```
## Bug Fix Summary

**Bug:** [one-line description]
**Root cause:** [what was wrong — confidence X/5]
**Fix:** [what was changed and why]

### Changes
- `file`: what and why

### Regression Test
- `test-file`: what it tests
- Before fix: FAIL (paste output)
- After fix: PASS (paste output)

### Proof
- Test suite: X passed, 0 failed
- [FE] Visual proof: [verify-in-browser videos]

### Checks
- [ ] Regression test failed before fix
- [ ] Regression test passes after fix
- [ ] All existing tests pass
- [ ] Self-review complete
- [ ] Code committed
```

Then: "Bug fixed. Run `omt-reflect` to capture learnings." or continue with next bug.

## Commit

One bug fix = one atomic commit. Message format:
```
fix: [brief description of what was broken]

Root cause: [one sentence]
Regression test: [test file and what it covers]
```

## Red Flags — STOP

- Fixing without understanding root cause → Investigate more
- Confidence < 4 and already writing fix code → Stop, keep investigating
- Regression test passes before the fix → Test is wrong, rewrite it
- "The fix is too simple to need a test" → Every bug fix needs a regression test
- Scope creeping into refactoring → Fix the bug only, create separate task for refactor
