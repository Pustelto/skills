# OMT Skills

AI agent workflow skills for structured software development. Implements a full feature delivery pipeline: PRD, tech spec, task breakdown, TDD execution, and knowledge compounding.

Works with **any AI coding agent**. Skills are written as markdown instructions in `SKILL.md` files (Claude Code convention), but the workflows are agent-agnostic — treat them as structured prompts for your agent of choice.

## How It Works

Three separate concerns:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Skills Repo   │     │   Tasks Vault   │     │  Working Repo   │
│   (this repo)   │     │  (your data)    │     │ (your project)  │
│                 │     │                 │     │                 │
│ SKILL.md files  │────▶│ Feature folders  │◀────│ .omt-context    │
│ bin/bootstrap   │     │ prd.md          │     │ _implementation │
│ templates/      │     │ tech-spec.md    │     │ .memo/          │
│                 │     │ tasks.md        │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

- **Skills repo** — Skill definitions, default templates, and scripts (install once, use everywhere)
- **Tasks vault** — Your feature folders with PRDs, specs, and tasks (one per machine, customizable templates)
- **Working repo** — The actual project you're developing (each project links to its active feature via `.omt-context`)

## Quick Start

```bash
# 1. Clone
git clone https://github.com/yourname/omt-skills.git
cd omt-skills

# 2. Run setup
bin/setup

# 3. In your project repo, start a feature
/omt-scaffold-feature
```

The setup script will:
- Create `~/.omt.config` pointing to your tasks vault
- Create the tasks vault directory with default templates
- Symlink skills to `~/.claude/skills/` (for Claude Code users)

## Workflow

```
/omt-scaffold-feature        Step 1: Create feature folder in tasks vault
        │
/omt-start-prd                Step 2: Write PRD with Product Owner agent
        │
/omt-create-tech-spec         Step 3: Write tech spec with Tech Lead agent
        │
/omt-create-tasks             Step 4: Break spec into small tasks (20 min max each)
        │
/omt-execute-task              Step 5: Execute tasks one by one (TDD, vertical slices)
        │  ├── /omt-compound       Capture learnings during work
        │  └── /omt-compound-log   Log task completion details
        │
/omt-reflect                   Step 6: Organize learnings into permanent knowledge
```

Each step has an explicit approval gate — the agent waits for your sign-off before proceeding.

## Skill Inventory

### Feature Delivery (OMT Workflow)

| Skill | Description |
|-------|------------|
| `omt-scaffold-feature` | Create feature folder in tasks vault with templates |
| `omt-start-prd` | Spawn Product Owner agent to write PRD |
| `omt-create-tech-spec` | Spawn Tech Lead agent — explore codebase, compare approaches, write spec |
| `omt-create-tasks` | Break approved spec into small, vertical-slice tasks |
| `omt-execute-task` | Execute one task at a time with TDD |
| `omt-fix-bug` | Lightweight alternative — investigate and fix a bug without full workflow |

### Knowledge Compounding

| Skill | Description |
|-------|------------|
| `omt-compound` | Quick-capture learnings to `_implementation.md` during work |
| `omt-compound-log` | Log task completion details (sharp knives, landmines, divergences) |
| `omt-reflect` | Organize captured learnings into permanent `.memo/` knowledge base |
| `omt-knowledge-search` | Search `.memo/` for relevant standards, patterns, past friction |
| `omt-setup` | Initialize `.memo/` knowledge base in a repo |
| `omt-seed` | Populate `.memo/` from existing docs and codebase patterns |

### Code Quality (Standalone)

| Skill | Description |
|-------|------------|
| `tdd` | Test-driven development philosophy and patterns |
| `review-code` | PR/branch code review |
| `review-fe` | Frontend-focused code review |
| `delegate-codex` | Delegate tasks to OpenAI Codex agent |

## Setup

### Automated (recommended)

```bash
bin/setup
```

### Manual

1. **Create config file** — tells skills where your tasks vault lives:
   ```bash
   echo "$HOME/omt-tasks" > ~/.omt.config
   ```

2. **Create tasks vault** with default templates:
   ```bash
   mkdir -p ~/omt-tasks/_templates
   cp templates/* ~/omt-tasks/_templates/
   ```

3. **Register skills** with your AI agent:

   **Claude Code** — symlink each skill:
   ```bash
   mkdir -p ~/.claude/skills
   for dir in omt-* tdd review-code review-fe delegate-codex; do
     [ -f "$dir/SKILL.md" ] && ln -s "$(pwd)/$dir" ~/.claude/skills/"$dir"
   done
   ```

   **Other agents** — point your agent at the `SKILL.md` files in this repo. Each file is a self-contained workflow instruction.

## Configuration

### `~/.omt.config`

Plain text file, single line — path to your tasks vault.

```
/Users/you/omt-tasks
```

### `.omt-context`

Created in your working repo root by `omt-scaffold-feature`. Points to the active feature folder. Gitignored.

```
/Users/you/omt-tasks/pending-PROJ-123-my-feature
```

### `_implementation.md`

Scratch file in your working repo root for session notes. Created by `omt-scaffold-feature`, used by `omt-compound`. Gitignored. Cleared by `omt-reflect` at session end.

### Environment Variables

| Variable | Purpose | Overrides |
|----------|---------|-----------|
| `OMT_TASK_CONTEXT` | Path to active feature folder | `.omt-context` file |
| `OMT_VAULT_DIR` | Path to tasks vault | `~/.omt.config` |

## Templates

Default templates ship in `templates/`. During setup, they're copied to `<vault>/_templates/`. Customize the vault copies — they take priority over defaults.

Templates use these placeholders:

| Placeholder | Replaced With |
|-------------|--------------|
| `{{FEATURE_NAME}}` | Title-cased feature name |
| `{{JIRA_ID}}` | Ticket ID (e.g., `PROJ-123` or `NO-TICKET`) |
| `{{STATUS}}` | `pending`, `in-progress`, or `done` |
| `{{DATE}}` | Creation date (`YYYY-MM-DD`) |

## Using with Non-Claude Agents

The `SKILL.md` format is a Claude Code convention, but the content is plain markdown describing a workflow. Any AI coding agent can follow these instructions:

1. Read the relevant `SKILL.md` file
2. Follow the **Process** section step by step
3. Use the **Path Resolution** rules to find files
4. Respect the **approval gates** (wait for user confirmation)

For agents that support custom instructions or system prompts, paste the relevant `SKILL.md` content as context.

## Contributing

1. Fork and clone
2. Create a skill directory with a `SKILL.md` file
3. Follow the existing patterns: frontmatter with `name` and `description`, clear process steps, approval gates
4. Submit a PR

## License

MIT
