# Merge request description template

Both `polish` and `create-mr` use this file. It is the single source of truth for merge request
descriptions. Edit it here.

Adjust the headings to match what your team already writes. Write substance, not boilerplate.

## The template

Use the feature form for new work. Use the bugfix form when the merge request fixes a defect.

### Feature form

```markdown
## What
<One or two sentences in the imperative voice. Name the change, then name the problem it solves.
Then, if the change needs it, one short paragraph on the mechanism.>

## Why
<The decisions the diff cannot show. Name the approach you chose. Name the alternative you
rejected and say why. State the trade-off and the number that makes it a trade-off. State the
known limits.>

## Verification
<What you ran and what the run proved. Give numbers, not adjectives. Include the query plan, the
timing, or the log line when you have one.>

## Notes for the reviewer
<Optional. Where to start reading. Which files are mechanical or generated. What deserves
scrutiny. Omit this section when the diff is small enough to read in order.>

## Stack
<Only when this merge request depends on another. Link the parent and say which one merges
first.>
```

### Bugfix form

```markdown
## What broke
<The defect, in terms a reader can verify. Name the trigger. Name the observed result. Name the
expected result. Link the incident or the log evidence when one exists.>

## Fix
<What the change does. Say whether the fix is behavioural or an ordering or configuration change,
and how many files it touches.>

## Verification
<How you proved the fix works, and how you proved the defect existed before it.>

## Notes for the reviewer
<Optional. Same as the feature form.>
```

## Rules

1. Omit a section rather than leave it empty. Never ship a heading with `N/A` under it.
2. Do not add a section that only repeats the ticket number. The title carries it, and most
   platforms link it automatically. Add a link in the body only when the reader needs a second
   ticket, such as a parent epic or a sibling ticket in another repository.
3. Write performance claims so they say which change alters the growth rate and which change only
   alters the constant factor. Name the inputs that still fall off the fix.
4. Keep the trailer that `create-mr` adds.
5. Write the description in the style the Google developer documentation style guide defines, at
   https://developers.google.com/style. One idea per sentence. Active voice with the actor named.
   Present tense. Expand an abbreviation on first use, for example "change data capture (CDC)". No
   em-dash asides, and no idioms. Many reviewers read English as a second language, so density
   costs them more than it costs a native reader. The `polish` skill states the same rule for
   comments and docs.
6. Put work that nobody verified under `## Verification`, in a line that starts with "Not
   verified:". Do not leave it as an unchecked checklist item, because a reviewer reads an unchecked
   box as a step that is still pending rather than as a known gap.

## Freshness checks

Run these when a merge request already exists. Compare every claim in the description against the
final diff, not against the first commit.

| Check | Question |
|---|---|
| Numbers | Did a batch size, a timeout, a retry count, or a measurement change during review? |
| Approach | Did review change the approach the description still describes? |
| Split work | Did part of the work move to another merge request? |
| Drift | Does the description still describe only the first commit? |
| Verification | Did anyone run what this section claims? Delete an unrun checklist. |
| Scope | Did the diff grow a file or a behaviour the description never mentions? |
