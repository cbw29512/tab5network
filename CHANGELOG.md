# Changelog — Tab5 Network Tester

This is a **living, append-only record** of work, including features that are later changed or removed. Do not silently rewrite history. For a source change, include the GitHub commit/PR, actual tests run, and any unresolved issues. Date entries in ISO 8601.

## 2026-11-13 — Guarded Windows USB flashing workflow prepared (no device upload yet)
- Committed `scripts/Flash-Tab5Network.ps1` for explicit COM-port flashing: default is fail-closed build/preflight; `-Upload` plus typed confirmation triggers PlatformIO USB upload. Do not invoke full-chip erase.
- The script checks two independent 16MB firmware backup files and private TNK1 manifest SHA-256, ESP32-P4/16MB flash identity, and filters **only** `SECURE_BOOT_EN` and `SPI_BOOT_CRYPT_CNT` read-only eFuse values; refuses enabled/unreadable security features.
- It takes the expected display-controller input `ST7121` from the user's **earlier real device runtime logs** (board version 3; LCD ST7121 and ST712x touch). The physical rear sticker remains uninspected; on-device LCD/touch success still needs testing.
- The 512GB microSD remains inside the unit by operator preference. This first UI firmware has no application SD I/O, and PlatformIO programs ESP32-P4 internal flash rather than the SD. A separate SD backup is not verified and this residual risk remains visible.
- Updated build-only script to call `python -m platformio` rather than relying on `pio.exe` being on the Windows PATH. **Verified source-level:** GitHub Actions [firmware run 43458569970](https://github.com/cbw29512/tab5network/actions/runs/43458569970) passed C++ core, Windows PowerShell syntax and ESP32-P4 compile at `7e43329`; [documentation run 43458569726](https://github.com/cbw29512/tab5network/actions/runs/43458569726) passed. Actual Windows preflight, eFuse checks and upload remain pending.
- No upload, erase, factory recovery, SD formatting or observed touchscreen run is claimed.

## 2026-11-13 — On-screen buttons replace the face; user reports backup verified
- Product clarification: **no Pocket DM face/avatar, overlay or animated startup view**. The replacement firmware must boot straight to the six large on-screen diagnostic buttons, with Back returning to that same home screen. No additional physical button needed for navigation.
- Existing source already initializes the Home dashboard. Added explicit boot contract comment and source regression checks for all six button-to-details-to-home transitions.
- **User-reported:** the private double-read 16 MB flash backup has been verified. Only the first pass appeared in the supplied long log; final output and manifest have **not** been independently inspected here. No private hashes, backup files or identifying information committed.
- Next: preserve microSD separately, confirm LCD revision and flash recovery limitations before replacing old firmware. Device still runs previous firmware until explicitly flashed; on-device UI acceptance **not yet performed**.

## 2026-11-13 — First full flash read observed; verification remains open
- User-supplied laptop log shows `flash-pass1.bin` completed: **16,777,216 bytes**, read from address 0x00000000 using `esptool` in 133.9 seconds.
- The supplied excerpt contains **no** completed `flash-pass2.bin`, no hash comparison, and no final `PASS` or manifest creation. Record this as partial read-only backup progress only.
- Do not restart another backup while the existing script runs. Next checkpoint: final script output showing both matching hashes, separate microSD preservation, and recovery feasibility assessment. No firmware write reported.

## 2026-11-13 — ESP32-P4 chip confirmed and private backup tooling added
- **Operator-verified:** Windows COM3 is ESP32-P4 revision v1.3, 400 MHz, dual core + LP core; flash manufacturer 0x46/device 0x4018, **16 MB**. `esptool` 5.6.0 installed successfully. No data written; MAC intentionally excluded from public project history.
- Added `scripts/Backup-Tab5Flash.ps1`: on an explicitly chosen COM port, rechecks chip and flash size, reads entire flash twice into separate **private non-GitHub files**, verifies 16,777,216 bytes each and matching SHA-256, and writes a private manifest. No erase/write/upload/SD modification.
- Schema: private `TNK1-FLASH-BACKUP` manifest (`chip`, `flash_bytes`, two filenames, `matching_sha256`, `restoration_tested=false`, `micro_sd_backed_up=false`). Existing firmware and project report schema unchanged.
- Safeguards: refuses missing/wrong Espressif port, wrong chip/flash size, backup paths inside the repo, existing session folder, incomplete or inconsistent reads; sanitizes MAC from tool output. Partial or mismatched dumps are **not** marked successful.
- Tests: real `flash-id` passed; double-read backup itself **not executed**. GitHub PowerShell syntax/CI verification pending at this entry. Separate microSD backup and restoration readiness remain open. No flash performed.
- Next blocker: complete private dual-read firmware backup, preserve microSD, inspect LCD sticker before any flash.

## 2026-11-13 — Windows hardware preflight and log privacy repair
- Operator cloned the repository and checked out `feature/touch-ui-preflight-v0` on Windows. Initial inspection was blocked by Windows PowerShell's script policy; executing the reviewed script in a separate child process using `-ExecutionPolicy Bypass` succeeded, without changing permanent policy.
- Observed PowerShell 5.1, Git installed, Python 3.12 installed; `pio` not on PATH. A single serial device appeared on COM3 with Espressif VID/PID 303A/1001; no proof yet that this is the Tab5 until physical disconnect/reconnect or read-only `flash-id` confirmation.
- Source change: default USB output now omits the unique PNP device-instance suffix. The earlier raw inspection had exposed a device-instance string in chat; that unique identifier is **not** copied into the public repository.
- Setup documentation now describes process-scoped execution policy invocation, privacy rules and the next read-only hardware gate.
- Tests: operator successfully executed the original preflight locally; redaction change is not yet verified on the physical laptop. CI checks pending for this commit. No USB flash, backup, network probe or firmware overwrite.
- Next: confirm COM3 association and ESP32-P4 flash ID, inspect LCD sticker, preserve existing firmware and SD.

## 2026-11-13 — First touchscreen firmware source (unreleased)
- Commit: `63dbda1` on `feature/touch-ui-preflight-v0`; proposed PR pending.
- Added six large Tab5 touch hitboxes and actual UI navigation on M5Unified with honest unimplemented/scope-required result pages; **no network probes or fabricated measurements**.
- Added isolated pure C++ `Controller` and geometry logic, desktop C++ test executable, and GitHub Actions host plus PlatformIO compile jobs.
- Touch fix `8981e61`: evaluate `wasClicked()` without a `getCount() > 0` guard so release events are not discarded after the finger lifts (per M5Stack API example).
- Added the read-only `scripts/Inspect-Tab5.ps1` to discover USB ports/tools and optionally run an operator-initiated ESP32-P4 chip ID read. No flash writes.
- Commit `1c3f1de`: added `scripts/Build-Tab5Network.ps1` for a PowerShell-only build; hashes the binary and never uploads. Windows execution unverified.
- Commit `dcba4ec`: GitHub Actions adds a Windows PowerShell parser check, so syntax can be validated without touching a device. First run pending.
- Selected documented source tags: pioarduino 54.03.21, M5Unified 0.2.23, M5GFX 0.2.30. Build results and LCD revision are not yet certified at this entry.
- Schema/state change: first in-code `State {screen, selected, outcome, authorized_scope, generation}` with fail-closed host test authorization; no saved network targets or secrets.
- **Verified:** [GitHub Actions run 43451215326](https://github.com/cbw29512/tab5network/actions/runs/43451215326) passed all three jobs on source head `337995f` (C++ controller, Windows PowerShell parser, ESP32-P4 PlatformIO compile). [Documentation run 43451215856](https://github.com/cbw29512/tab5network/actions/runs/43451215856) also passed. No physical Tab5 testing performed.
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
