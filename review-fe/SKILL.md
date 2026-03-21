---
name: review-fe
description: Use when reviewing frontend code — manual review, PR review, or during omt-execute-task. Covers React, TypeScript, CSS changes.
---

# Frontend Code Review

## Overview

Philosophy-driven code review that prioritizes **understanding over checklist checking**. Reviews code holistically — not just the diff, but how it fits the codebase, whether it should exist, and whether it's easy to read, change, and test.

## When to Use

- Reviewing your own code before commit/PR
- Reviewing a teammate's PR
- During `omt-execute-task` step 5 (review)
- When asked to review specific files or changes
- **Not** for backend-only changes

## Process

1. **Determine scope:**
   - If branch/PR: get full diff via `git diff <base>...HEAD`
   - If specific files: read those files
   - Get list of changed files

2. **Load context beyond the diff:**
   - Read FULL changed files (not just diff hunks)
   - Read files that IMPORT or USE the changed code
   - Read relevant tests (existing and new)
   - Read project conventions (CLAUDE.md, AGENTS.md if present)

3. **Search codebase for existing similar code:**
   - For every NEW file/component/hook/utility in the diff, actively search (Grep/Glob) for existing alternatives
   - Check shared libs, domain utils, other features that solved similar problems
   - This is the most commonly missed step — don't skip it

4. **Spawn fe-reviewer agent** via Task tool:
   - `subagent_type="general-purpose"`, `name="fe-reviewer"`
   - Pass: diff, full file contents, usage context, conventions, and search results for existing similar code
   - Agent reviews using philosophy defined in `~/.claude/agents/fe-reviewer.md`
   - Agent MUST start output with a Branch Summary (what the changes do)

5. **Present findings** by severity:

| Severity | Meaning | Action |
|----------|---------|--------|
| CRITICAL | Bugs, broken logic, impossible states | Must fix |
| MAJOR | Architecture, testability, cognitive complexity | Should fix |
| MINOR | Style, naming, small improvements | Nice-to-have |
| PRAISE | Good patterns worth recognizing | Acknowledge |

## Key Principle

> "Understand the code first. Then question whether it needs to exist. Then review how it's written."

The review is NOT just "find bugs in this diff." It's: does this code make the codebase healthier?

## Common Mistakes

- **Not searching for existing code** — the #1 miss. For every new component/utility, grep the codebase for similar ones before accepting it as "new"
- Reviewing only the diff without reading full files and their consumers
- Accepting complex UI components (split button, dropdown) when a simpler one fits the actual use case
- Flagging mechanical issues (missing semicolons) instead of architectural ones
- Not questioning whether the code should exist at all
