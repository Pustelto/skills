---
name: posting-gitlab-mr-inline-comments
description: Use when posting code review comments on a GitLab merge request via the glab CLI and the comments must appear anchored to specific file diff lines (so the reviewer sees the code snippet and a Resolve thread button) rather than as general MR discussions.
---

# Posting GitLab MR inline review comments via glab

## Overview

GitLab distinguishes two comment kinds on a merge request:

- **`DiffNote`** — anchored to a file + line. Renders with the code snippet, "started a thread on the diff", and a `Resolve thread` button. This is what you want for actionable review findings.
- **`DiscussionNote`** — general MR comment, no file context. Correct for summary / verdict notes.

The trap: `glab api --field "position[new_line]=N"` (form-encoded) **silently drops the position** and produces a `DiscussionNote`. The bracketed field names don't survive form-encoding the way the API expects. There is no error — the comment posts, just unanchored.

**The fix: send a JSON body via `glab api --input -`.**

## When to use

- Posting code-review findings on a GitLab MR via CLI (review skills, automated reviewers)
- You want each finding to render with file + line context
- You saw `glab api --field position[...]=...` produce a general comment instead of an inline one

When NOT to use:
- Summary / verdict notes that don't belong to one line — use `glab mr note <iid> --message ...`, which correctly creates a `DiscussionNote`.

## Core technique

Build the position as a JSON object, build the full payload as JSON, pipe to `glab api --input -`:

```bash
BASE_SHA="..."   # from glab api projects/:fullpath/merge_requests/<iid> | jq .diff_refs
HEAD_SHA="..."
START_SHA="..."
PROJECT_ID=...
MR_IID=...

# Position for an ADDED line (+ in the unified diff)
POSITION=$(jq -n \
  --arg b "$BASE_SHA" --arg h "$HEAD_SHA" --arg s "$START_SHA" \
  --arg p "$FILE" --argjson l "$NEW_LINE" \
  '{base_sha:$b, head_sha:$h, start_sha:$s, position_type:"text",
    new_path:$p, old_path:$p, new_line:$l}')

PAYLOAD=$(jq -n --arg body "$(cat "$BODY_FILE")" --argjson position "$POSITION" \
  '{body:$body, position:$position}')

echo "$PAYLOAD" | glab api \
  --method POST \
  --header "Content-Type: application/json" \
  --input - \
  "projects/${PROJECT_ID}/merge_requests/${MR_IID}/discussions" \
  | jq '{id:.id, type:.notes[0].type, has_position:(.notes[0].position != null)}'
```

A successful inline post returns `type: "DiffNote"` and a populated `position`. **Always verify** — a `DiscussionNote` response means the position was rejected silently and the comment is now an unanchored general note.

A reusable helper script is at `post-mr-comment.sh` in this skill directory.

## Position payload rules

Which keys you send depends on what kind of line in the diff you're commenting on:

| Line kind | Required position fields |
|---|---|
| Added (`+` line) | `new_path`, `old_path` (same value), `new_line` |
| Removed (`-` line) | `new_path`, `old_path` (same value), `old_line` |
| Unchanged (context) | `new_path`, `old_path` (same), **both** `new_line` AND `old_line` |
| Line in a newly-added file | `new_path`, `new_line` — **omit** `old_path` / `old_line` |
| Line in a deleted file | `old_path`, `old_line` — omit `new_path` / `new_line` |

Every position payload also needs `base_sha`, `head_sha`, `start_sha`, `position_type: "text"`.

The most common silent-failure cause: sending only `new_line` for a context (unchanged) line. GitLab needs both `new_line` and `old_line` for context anchoring.

## Finding line numbers

1. Get refs once:
   ```bash
   glab api projects/:fullpath/merge_requests/<iid> \
     | jq '{diff_refs, project_id, iid}'
   ```
2. List actual diff hunks for the file:
   ```bash
   git --no-pager diff <base_sha>..<head_sha> -U0 -- <file>
   ```
   Hunks look like `@@ -OLD_START,OLD_COUNT +NEW_START,NEW_COUNT @@`. `+` lines use `new_line`; `-` lines use `old_line`.

### Computing `old_line` for a context line

For an unchanged line, you need both `new_line` and `old_line`. Track the cumulative offset (sum of `NEW_COUNT - OLD_COUNT` across every hunk that ENDS before your target):

```
running_offset += (new_count - old_count) for each prior hunk
old_line       = new_line - running_offset
```

Example: after a hunk `@@ -65,2 +68,2 @@` (no net change but the file's already been shifted) the running offset is `+3`. To comment on a context line at new_line 90: `old_line = 90 - 3 = 87`.

If the math feels brittle, an alternative is to comment on the nearest `+` line within the same logical block — usually you don't lose much.

## Editing and deleting comments

A **discussion ID** is not the same as a **note ID**. Fetch the note ID first:

```bash
NOTE_ID=$(glab api projects/${PROJECT_ID}/merge_requests/${MR_IID}/discussions/${DISCUSSION_ID} \
  | jq '.notes[0].id')

# Edit body
echo '{"body":"new content"}' | glab api --method PUT \
  --header "Content-Type: application/json" --input - \
  "projects/${PROJECT_ID}/merge_requests/${MR_IID}/notes/${NOTE_ID}"

# Delete
glab api --method DELETE \
  "projects/${PROJECT_ID}/merge_requests/${MR_IID}/notes/${NOTE_ID}"
```

## Common mistakes

| Symptom | Cause | Fix |
|---|---|---|
| `type: DiscussionNote`, no diff context shown | Used `glab api --field position[...]=...` | Switch to `--input -` with a JSON body |
| Same, but only on context lines | Sent only `new_line` for an unchanged line | Add `old_line` too |
| 400 / silent reject on a new file | Sent `old_path` for a file that didn't exist at `base_sha` | Pass `mode=new`: omit `old_path` / `old_line` |
| Comment lands on the wrong line | Used the line number from the OLD file (or vice versa) | `new_line` is the line in HEAD; verify with `git diff -U0` |
| `--field` "works" once then stops | One field accidentally URL-safe, others not | Always JSON-body; don't mix |
| Cleanup needs to delete one-by-one | First attempt produced unanchored notes | Loop over discussion IDs, fetch note ID, DELETE |

## Red flags — stop and check

- A post returned `type: "DiscussionNote"` when you expected inline → position was rejected
- You're about to use `--field position[...]=...` → won't work, switch to `--input -`
- You're sending only `new_line` for a line that wasn't a `+` in the diff → add `old_line`
- You're sending `old_path` for a file that's new in this MR → drop it

## General (non-inline) notes

For verdict / summary comments that belong to the whole MR, not one line:

```bash
glab mr note <iid> --message "$(cat summary.md)"
```

That creates a `DiscussionNote`, which is the correct shape for general commentary.
