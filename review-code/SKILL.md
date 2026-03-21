---
description: "Review a PR or branch: accepts a branch name or GitLab PR URL"
argument-hint: "<branch-name or PR-URL>"
allowed-tools:
  ["Bash", "Glob", "Grep", "Read", "Task", "AskUserQuestion", "Edit", "Write"]
---

# Review: $ARGUMENTS

You are reviewing code changes for the given branch or PR. The input is: **$ARGUMENTS**

## Step 1: Determine the target branch

Parse `$ARGUMENTS` to figure out what to review:

- If it looks like a GitLab MR URL (contains `/merge_requests/`), extract the PR number and use `glab` CLI to get the branch name and base branch.
- If it looks like a PR number (just digits), use `glab` CLI.
- Otherwise, treat it as a branch name directly. The base branch is `main` or `master` (verify this).

Store the **head branch name** and **base branch name** for later steps.

## Step 2: Set up a worktree

1. Run `git worktree list` to check if a worktree already exists for the target branch.
2. If one exists, `cd` into it and run `git pull`.
3. If not, create one: `git worktree add ../<repo-name>-review-<branch> <branch>` (fetch the branch first if needed with `git fetch origin <branch>`).
4. Inside the worktree, make sure main is up to date: `git fetch origin main`.

## Step 3: Gather the diff

Run the following to understand all changes:

```
git diff origin/main...HEAD --stat
git diff origin/main...HEAD
```

If this is a PR, also run:

```
gh pr diff <number>
```

Read any modified files fully if needed for context. Focus on understanding what changed and why.

## Step 4: Find relevant CLAUDE.md files

Look for CLAUDE.md files at:

- The repository root
- Any directories containing modified files

Read them to understand project conventions and guidelines.

## Step 5: Present a high-level overview

Before diving into individual snippets, present the user with a **general overview** of the PR:

1. **Written summary** -- 3-5 sentences describing what this PR does at a high level: the motivation, the approach taken, and the key areas of the codebase it touches. Mention the number of files changed, any new dependencies, and whether it's a feature, bugfix, refactor, etc.

2. **Architecture / flow diagram** -- generate a Mermaid diagram (in a fenced `mermaid` code block) that shows how the changed components fit together. Choose the diagram type that best fits the changes:
   - **flowchart/graph** -- for request flows, data pipelines, or control flow across services
   - **sequence diagram** -- for multi-step interactions between components (API calls, event chains)
   - **class diagram** -- for type/interface changes and their relationships

   Focus the diagram on **what this PR changes or introduces**, not the entire system. Highlight new components or modified paths. Keep it readable -- no more than ~15 nodes. If the PR is too small or trivial for a diagram to add value (e.g., a one-line config change), skip it.

3. **Key questions / first impressions** -- note any high-level concerns or open questions before getting into details (e.g., "This adds a new polling loop but I don't see a shutdown path" or "The migration is backwards-compatible").

Wait for the user to acknowledge the overview before proceeding to snippets.

## Step 6: Interactive snippet-by-snippet walkthrough

Instead of dumping the full review at once, walk the user through the diff **snippet by snippet**. This is the preferred review flow:

1. **Organize snippets logically** -- group by area/concern, not by file order. Start with foundational changes (types, interfaces, shared modules) before the code that uses them. Number each snippet (e.g., "Snippet 3/12") so the user knows their progress.

2. **For each snippet, present:**
   - The relevant diff or code block (trimmed to the essential parts, not the entire file)
   - A plain-language explanation of what's happening and why
   - What's good about the approach
   - What's concerning or could be improved (be specific -- name the issue, explain the consequence)

3. **Wait for the user's response after each snippet.** The user may:
   - Leave a rough comment or note -- **store it** as a collected review comment and confirm you noted it, then move to the next snippet
   - Ask questions -- answer them, then continue
   - Say "move on" / "next" -- proceed to the next snippet

4. **Track all collected comments** as you go. Maintain an internal list with:
   - The file path and approximate line
   - The severity (Critical / Important / Suggestion / Nitpick)
   - The comment text (refined from the user's rough notes into clear, actionable language)

## Step 7: Common review patterns to watch for

When reviewing, pay special attention to these recurring issues:

### Consistency

- **Hardcoded strings vs constants** -- when one file uses constants and another hardcodes the same values, flag it
- **Inconsistent patterns across similar files** -- if two files implement the same pattern, they should do it the same way (e.g., both using typed returns, both using the same imports)
- **Return type looseness** -- `any[]` or untyped returns when a specific type is available

### Architecture

- **Code duplication across files** -- large blocks of similar logic that could be extracted into a shared helper
- **Half-wired integrations** -- mechanical integration (code structure is there) without semantic integration (prompts, config, documentation don't match)
- **Silently removed behavior** -- features/logic that existed before and are removed without mention in the PR description

### Naming & Types

- **Misleading names** -- types or functions whose names don't match what they actually contain or do
- **Unaccounted config values** -- numeric configs that don't add up or have unexplained gaps

### LLM/AI-specific (when reviewing AI agent code)

- **Tool returns success but system overrides later** -- tools that always return success when the orchestrator may block the action, creating a confusing experience for the model
- **Missing prompt instructions for new capabilities** -- adding tools/mechanics without updating the system prompt to explain them to the model
- **Duplicated content in context window** -- the same information surfaced twice (e.g., in tool results and in injected messages), wasting tokens
- **Multiple injected messages in a row** -- several consecutive `role: 'user'` messages that could confuse the model about who's speaking

### Log Levels & Observability Cost

- **Informational logs that should be debug** -- Logs should only be exported if they help detect anomalies or system misbehavior. Any log that merely confirms the system is operating as expected (e.g., "request received", "processing started", "cache hit", "successfully completed X", "connecting to Y") should be `.debug`, not `.info` or higher. Debug logs are not exported to Datadog. Flag every `.info` / `.log` / `logger.info` / `log.info` / `console.log` (in production paths) that is purely informational and suggest demoting it to `.debug` / `logger.debug` / `log.debug`.
- **Noisy success-path logging** -- repeated per-request or per-item info logs inside loops or hot paths are especially costly. These should almost always be debug level.
- **Appropriate log levels for actual issues** -- conversely, make sure genuine warnings and errors are NOT being logged at debug/info. Errors, timeouts, retries, and unexpected states should be `.warn` or `.error`.

### Maintenance

- **Hardcoded sets/lists that must be manually maintained** -- suggest co-locating the metadata with the thing it describes (e.g., a tool declaring its own category rather than a central registry)

## Step 8: Consolidate and publish comments

After walking through all snippets, present the **full collected comment list** to the user, organized by severity:

1. **Critical / Important** -- must address before merge
2. **Suggestions** -- would improve the code but not blocking
3. **Nitpicks** -- minor style/naming/consistency issues

For each comment, show:

- **File and line reference**
- **Clear description** of the issue
- **Suggested fix** (when applicable)

Ask the user if they want to refine any comments before publishing.

When the user says to publish, post all comments as a **single GitLab MR review with inline comments**:

## Output format (for the final consolidated view)

### Summary

<1-3 sentence overview>

### Collected Comments

#### Critical / Important

For each:

- **File**: `path/to/file:line`
- **Description**: What the issue is
- **Suggestion**: How to fix it

#### Suggestions

<same format>

#### Nitpicks

<same format>

### Verdict

One of:

- **Ship it** -- no issues found, looks good
- **Needs changes** -- issues found that should be addressed before merging
- **Needs discussion** -- architectural or design concerns that need team input
