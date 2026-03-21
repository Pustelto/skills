---
name: omt-setup
description: Bootstrap compound memory system (.memo/) in any repo. Creates folder structure, INDEX.md, and updates CLAUDE.md. Run once per repo before using other compound skills.
---

# Setup Compound Memory System

## Overview

Initialize the `.memo/` compound memory system in any repository. Creates the folder structure, INDEX.md template, and adds documentation to CLAUDE.md so all agents know about the system.

This is a **one-time setup per repo** — run it once, then use `omt-seed` to populate with knowledge.

## When to Use

- Setting up compound memory in a new repo
- Adding compound memory to an existing project
- Bootstrapping the system for testing

## What It Creates

```
.memo/
  INDEX.md                    # From template, ready to use
  standards/                  # Empty, ready for notes
  runbooks/                   # Empty, ready for notes
  architecture/               # Empty, ready for notes
  refactoring/                # Empty, ready for notes
  _scratch.md                 # Empty scratch file
```

Plus updates to `CLAUDE.md` explaining the system.

## Process

### 1. Check if Already Set Up

Check if `.memo/` exists. If yes, ask user:
- Abort (already set up)
- Re-create (wipe and start fresh)
- Update only CLAUDE.md (keep existing .memo/)

### 2. Create Folder Structure

```bash
mkdir -p .memo/standards
mkdir -p .memo/runbooks
mkdir -p .memo/architecture
mkdir -p .memo/refactoring
touch .memo/_scratch.md
```

### 3. Create INDEX.md from Template

Use the template at the end of this skill. Write to `.memo/INDEX.md`.

### 4. Update CLAUDE.md

Add this section to CLAUDE.md (or create if doesn't exist):

```markdown
## Knowledge Base System

This project uses a compound memory system in `.memo/`:

- **`.memo/INDEX.md`** - Start here for all team knowledge. Always check this first when planning work.
- **`.memo/standards/`** - How we do things (conventions, patterns, rules)
- **`.memo/runbooks/`** - Step-by-step procedures for common tasks
- **`.memo/architecture/`** - System design docs with diagrams (Mermaid, ASCII)
- **`.memo/refactoring/`** - Friction log documenting pain points and improvement ideas
- **`.memo/_scratch.md`** - Quick session notes (migrated to proper notes during reflection)

### For AI Agents

When planning work:
1. Always read `.memo/INDEX.md` first to find relevant standards and past solutions
2. Use `/omt-search <topic>` to find specific knowledge
3. During work, capture learnings with `/omt-compound "quick note"`
4. At session end, run `/omt-reflect` to migrate scratch notes to organized knowledge

The system is designed for progressive disclosure: INDEX.md → category folder → individual note → referenced code.
```

### 5. Commit Changes

```bash
git add .memo/ CLAUDE.md
git commit -m "docs: initialize compound memory system

- Created .memo/ structure for team knowledge
- Added standards, runbooks, architecture, refactoring folders
- Updated CLAUDE.md with system documentation

Use /omt-seed to populate with existing knowledge."
```

### 6. Next Steps

Tell user:

```
✅ Compound memory system initialized!

Next steps:
1. Run `/omt-seed` to populate with existing knowledge (optional)
2. Run `/omt-seed "specific topic"` for targeted extraction (e.g., "error handling")
3. Start using `/omt-compound` during work to capture learnings
4. Use `/omt-reflect` at session end to organize knowledge

The system is ready but empty. Use omt-seed to migrate existing knowledge.
```

## For Submodules

If setting up in a submodule (e.g., `libs/dpm/`):
- Create `.memo/` in the submodule root
- Only include: standards/, runbooks/, architecture/, refactoring/
- No CLAUDE.md update (that stays at repo root)
- Lighter INDEX.md (no global concerns)

Ask user: "Is this a submodule setup? (y/n)"

### IMPORTANT: Register in Root INDEX.md

After creating a submodule `.memo/`, **always update the root `.memo/INDEX.md`**:

1. Move the domain from the **Pending** table to the **Active** table under `### Submodule Knowledge Bases`
2. Add the relative path and a short description of what the submodule knowledge covers
3. Update the Change Log

Example — after running `omt-setup` in `libs/dpm/`:

```markdown
#### Active (have `.memo/`)
| Domain | Location | Notes |
|--------|----------|-------|
| DPM (Data Processing) | [`libs/dpm/.memo/`](../libs/dpm/.memo/INDEX.md) | Processing monitoring, pipeline config, job management |
```

And remove the row from the Pending table.

This ensures the root INDEX.md is always the single source of truth for all domain knowledge bases across the monorepo.

## Validation

After creation, verify:
- All folders exist
- INDEX.md is valid markdown
- _scratch.md is empty
- CLAUDE.md updated (repo root only)

## Common Issues

- **CLAUDE.md doesn't exist** → Create it with just the Knowledge Base section
- **Git not initialized** → Warn user, create files but skip commit
- **.memo/ already exists** → Ask user how to proceed

---

## INDEX.md Template

\`\`\`markdown
# Knowledge Base Index

> Last updated: {TODAY} | Total notes: 0

## Quick Links

- [Standards](./standards/) — How we build (conventions, patterns, rules)
- [Runbooks](./runbooks/) — Step-by-step procedures
- [Architecture](./architecture/) — System design, flows, module docs
- [Refactoring](./refactoring/) — Friction log and improvement ideas

---

## Standards

> Conventions, patterns, and rules we follow. Each note should include problem/context, solution with examples, and code references.

| Note | Summary |
|------|---------|
| _No standards documented yet. Use `/omt-reflect` to create from session learnings._ | |

## Runbooks

> Step-by-step procedures for common tasks. Each runbook should be actionable and include commands/code.

| Note | Summary |
|------|---------|
| _No runbooks documented yet. Use `/omt-reflect` to create from session learnings._ | |

## Architecture

> System design documentation with diagrams (Mermaid, ASCII). Captures flows, modules, and key decisions.

| Note | Summary |
|------|---------|
| _No architecture docs yet. Use `/omt-reflect` to create from session learnings._ | |

## Refactoring

> Friction log documenting pain points and improvement ideas. Tracks severity, occurrences, and suggested approaches.

| Note | Friction | Occurrences | Effort | Summary |
|------|----------|-------------|--------|---------|
| _No refactoring notes yet. Use `/omt-reflect` to create from session learnings._ | | | | |

---

## Change Log

| Date | Note | Change |
|------|------|--------|
| _No changes yet._ | | |

---

## How to Use

- **For humans:** Scan this INDEX, click into category folders, read relevant notes
- **For AI agents:** Read this INDEX during planning to find relevant standards and past solutions
- **To add knowledge:** Use `/omt-compound` during work, then `/omt-reflect` at session end
- **To search:** Use `/omt-search <topic>` to find specific notes
\`\`\`
