---
name: delegate-to-codex
description: "Delegate a coding task to OpenAI Codex agent for autonomous execution"
---

You are delegating a coding task to a headless Codex agent. Codex will do the actual implementation work.

## Your Task

1. Identify the task from conversation context
2. Read CLAUDE.md and inject context directly into the prompt
3. Execute Codex and report results

### Step 1: Identify the Task from Context

Review the conversation history and identify:

- What task does the user want accomplished?
- What files/areas of the codebase are involved?
- What does "done" look like?

Restate the task clearly. If unclear, ask the user to clarify.

### Step 2: Gather Context

1. Read CLAUDE.md if it exists - extract relevant project context
2. Use Read/Grep/Glob to find relevant code patterns or resources
3. Note any conventions or styles to follow

### Step 3: Formulate Task for Codex

Write a detailed task specification that INCLUDES the CLAUDE.md context directly:

```
# Project Context
[Paste relevant sections from CLAUDE.md here]

# Task
[Clear description based on conversation context]

# Relevant Files
[List key files Codex should know about]

# Requirements
- [specific requirement 1]
- [specific requirement 2]

# Success Criteria
- [how to know it's done correctly]
```

Do NOT:

- Tell Codex how to implement (let it decide)
- Over-constrain the solution

DO:

- Clearly state if you expect some changes or if you are asking for review/feedback (eg. review technical document vs. rewrite it)
- Include CLAUDE.md context directly in the prompt
- Be specific about requirements
- State clear success criteria

### Step 4: Execute Codex

**CRITICAL: Choose the correct mode based on what the user wants.**

#### For IMPLEMENTATION (writing code):
```bash
codex exec --full-auto "YOUR_TASK_WITH_CONTEXT_HERE" 2>&1
```
`--full-auto` enables `--sandbox workspace-write` (can modify files) and `-a on-request` approval.

#### For REVIEW ONLY (reading and analyzing, no file changes):
```bash
codex exec -s read-only -o /tmp/codex-review-output.txt "YOUR_REVIEW_PROMPT" 2>&1
```
Then read `/tmp/codex-review-output.txt` for the structured review output.

`-s read-only` prevents ALL file writes. The `-o` flag saves the final response to a file (useful since output can be large).

**Always clarify with the user before choosing a mode.** When in doubt, use read-only. Implementation mode will modify files — only use it when explicitly requested.

### Step 5: Report Results

## Delegation Report

### Task Identified

[The task you identified from context]

### Context Provided

[Summary of CLAUDE.md context you included]

### What Codex Did

- Files created/modified
- Summary of changes

### Verification

- Did it meet the success criteria?
- Any issues encountered?

### Files Changed

[List with brief descriptions]

### Follow-up Needed

- [ ] Any remaining tasks
- [ ] Things to review

---

## Important

- YOU identify the task from conversation context
- Inject CLAUDE.md content DIRECTLY into the prompt (don't create AGENTS.md)
- If Codex fails, report what happened and suggest fixes
- You can run Codex multiple times with refined prompts
