---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when building any features or fixing bugs, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass.

## The Test Value Principle

TDD is **extremely strongly recommended** — it is the default for all code changes. But every test must justify its existence by providing real value:

> WRITE TESTS THAT PROTECT AGAINST REGRESSIONS AND SURVIVE REFACTORING.A TEST THAT DOES NEITHER IS WASTE — SKIP IT.

**When to use TDD (strongly recommended — this is the default):**

- Behavioral logic — conditionals, calculations, state machines, data transformations
- Integration boundaries — how modules interact, API contracts, data flow across layers
- User-facing behavior — what happens when a user clicks, submits, navigates
- Complex wiring — anything where a mistake would silently produce wrong results

**When TDD does NOT add value (skip it, but document why):**

- Asserting type shapes the compiler already enforces (TypeScript interfaces, prop types)
- Asserting static configuration that only changes intentionally (column IDs, route paths)
- Pure prop-threading through thin wrappers/containers with zero logic
- Mechanical renames propagated through a component tree where the type checker is the safety net

When skipping TDD, state explicitly WHY in your task summary. The bar is: "Would this test catch a real bug that the compiler wouldn't?" If no → skip. If yes → TDD.

For changes spanning multiple files as one logical change, prefer ONE integration test that verifies the end-to-end behavior over per-file unit tests that test wiring.

## PRIMARY RULES YOU MUST ALWAYS FOLLOW

**Core principles**:

- Tests should verify behavior through public interfaces, not implementation details (treat testing module as blackbox). Code can change entirely; tests shouldn't.
- If you didn't watch the test fail, you don't know if it tests the right thing.
- Protection against regressions — test should fail when changing of the code causes regression
- Resistance to refactoring — test should still work if we change the implementation of tested unit
- Fast feedback — tests must be fast
- Maintainability — tests must be easy to maintain
- **Value** — every test must provide protection the type system and compiler cannot

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function and tests fail, those tests were testing implementation, not behavior.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Anti-Pattern

### Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

### Mocks and test-utils

When adding mocks or test utilities, read [anti-patterns.md](anti-patterns.md) to avoid common pitfalls:

- Testing mock behavior instead of real behavior
- Adding test-only methods to production classes
- Mocking without understanding dependencies

## Workflow

### 1. Planning

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Identify opportunities for [deep modules](deep-modules.md) (small interface, deep implementation)
- [ ] Design interfaces for [testability](interface-design.md)
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Confirm with the user exactly which behaviors matter most. Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Good Tests

| Quality      | Good                                | Bad                                               |
| ------------ | ----------------------------------- | ------------------------------------------------- |
| Minimal      | One thing. "and" in name? Split it. | test('validates email and domain and whitespace') |
| Clear        | Name describes behavior             | test('test1')                                     |
| Shows intent | Demonstrates desired API            | Obscures what code should do                      |

## Why Order Matters

**"I'll write tests after to verify it works"**

Tests written after code pass immediately. Passing immediately proves nothing:

- Might test wrong thing
- Might test implementation, not behavior
- Might miss edge cases you forgot
- You never saw it catch the bug

Test-first forces you to see the test fail, proving it actually tests something.

**"I already manually tested all the edge cases"**

Manual testing is ad-hoc. You think you tested everything but:

- No record of what you tested
- Can't re-run when code changes
- Easy to forget cases under pressure
- "It worked when I tried it" ≠ comprehensive

Automated tests are systematic. They run the same way every time.

**"Deleting X hours of work is wasteful"**

Sunk cost fallacy. The time is already gone. Your choice now:

- Delete and rewrite with TDD (X more hours, high confidence)
- Keep it and add tests after (30 min, low confidence, likely bugs)

The "waste" is keeping code you can't trust. Working code without real tests is technical debt.

**"TDD is dogmatic, being pragmatic means adapting"**

TDD IS pragmatic:

- Finds bugs before commit (faster than debugging after)
- Prevents regressions (tests catch breaks immediately)
- Documents behavior (tests show how to use code)
- Enables refactoring (change freely, tests catch breaks)

"Pragmatic" shortcuts = debugging in production = slower.

**"Tests after achieve the same goals - it's spirit not ritual"**

No. Tests-after answer "What does this do?" Tests-first answer "What should this do?"

Tests-after are biased by your implementation. You test what you built, not what's required. You verify remembered edge cases, not discovered ones.

Tests-first force edge case discovery before implementing. Tests-after verify you remembered everything (you didn't).

30 minutes of tests after ≠ TDD. You get coverage, lose proof tests work.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

