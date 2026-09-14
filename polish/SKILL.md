---
name: polish
description: Use when a branch is finished and about to become a merge request, when a draft merge request goes ready, or after review fixes are pushed. Use it at any point where a human reviewer is about to read the branch. Also use when asked to clean up comments, to check that docs touched by the branch are still true, or to check that the merge request description matches the current code.
---

# Polish: the last pass before the reviewer

A reviewer has limited attention. This pass spends all of it on the change itself. It removes
comments that restate code, it corrects doc sentences that the branch just made false, and it
rewrites a description that still describes an earlier version of the branch.

Polish edits three things: comments, doc text, and the merge request description. It edits nothing
else. Polish is not a review, not a refactor, and not a bug hunt. Report anything else you find.

Related skills:

- `code-comments` tells you how to write a comment in the first place.
- `create-mr` runs the quality gate, commits, pushes, and creates the merge request.
- `fix-review` addresses review threads.

Run polish after `fix-review` and before `create-mr` marks a merge request ready.

## Scope

Read only what this branch changed:

```bash
BASE=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|origin/||')
git diff "$BASE"...HEAD --stat
git diff "$BASE"...HEAD -U3
```

The base is the repository's default branch, usually `main` or `master`.

Leave noise that sits outside the diff. Report it when it matters. Never fix it here.

## Style for every word you write

This rule covers every comment you keep or correct, every doc sentence you change, and the merge
request description. Follow the Google developer documentation style guide, at
https://developers.google.com/style:

1. One idea per sentence. Split a sentence that carries two.
2. Active voice, with the actor named. Write "the consumer treats the event as a rebase", not "the
   event is treated as a rebase".
3. Present tense. Write "the planner rejects it", not "the planner will reject it".
4. Expand an abbreviation on first use in that file, for example "change data capture (CDC)".
5. No em-dash asides and no nested quotes inside a clause. Use two sentences instead.
6. No idioms and no figurative language.
7. Numbered steps for a mechanism, not one dense paragraph.

Many reviewers read English as a second language. Density costs them more than it costs a
native reader. This rule constrains padding, never necessary content: when a comment needs
two sentences to stay true, write two sentences.

## Pass 1: sweep the comments

Apply this test to every comment the diff adds or changes:

> Sweep all comments added or updated in this merge request and remove those that bring no extra
> value. A comment may exist only when it does one of three things: it explains a non-obvious
> change in a way that can prevent a bug, it explains the existence of a magic number, or it
> explains a non-standard solution that another developer without context might try to "fix".
>
> A comment must not re-explain the code, duplicate knowledge stored elsewhere, or state the
> obvious. If a reader can infer the knowledge by reading the code, it does not belong in a comment.

Delete these without further analysis:

- Step narration, such as `// build the insert statement` above the line that builds it.
- Section banners, such as `// ===== public API =====`.
- Diff and ticket narration, such as `// added in PROJ-1234`.
- Doc blocks that restate a signature.
- Doc blocks on private members, tests, overrides, and data classes.
- Commented-out code.
- Debug logging that the branch added as scaffolding.
- A bare `TODO`. A `TODO` survives only when it states a reason and names a ticket.

Never delete a comment that a tool reads. This includes `@Suppress`, `detekt:disable`,
`eslint-disable`, `@ts-expect-error`, `noinspection`, `//language=SQL`, license headers, and code
generation markers. This pass judges prose.

## Pass 2: prove every surviving comment true

Check each surviving comment against the code as it now stands. The ticket, the previous comment,
the commit message, the handoff note, and the previous doc all state claims. The code that produces
the behaviour is the authority. Read that code.

A comment that disagrees with the code presents you with a choice. Take one of these three actions:

| Situation | Action |
|---|---|
| The comment fails Pass 1. | Delete it. Also report the contradiction, because the code may be the wrong side of it. |
| The comment earns its place and the code proves it wrong. | Correct the comment. |
| You cannot establish which side is true. | Change nothing. Stop. Ask. |

