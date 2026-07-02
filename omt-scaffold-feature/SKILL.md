---
name: omt-scaffold-feature
description: Use when starting a new feature. Step 1 of omt workflow — run before omt-start-prd
---

# Scaffold Feature

## Overview

Creates a feature directory in the tasks-vault by delegating to the scaffold script **bundled with this skill** at `bin/bootstrap-task` (next to this `SKILL.md`). The script renders the templates bundled in `templates/` (prd, tech-spec, tasks, implementation).

The destination tasks-vault is **not hardcoded** — the script resolves it in this order:

1. `--vault PATH` flag
2. `$OMT_TASKS_VAULT` environment variable
3. a `vault=<path>` line in the config file (`$OMT_CONFIG_FILE`, default `~/.config/omt/config`)
4. fallback `$HOME/Developer/tasks-vault`

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
3. **Run the bundled script** (from the skill directory, or by absolute path):
   - Minimal explicit call:
     `bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS"`
   - If the vault isn't at the default location and no env/config is set, pass it explicitly:
     `--vault "$OMT_TASKS_VAULT"`
   - If the user wants the full set up front, append:
     `--all-files`
4. **Capture the output path** from the script and remember it for subsequent skills.
5. The script will prompt to create `.omt-context` in the current directory (defaults to yes). This file persists the feature folder path so all subsequent omt skills auto-discover it.
6. **Create `_implementation.md`** — empty file in the repo root for session notes (used by `omt-compound`).
7. **Update `.gitignore`** — append `.omt-context` and `_implementation.md` if not already present.
8. **Inform the user** that the feature is initialized and the next step is `omt-start-prd`.

## Command Reference

The script lives at `bin/bootstrap-task` inside this skill. Run it from the skill directory (or by absolute path):

```bash
bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS"
```

With all files:

```bash
bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS" --all-files
```

Pointing at a specific vault (when not using `$OMT_TASKS_VAULT` / config):

```bash
bin/bootstrap-task --name "$FEATURE_NAME" --jira "$JIRA_ID" --status "$STATUS" --vault "$OMT_TASKS_VAULT"
```

Run `bin/bootstrap-task --help` for the full option list and vault-resolution order.

## Input Defaults

| Input | Default |
|------|---------|
| Jira ID | `NO-TICKET` |
| Status | `pending` |
| Create all files | `no` |
| Vault | `$OMT_TASKS_VAULT` → `~/.config/omt/config` → `$HOME/Developer/tasks-vault` |

## Notes

- Do not manually create directories or render templates when the script is available.
- Do not force kebab-case from the user; pass the human-readable feature name through to the script.
- The script already guards against duplicate target folders.
- The script and templates are bundled with this skill (`bin/`, `templates/`) — it carries no hardcoded vault path. If the vault can't be resolved, the script fails loudly and tells the user how to set it (`--vault`, `$OMT_TASKS_VAULT`, or the config file).
- **`templates/` is the canonical template set for the whole omt workflow.** `omt-create-tech-spec` and `omt-create-tasks` read `tech-spec.md` / `tasks.md` from here (`../omt-scaffold-feature/templates/`) when lazily creating those files, so there is a single source of truth — edit a template here and every skill picks it up.

## Output

After completion, inform user: "Feature initialized. Next: run `omt-start-prd` to begin PRD creation."
