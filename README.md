# Skills

My personal set of AI-agent skills for structured software development — mostly an
**OMT** ("one more thing") workflow that runs a feature from idea to merge: scaffold →
PRD → tech spec → task breakdown → TDD execution → reflection, plus a few standalone
review/fix helpers.

> ⚠️ **Heavily WIP and personal.** These are tuned to my own machine, conventions, and
> habits. They probably **won't work out of the box** for you — paths, tools, and
> assumptions will need adjusting. I'm sharing them for **inspiration**, not as a
> finished product. Fork, copy ideas, ignore the rest.

## Layout

Each skill is a folder with a `SKILL.md` (the instructions the agent reads). Some bundle
their own assets:

- `omt-*` — the core feature-delivery workflow (start at `omt-scaffold-feature`).
- `omt-scaffold-feature/` — bundles the canonical `templates/` and a `bin/bootstrap-task`
  script; other omt skills reference those templates.
- `omt-create-tech-spec/agents/` — research subagent definitions used during spec writing.
- `tdd/`, `fix-review/`, `review-*`, `posting-gitlab-mr-inline-comments/` — standalone helpers.

The worked examples in the skills are genericized; the concepts (tracer bullets,
risk-first ordering, integration-boundary inventories) are the point.

## Using them

Written as `SKILL.md` files (Claude Code convention), but they're just structured
prompts — usable with any coding agent. For Claude Code:

```bash
bin/setup   # records your tasks-vault location and (optionally) symlinks skills into ~/.claude/skills
```

The tasks-vault (where feature folders live) is resolved from `--vault`,
`$OMT_TASKS_VAULT`, or `~/.config/omt/config` — no hardcoded paths.

## License

MIT — see [LICENSE](./LICENSE).
