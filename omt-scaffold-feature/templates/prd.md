---
feature: {{FEATURE_NAME}}
jira_id: {{JIRA_ID}}
status: {{STATUS}}
created: {{DATE}}
type: prd
---

# PRD: {{FEATURE_NAME}}

## Problem Statement

_What user problem are we solving? Why is this valuable now?_

## Proposed Solution

### High-Level Flow

```
1. [First step in user journey]
2. [Next step]
3. [...]
```

### What Changes

| Area | Current State | Target State |
|------|--------------|--------------|
| _area 1_ | _how it works today_ | _how it should work_ |
| _area 2_ | _..._ | _..._ |

### Scope

**In scope:**

- _Concrete capability 1_
- _Concrete capability 2_

**Out of scope (YAGNI):**

- _Feature X_ — reason: not needed for v1
- _Integration Y_ — reason: deferred

## Impact on Existing Flows

_How does this affect features that already work?_

## Key File References

_Known relevant files (filled by Product Owner or Tech Lead during research):_

| Component | File |
|-----------|------|
| _component name_ | `path/to/file` |

## Questions & Assumptions

### Questions

| # | Question | Status | Answer |
|---|----------|--------|--------|
| Q1 | _Question raised during PRD creation_ | `PENDING` | _Fill when resolved_ |
| Q2 | _..._ | `RESOLVED` | _Answer_ |

### Assumptions

| # | Assumption | Status | Risk if wrong | Validation |
|---|-----------|--------|---------------|------------|
| A1 | _What we assume to be true_ | `CONFIRMED` / `UNCONFIRMED` | _Impact_ | _How to verify_ |

## Acceptance Criteria

_Numbered, testable, **user-observable** outcomes. Each must be verifiable end-to-end through the real entry point (the screen / API / command the user or caller hits) — not an implementation step, and not something a partial or dead-code implementation could satisfy on paper. The tech-spec maps each AC to a test; each task references the AC ids it advances._

- **AC1:** _user-observable outcome, verifiable end-to-end (e.g. "editing a referenced value and publishing shows the impacted tables in the dialog")_
- **AC2:** _..._

## Success Metrics

_Measurable targets (adoption, performance, error rate). Distinct from Acceptance Criteria above — metrics gauge success after release; ACs gate "is it done"._

- **Metric 1:** _measurable target_
- **Metric 2:** _measurable target_

## Approval

- [ ] Product Owner reviewed
- [ ] User approved scope
- [ ] Questions resolved or tracked
- [ ] Ready for Tech Spec

---

**Next step:** Run `omt-create-tech-spec` to create technical specification
