# Architectural Defaults for Tech Specs

These are default preferences when designing new components or modules. They favor code that is easy to maintain, evolve, debug, read, and test over years in production.

**Override clause:** Codebase conventions win. If the codebase already solves a concern (DB access, error handling, validation, transport) one specific way, follow it — even if it conflicts with the defaults below. Introducing alien concepts for "purity" creates friction and surprises future readers; pattern reuse compounds. Document any deviation from defaults in the spec's Trade-Off Analysis ("we follow existing pattern X here, not the default Y, because...").

---

## 1. Hexagonal / Clean Architecture

- Domain logic has no knowledge of infrastructure
- Infrastructure (DB, HTTP, queues, external APIs, file system) injected as a dependency behind interfaces
- Should be possible to swap DB or transport (REST↔GraphQL) at the infra layer without changing domain code
- Module structure should reveal the domain ("screaming architecture"), not the framework

## 2. Always-Valid Domain

- Validate inputs and assert invariants at the infrastructure boundary or use-case entry point
- Inside domain logic, work with already-valid data — eliminate "is it valid?" branches in business logic
- Make impossible states unrepresentable in types

## 3. Error as Data

- After the infra boundary, return explicit error values (Result types, discriminated unions)
- Throwing is reserved for truly exceptional or programmer-error conditions (assertion failures, bugs)
- The function signature should reveal the possible outcomes — no surprise exceptions

## 4. Discriminated Unions over Optional Flags

- Prefer `{ kind: 'success', data }` / `{ kind: 'failure', error }` over `{ data?, error?, isError? }`
- A caller cannot construct an impossible state by mixing properties

## 5. Simple > Clever

- Boring, obvious code wins
- A few extra lines that make data flow explicit beats a clever one-liner that needs a comment
- YAGNI and KISS apply at design time too — no layers for hypothetical needs
- "Senior" doesn't mean "show off skills"; it means "reduce surprise for the next reader"

## 6. Coupling and Cohesion

- High cohesion within modules, low coupling between
- Few large modules with clear APIs beat many tiny boxes you have to chase across files
- Public surface area should be small; internals can be rich

## 7. Reversibility

- Prefer designs that don't close doors
- For irreversible decisions (DB choice, public API contract, breaking schema change), explicitly document trade-offs and migration cost in the spec
- "We can change this later" is a claim — verify it before committing

## 8. Test-Reachable Design

- Pick the highest test level with the best effort/impact ratio for each concern
  - Pure logic: unit tests
  - Module integration: integration tests (real adapters where cheap)
  - Cross-system / UX: end-to-end (sparingly)
- Don't push everything to e2e; don't unit-test what only matters at integration
- Design seams where mocks and fakes go cleanly (interfaces at the infra boundary)
- If the design makes testing hard, the design is wrong — fix the design, not the test
- Each interface should have behavior-level test cases identified before implementation begins

## 9. Orthogonality

- Components should change independently — modifying one shouldn't ripple through others
- Knobs and switches that interact in non-obvious ways are a code smell

## 10. Crash Early at Boundaries

- Detect bad input at the boundary and reject it immediately with a clear error
- Don't let invalid data propagate deeper, where the failure point will be far from the cause

---

## Sources for Future Expansion

- *The Pragmatic Programmer* (Hunt, Thomas) — orthogonality, reversibility, tracer bullets, design by contract
- *Domain-Driven Design* (Evans) — bounded contexts, ubiquitous language, aggregates
- *Clean Architecture* (Martin) — dependency inversion, ports and adapters
- *Working Effectively with Legacy Code* (Feathers) — seams, sprout/wrap patterns
- *Refactoring* (Fowler) — primitive obsession, feature envy, module boundaries

This list is intentionally short. Expand only when a recurring decision benefits from a documented default.
