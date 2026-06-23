---
name: review-patrik
description: Use when reviewing frontend code with strict, nitpicky standards before committing or opening an MR. Catches 12 real patterns from 770+ historical review comments. Triggers on "patrik review", "strict review", "nitpick my code", or when you want to pre-empt human reviewer feedback.
---

# Strict Frontend Review — "Patrik"

Data-driven code review that checks for 12 patterns extracted from 770+ real human review comments across 89 MRs.

## When to Use

- Before committing or opening an MR
- When you want strict, nitpicky feedback
- To pre-empt human reviewer comments
- After AI-assisted coding sessions (pattern P8 specifically catches uncleaned AI artifacts)

## Process

1. **Determine scope**: get the diff via `git diff main...HEAD` (or specific files if provided)
2. **Read full changed files** — not just the diff
3. **Spawn the patrik agent**:
   - `subagent_type="patrik"` (defined in `.claude/agents/patrik.md`)
   - Pass: the diff, full file contents, and any project conventions (CLAUDE.md)
   - The agent applies all 12 review patterns and reports findings by severity

## The 12 Patterns (quick reference)

| # | Pattern | Frequency |
|---|---------|-----------|
| P1 | Use existing codebase utilities | 49 hits / 38 MRs |
| P2 | Code organization / separation of concerns | 49 / 26 |
| P3 | Unnecessary code / dead code | 44 / 30 |
| P4 | GraphQL naming & schema conventions | 42 / 19 |
| P5 | TypeScript types & unnecessary casts | 24 / 16 |
| P6 | Naming & clarity | 24 / 15 |
| P7 | Prefer simpler declarative patterns | 22 / 17 |
| P8 | AI-generated code not matching conventions | 19 / 17 |
| P9 | Missing i18n/lingui translations | 15 / 7 |
| P10 | Missing/silent error handling | 14 / 9 |
| P11 | Use Flamingo design system | 9 / 7 |
| P12 | Memoization: unstable references | 8 / 8 |

## Data Source

Patterns extracted from `.ai/review-patterns-analysis.md`. Raw data in `.ai/mr-review-comments.json`. Pattern-to-comment mapping in `.ai/classified-comments.json`.
