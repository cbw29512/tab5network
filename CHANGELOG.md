# Changelog — Tab5 Network Tester

This is a **living, append-only record** of work, including features that are later changed or removed. Do not silently rewrite history. For a source change, include the GitHub commit/PR, actual tests run, and any unresolved issues. Date entries in ISO 8601.

## 2026-11-13 — Project baseline
- Established separate repository `cbw29512/tab5network` (public).
- Selected MVP: visual, push-button Wi-Fi Scan, Devices, Ping, Port Test, DNS, Run All.
- Defined requirement for a Windows PowerShell laptop workflow over USB-C, with backup and safe restore of the previous Pocket DM firmware and SD card.
- Added initial requirements, architecture/data schema/state-machine design, hardware notes, Windows inspection procedure, recovery plan, tests, handoff policy and scope/security guide.
- **Verification level:** GitHub file commits only; no physical build or flash was performed.
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
