---
name: omt-scaffold-feature
description: Use when starting a new feature. Step 1 of omt workflow — run before omt-start-prd
---

# Scaffold Feature

## Overview

Creates a feature directory in the tasks vault using the `bin/bootstrap-task` script from the OMT skills repo.

Default script behavior creates only `prd.md`. Other files are created lazily by subsequent skills unless `--all-files` is explicitly requested.

## When to Use

- Starting a new feature or project
- Need a structured workspace before PRD creation
- **Not** for existing features (check tasks vault first)

## Path Resolution

- **Skills repo:** derive from this SKILL.md file's location — go up one directory
- **Tasks vault:** read `$HOME/.omt.config` (plain text, single line = vault path). Fallback: `$HOME/omt-tasks/`
- **Templates:** `<tasks-vault>/_templates/` if exists, otherwise `<skills-repo>/templates/`

## Process

1. **Gather info** from the user: Feature Name, Jira ID, Status (`pending`/`in-progress`/`done`), and optionally whether to create all standard files.
2. **Normalize inputs**:
   - Feature Name: natural language is fine; the script will slugify it.
   - Jira ID: default to `NO-TICKET` if the user leaves it blank.
   - Status: default to `pending` if the user leaves it blank.
   - Create all files: default to `no`.
3. **Run the script** from the skills repo:
   - Minimal explicit call:
     `<skills-repo>/bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS"`
   - If the user wants the full set up front, append:
     `--all-files`
4. **Capture the output path** from the script and remember it for subsequent skills.
5. The script will prompt to create `.omt-context` in the current directory (defaults to yes). This file persists the feature folder path so all subsequent omt skills auto-discover it.
6. **Create `_implementation.md`** — empty file in the repo root for session notes (used by `omt-compound`).
7. **Update `.gitignore`** — append `.omt-context` and `_implementation.md` if not already present.
8. **Inform the user** that the feature is initialized and the next step is `omt-start-prd`.

## Command Reference

```bash
# Resolve skills repo from this SKILL.md location
SKILLS_REPO="$(cd "$(dirname "$0")/.." && pwd)"

$SKILLS_REPO/bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS"
```

With all files:

```bash
$SKILLS_REPO/bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS" --all-files
```

## Input Defaults

| Input | Default |
|------|---------|
| Jira ID | `NO-TICKET` |
| Status | `pending` |
| Create all files | `no` |

## Notes

- Do not manually create directories or render templates when the script is available.
- Do not force kebab-case from the user; pass the human-readable feature name through to the script.
- The script already guards against duplicate target folders.

## Output

After completion, inform user: "Feature initialized. Next: run `omt-start-prd` to begin PRD creation."
