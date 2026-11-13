# Changelog — Tab5 Network Tester

This is a **living, append-only record** of work, including features that are later changed or removed. Do not silently rewrite history. For a source change, include the GitHub commit/PR, actual tests run, and any unresolved issues. Date entries in ISO 8601.

## 2026-11-13 — First touchscreen firmware source (unreleased)
- Commit: `63dbda1` on `feature/touch-ui-preflight-v0`; proposed PR pending.
- Added six large Tab5 touch hitboxes and actual UI navigation on M5Unified with honest unimplemented/scope-required result pages; **no network probes or fabricated measurements**.
- Added isolated pure C++ `Controller` and geometry logic, desktop C++ test executable, and GitHub Actions host plus PlatformIO compile jobs.
- Touch fix `8981e61`: evaluate `wasClicked()` without a `getCount() > 0` guard so release events are not discarded after the finger lifts (per M5Stack API example).
- Added the read-only `scripts/Inspect-Tab5.ps1` to discover USB ports/tools and optionally run an operator-initiated ESP32-P4 chip ID read. No flash writes.
- Selected documented source tags: pioarduino 54.03.21, M5Unified 0.2.23, M5GFX 0.2.30. Build results and LCD revision are not yet certified at this entry.
- Schema/state change: first in-code `State {screen, selected, outcome, authorized_scope, generation}` with fail-closed host test authorization; no saved network targets or secrets.
- Tests: committed C++ host tests and GitHub compile configuration; **results pending**. No physical Tab5 testing performed.
- Next blocker: inspect GitHub compile, verify connected Windows Tab5 COM/LCD/flash, create private backups before any flash.
- Release: none, previous firmware and SD untouched.

## 2026-11-13 — Project baseline
- Established separate repository `cbw29512/tab5network` (public).
- Selected MVP: visual, push-button Wi-Fi Scan, Devices, Ping, Port Test, DNS, Run All.
- Defined requirement for a Windows PowerShell laptop workflow over USB-C, with backup and safe restore of the previous Pocket DM firmware and SD card.
- Added initial requirements, architecture/data schema/state-machine design, hardware notes, Windows inspection procedure, recovery plan, tests, handoff policy and scope/security guide.
- Added docs/DECISIONS.md for decisions, reversals and feature removals; PROJECT_STATE.md for verified current status; CONTRIBUTING.md for the update policy.
- Added automated documentation integrity and source-change gate (scripts/check_docs.py; .github/workflows/documentation.yml).
- **Verified:** [Documentation CI run 43448788566](https://github.com/cbw29512/tab5network/actions/runs/43448788566) passed on commit b288277; this validates files and local links, not real device operation.
- **Verification level:** GitHub file commits and documentation CI only; no firmware build, physical test or flash performed.
- **Open blockers:** exact board LCD driver, USB device identification, flash backup, SD backup, build toolchain verification, firmware prototype, network tests.
- **Release status:** no tag / no working release.

## New entry template
```markdown
## YYYY-MM-DD — <feature, fix, or removal>
- Commit/PR:
- Before → after behavior:
- Data schema or state changes:
- Hardware and toolchain:
- Tests run and actual results:
- Documentation changed:
- Known limitations and next blocker:
- Release impact: unreleased / candidate / tagged
```
