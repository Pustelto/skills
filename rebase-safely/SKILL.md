---
name: rebase-safely
description: Use when rebasing a feature branch (or a stack of branches) onto the latest master/main, resolving rebase conflicts, or force-pushing a rewritten branch — anytime history is rewritten and changes could be silently lost or a remote clobbered.
---

# Rebasing Safely

## Overview

Rebasing rewrites history. Two things go irreversibly wrong: **changes vanish** (a conflict hunk resolved to the wrong side, a commit dropped, a `-X theirs` clobber) and **the remote gets corrupted** (a force-push overwrites work that wasn't yours to overwrite). Both are recoverable *only if you left yourself a rope*.

**Core principle: never rewrite history without a recorded escape hatch, never push until the human has seen the result, and never trust that a rebase kept everything — prove it.**

This skill is grounded in the owner's actual workflow: fetch first, rebase onto `origin/<base>`, resolve conflicts keeping *combined* intent, verify nothing was lost, then stop and let the human decide about pushing.

## The Iron Rules

1. **Record an escape hatch before the first `git rebase`.** A backup tag + the written-down pre-rebase SHA. No escape hatch → don't start.
2. **NEVER push automatically. Pushing to a remote is only ever done when the user explicitly asks for the push in this task** — not implied by "rebase", not "to run CI", not because a teammate is waiting. Default is always to stop and report. The owner has repeatedly said *"do not push after rebase, I want to check the results first."* The permission layer backs this up: plain `git push --force` / `-f` is **denied** (never usable), and `git push --force-with-lease` is **ask-gated** (you may run it, but every force-push prompts for confirmation). If a push is genuinely needed and you were not explicitly asked, hand the exact command to the user and stop.
3. **When the user *has* asked you to push a rewritten branch, use `--force-with-lease`, never `--force`.** Prefer the pinned form `--force-with-lease=<branch>:<remote-sha>` using the SHA you just fetched. Running it will prompt for confirmation — that is intended.
4. **Prove nothing was lost** with `git range-diff` and a file/content check before declaring success.
5. **A conflict is a decision, not a chore.** Understand BOTH sides. Never blanket `-X theirs`/`-X ours` to make it stop.

**Violating the letter of these rules is violating the spirit of them.** "The teammate is waiting" / "it's obviously a clean rebase" / "force-with-lease is safe enough" / "rebase obviously means push too" are not exceptions.

## Procedure

### 1. Snapshot + escape hatch (before touching history)
```bash
git status                              # must be clean; stash or commit first
git rev-parse HEAD                      # record this SHA (paste it in your report) — the authoritative rope
git tag backup/<branch>-prerebase       # tag, not branch — immune to rebase.updateRefs (see note)
git fetch origin <base> --quiet         # base = master or main
git log --oneline HEAD..origin/<base>   # what's incoming (empty = nothing to do)
git log --oneline origin/<base>..HEAD   # your commits that will be replayed
```
Note the "your commits" count — you will confirm the same count survives.

**Why a tag, not a branch:** with `rebase.updateRefs` enabled, a *branch* pointing into the rebased range gets silently moved forward to the new HEAD during the rebase — destroying its value as a rope. A **tag** is not moved, and the **recorded SHA + `git reflog`/`ORIG_HEAD`** can never be moved. The written-down SHA is the real escape hatch; the tag is convenience. (If you used a backup *branch*, after the rebase verify it still points at the pre-rebase SHA and `git branch -f` it back if not.)

### 2. Rebase
```bash
git rebase origin/<base>
```
On conflict, resolve with intent (§3). Continue **without opening an editor** (avoids a hang):
```bash
git diff --name-only --diff-filter=U    # exactly which files conflict
# ... edit each file, then:
git add <file>
GIT_EDITOR=true git rebase --continue
```
To bail out at any point and return to the exact pre-rebase state:
```bash
git rebase --abort                      # restores HEAD to where you started
```

### 3. Resolve conflicts by combined intent
- Open each conflicted file. Read **both** sides and the base. Ask: does master's change and my change both need to survive? Usually **yes** — the answer is a merge of both, not a pick.
- Picking one whole side (`-X theirs`/`ours`, or deleting the other's hunk) is the #1 way changes silently vanish. Only do it when you have positively confirmed the other side is genuinely obsolete.
- If you cannot tell what the correct resolution is, STOP and ask. A wrong resolution that compiles is worse than a question.

### 4. Prove nothing was lost (before any push)
```bash
git range-diff origin/<base> <PRE_REBASE_SHA> HEAD   # each old commit → new commit, 1:1
git log --oneline origin/<base>..HEAD                # same commit count as step 1?
git diff <PRE_REBASE_SHA> HEAD -- .                  # only expected base-integration deltas?
```
`range-diff` should show every original commit mapped to a rebased one with only the intended conflict deltas. A dropped commit, an unexpected content change, or a shrunk diff = a lost change. Investigate before proceeding.
Then run the project's build/tests (the owner always does a post-rebase compile/check).

### 5. STOP. Report, don't push.
Report: pre-rebase SHA, backup tag name, commits replayed, files that conflicted and how each was resolved, range-diff result, build status. **This is the end of the task unless the user explicitly asked you to push.** Do not push to "save a round trip", to "run CI", or because someone is waiting.

### 6. Push — only when the user explicitly asked
`--force-with-lease` is ask-gated, so running it prompts for confirmation. Use the exact, safe command:
```bash
git fetch origin <branch>                             # refresh the lease target
git rev-parse origin/<branch>                          # the SHA being overwritten
git push --force-with-lease=<branch>:<that-sha> origin <branch>
```
`--force-with-lease` refuses the push if the remote moved since the fetch (someone else pushed) — that's the guard against clobbering. Plain `--force` is permission-denied and has no guard; never use it, never suggest it. When the push prompts, that confirmation is the intended checkpoint — surface the command so the reviewer knows exactly what will change.

## Stacked branches (the common case)

The owner usually rebases a **stack**: branch B depends on A depends on master. Rebase bottom-up, each onto its (already-rebased) parent:

```bash
# after the lowest branch A is rebased onto origin/master:
git checkout B
git rev-parse HEAD; git tag backup/B-prerebase
git rebase --onto A <old-A-tip> B      # replay B's own commits onto new A
```
- Do each branch's snapshot/verify/report cycle individually.
- **When a lower MR has been merged to master**, its commits are now in `origin/master`. Rebase the rest of the stack onto `origin/master` and let the merged commits drop out (git detects them as already-applied). Verify with `range-diff` that *only* the merged commits disappeared and your remaining work is intact.
- Push the stack only when told, bottom-up, each with its own `--force-with-lease`.

## Recovery — when something's already wrong

| Situation | Recovery |
|-----------|----------|
| Rebase in progress went bad | `git rebase --abort` → back to pre-rebase HEAD |
| Rebase finished, commits look wrong | `git reset --hard <recorded-SHA>` (or `backup/<branch>-prerebase` tag) |
| No tag, but local | `git reflog` → find pre-rebase HEAD → `git reset --hard <sha>` / `ORIG_HEAD` |
| Already force-pushed a bad rewrite | remote still has your reflog locally; reset local to the recorded SHA, `git push --force-with-lease` the good state back |
| "We lost things during rebase" | `git range-diff` old-SHA..new to find the dropped hunk/commit; cherry-pick or re-resolve from the recorded SHA/tag |

Delete `backup/<branch>-prerebase` only after the human confirms the result is good and it's pushed.

## Red Flags — STOP

- About to run `git rebase` and there's no recorded SHA / backup tag yet
- About to run **any** `git push` when the user did not explicitly ask for a push in this task
- Typing plain `--force`/`-f` (permission-denied and unguarded) instead of `--force-with-lease`
- Resolving a conflict by keeping one whole side without reading the other
- Declaring "rebase done, intent kept" without having run `range-diff`
- Working tree wasn't clean before you started
- Under time pressure ("teammate waiting", "be quick") and tempted to skip the snapshot or push without review

**Every one means: stop and follow the procedure.**

## Rationalizations — and reality

| Excuse | Reality |
|--------|---------|
| "Teammate's waiting, just push it" | A clobbered remote costs the team hours. 30 seconds of backup + review is cheaper. |
| "It's obviously a clean rebase" | Clean rebases still drop commits when the base already contains a similar change. Run `range-diff`. |
| "`--force-with-lease` is safe, I don't need review" | Lease guards the *remote*, not your *resolution*. The human reviews the resolution. |
| "Backup branch is clutter" | It's free and deletable. Losing a day of work is not. |
| "I'll just keep my side on every conflict" | That's how master's needed fixes get silently reverted. Merge intent, don't pick. |
| "range-diff is overkill for 3 commits" | 3 commits is exactly where a silent drop hides. It takes one command. |
| "The user said rebase, that implies push" | It does not. Push only when the user explicitly asks for the push. `--force-with-lease` is ask-gated (it prompts); plain `--force` is denied. |
| "I'll just push to run CI / it's faster" | Not your call. Stop and hand over the command; the user decides when the remote changes. |

## Quick Reference

```bash
# safety net (record the SHA; tag survives rebase.updateRefs, a branch may not)
git rev-parse HEAD; git tag backup/<b>-prerebase
git fetch origin <base> --quiet
# rebase
git rebase origin/<base>
git diff --name-only --diff-filter=U      # conflicts
GIT_EDITOR=true git rebase --continue
git rebase --abort                        # panic button
# verify
git range-diff origin/<base> <preSHA> HEAD
# push — ONLY if the user explicitly asked; --force-with-lease is ask-gated (prompts), plain --force is denied:
git fetch origin <b>; git rev-parse origin/<b>
git push --force-with-lease=<b>:<sha> origin <b>   # will prompt for confirmation
# recover
git reset --hard <preSHA>                 # or backup/<b>-prerebase tag / git reflog / ORIG_HEAD
```
