# Contributing and living-document workflow

## Before any code
1. Pull/review current `main` and any open PRs. Read PROJECT_STATE.md first.
2. Check DEFINITION_OF_DONE.md, ARCHITECTURE.md, TEST_PLAN.md, HARDWARE.md, SECURITY.md and any relevant source contracts.
3. For a feature, define/modify **data schema and state transitions first**, then specify errors, permissions, timeouts and observability.
4. Confirm the test plan covers the new behavior *before implementation*. Never invent APIs or library support; check official SDK docs.
5. Keep source files modular (target **≤150 lines** each); split larger modules.

## Every change must include
- Code and tests where appropriate, with explicit error handling and meaningful diagnostic logging (without secrets).
- Current documentation reflecting **what truly works**; distinguish source tests from hardware acceptance.
- A CHANGELOG.md entry with source commit/PR, changed behavior, verification and limitations.
- Updated PROJECT_STATE.md: exact verified milestone, blocked tasks and next single action.
- A new or superseding ADR in docs/DECISIONS.md when scope, behavior, dependency, security, schema or architecture changes.
- Updated setup/flash/handoff instructions if installation or recovery is impacted.

## Removing features
Do not just delete. Add a CHANGELOG removal entry and ADR explaining the reason, test coverage deleted or replaced, effect on stored data, migration path and UI changes. Update Definition of Done and acceptance plan if requirements change. Keep historical entries.

## Verify and label claims
- **Implemented:** code committed, not necessarily working.
- **Source tested:** automated tests actually passed on a stated commit.
- **Hardware tested:** observed on a specific Tab5 revision with supporting redacted evidence.
- **Released:** version tag, verifiable binary hash and completed acceptance matrix.
Do not collapse these levels into a general 'done'.

## Branching and merge
Use short feature branches and pull requests when feasible. Merge only after required tests and documentation checks. Tag only an approved device-tested release. If work must remain incomplete, record it as blocked and do not present simulated screenshots as real test output.

## Review checklist
- [ ] Target scope authorized and bounded
- [ ] Existing recovery preserved
- [ ] Schemas/state and error paths updated
- [ ] Tests run; commands/results recorded
- [ ] No credentials, firmware dumps or private reports in commit
- [ ] README/SETUP/FLASH/ARCHITECTURE/HANDOFF updated where affected
- [ ] PROJECT_STATE.md and CHANGELOG.md updated
- [ ] New ADR for any significant change/removal