A false premise voids the conclusion built on it. When a comment states a fact that turns out to be
wrong, the instruction it justifies loses its support, however sensible that instruction still
sounds. Do not correct the fact and keep the instruction. Instead do one of two things: re-derive
the instruction from the code and rewrite the whole comment, or leave the comment exactly as it is
and report it. A half-corrected justification is worse than the original, because it looks reviewed.

## Pass 3: check the docs the branch changed

For every doc file in the diff, re-read every claim in the file. This includes sentences the branch
never touched, because the branch may have made them false.

Check these:

1. Descriptions of a mechanism.
2. Counts and limits, such as retry counts, batch sizes, and timeouts.
3. Named symbols. Confirm each one still exists.
4. Code samples. Confirm each one still matches the API.
5. Performance claims. State which change alters the growth rate and which change only alters the
   constant factor. Name the inputs that still fall off the fix.

When the branch makes a doc outside the diff false, report that doc. Do not fix it here.

## Pass 4: check the merge request description

Read the current description:

```bash
glab mr view --output json   # GitLab
gh pr view --json body       # GitHub
```

Write the description that the final diff deserves, then compare it against the current one. Every
claim in the description must be checkable in the final diff.

Read `mr-description-template.md` in this skill directory for the template, the section rules, and
the freshness checks. That file is the single source of truth, and `create-mr` uses it too.

Write the new body to a file, then update the description:

```bash
# GitLab
glab api --method PUT projects/:fullpath/merge_requests/<IID> --field description=@/tmp/description.md
# GitHub
gh pr edit <number> --body-file /tmp/description.md
```

Never pass `--title` when you update a draft merge request. The title carries the draft state in
its `Draft: ` prefix, so setting a title without that prefix marks the merge request ready. On
many instances that also notifies or auto-assigns reviewers.

When no merge request exists yet, hand the description to `create-mr`. Do not create one here.

## Hard rules

1. Report uncertainty to the user. Never write it into the artifact. Do not put a note such as
   "this needs verifying" inside a comment, a doc, or a description, because the reviewer reads that
   note as verified fact.
2. When you find a defect, stop and report it. Do not fix it. Do not delete dead code. Do not
   rename. Do not restructure. A behaviour change hidden inside a polish pass is invisible to a
   reviewer who believes they are reading cleanup. When a comment can only become true if you
   change code, that is a defect report and not a polish edit.
3. Re-run the repository quality gate after you edit, whatever that repository uses, for example
   `./gradlew check`, `npm run lint`, or `make check`. Suppressions, formatting directives, and
   code generation markers all live in comments, so a comment edit can break the build.

## Red flags: stop and re-read the pass

| Excuse | Reality |
|---|---|
| "The comment is stale, so deleting it fixes the problem." | Deleting it hides the contradiction. Decide which side is wrong, and report it either way. |
| "I will add a note that this needs checking." | That note ships to the reviewer as fact. Report uncertainty in chat instead. |
| "The ticket says the retry count is 3." | The ticket states a claim. The code that produces the behaviour is the authority. |
| "While I am here, this dead helper should go." | That work sits outside this pass. Report it. |
| "This comment explains the tricky part, so it stays." | It stays only when a reader cannot get the same knowledge from the code, the names, and the types. |
| "The fact was wrong, but the conclusion still sounds right." | The conclusion rested on that fact. Re-derive it from the code, or leave the comment alone and report it. |
| "The description is roughly right." | A roughly right number is a wrong number. Write the description from the final diff. |
| "I found a bug, so I will fix it quickly." | Then the reviewer reviews a behaviour change that you labelled as cleanup. |
| "The reviewer will spot the mismatch." | Finding that mismatch costs the reviewer the attention this pass exists to save. |

## Report

```
Comments:    <n> deleted, <n> corrected, <n> kept (list each kept comment and the reason)
Docs:        <file>: <claims corrected>
Description: updated / already accurate
Gate:        <command>: passed / failed <detail>

Needs your call:
  - <contradiction I could not resolve, with both sides stated>
  - <suspected defect, file:line, and what I believe is wrong>

Out of scope, untouched:
  - <pre-existing noise, dead code, docs outside the diff>
```
