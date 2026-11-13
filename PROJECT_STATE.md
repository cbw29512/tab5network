# Project State — read before every change

**Project:** Tab5 Network Tester (working name Pocket Kali)  
**Last reviewed:** 2026-11-13  
**Source of truth:** GitHub `cbw29512/tab5network` main branch  
**Current phase:** Touch UI source compiled and guarded Windows flashing script committed; physical Tab5 installation, touchscreen operation and network diagnostics remain NOT verified.

## Current verified facts
- User selected a visual six-button touchscreen network tester, standalone for basic tests.
- Development host is a **Windows laptop connected by USB** to an existing M5Stack Tab5.
- Repository `cbw29512/tab5network` exists, and is **public**.
- The Tab5 previously hosted Pocket DM; preservation of the old firmware and SD contents takes priority over new flashing.
- Manufacturer documents ESP32-P4 main controller, ESP32-C6 2.4 GHz radio, 16 MB flash, 32 MB PSRAM and 1280×720 touch display. LCD driver revision varies.
- Full initial documentation and living-change workflow are committed to GitHub.
- Feature branch `feature/touch-ui-preflight-v0` commit `63dbda1` contains the first source-level ESP32-P4 touch dashboard and read-only Windows USB inspection script. Build-only PowerShell script added at commit `1c3f1de` (prints SHA-256; does not flash).
- Dashboard has six large touch buttons, geometry-tested hit detection, and honest Scope Required / Unsupported result screens. **No network scans or packets are implemented.**
- Touch release handling patched at `8981e61` to avoid suppressing `wasClicked()` after finger lift; physical verification is still required.
- PlatformIO config pins documented M5Stack-supported upstream tags. Earlier baseline CI run `43450548417` passed both pure C++ core tests and a Linux PlatformIO ESP32-P4 compile. Latest commits (including touch-event fix and PowerShell checker) need fresh final-head checks before claiming readiness.
- **Verified:** GitHub Actions [firmware run 43451215326](https://github.com/cbw29512/tab5network/actions/runs/43451215326) passed on head `337995f`: all three jobs green — C++ unit tests, Windows PowerShell script syntax and ESP32-P4 PlatformIO build. Separate [documentation run 43451215856](https://github.com/cbw29512/tab5network/actions/runs/43451215856) passed. These are CI source checks, NOT an on-device test.
- **Verified user Windows inspection, 2026-11-13:** Git clone and feature branch switch succeeded; `Inspect-Tab5.ps1` ran successfully after process-local execution policy bypass. PowerShell 5.1; Git present; Python 3.12 present; `pio` not on PATH. Exactly one USB serial device enumerated: **COM3**, Espressif **VID_303A/PID_1001**. This remains a **candidate Tab5 port**, not ESP32-P4 chip-ID proof. Unique PNP device-instance string deliberately not recorded in GitHub.
- **Verified ESP32-P4 flash identification (Windows, 2026-11-13):** esptool 5.6.0 on COM3 reported ESP32-P4 revision **v1.3**, dual core + LP core, **400 MHz** and **16 MB flash** (manufacturer 0x46, device 0x4018). This supersedes the earlier candidate-port-only status; device MAC intentionally excluded from public records. No write/erase occurred.
- Added guarded `scripts/Backup-Tab5Flash.ps1` to take **two independent 16 MB read-only flash dumps**, confirm size and matching SHA-256, then save a **private** manifest outside the public repo. **The backup script has now run on the laptop: the shared log confirms the first full 16 MB read completed, but does not show a second completed read or matching hashes. Backup verification remains PENDING.**
- Physical LCD revision, private flash backup, separate microSD backup, restoration test, and firmware flashing remain pending.
- Documentation check is active in GitHub Actions: [run 43448788566](https://github.com/cbw29512/tab5network/actions/runs/43448788566) **passed** (source Markdown integrity only, not firmware tests).
- Code pull requests changing source/tests/build scripts require changes to both PROJECT_STATE.md and CHANGELOG.md, enforced by scripts/check_docs.py.

## Not verified / not implemented
- Current COM3 chip identity and 16 MB flash size **confirmed**; exact LCD/touch revision, flash protection/eFuse state and existing firmware backup **not yet verified**.
- Local PlatformIO still missing from PATH; Python 3.12 and esptool 5.6.0 verified working on Windows.
- Firmware source for touchscreen preview exists; actual firmware build, physical touch, Wi-Fi and network diagnostics are unverified.
- SD-card logging, portable report export, NucBox integration or software release.
- Real hardware acceptance tests and USB flashing/restore.
- Actual verified build binaries, flash/restore tests or release tags. Toolchain versions have been selected from upstream documentation but are not yet a successful build.

- **User-verified 2026-11-13:** the operator reported the private two-pass firmware backup as verified. The final PASS/hash output was not independently supplied or inspected; record this as **user-reported verified**, not independently certified. Continue to protect the private images and do not commit them to GitHub.
- **Startup UI contract:** the former Pocket DM face/avatar will not appear in the replacement firmware. Six touch buttons are the home screen immediately after display initialization; physical installation/testing pending.
- **Prior physical-runtime observation, 2026-11-11:** the user's existing Tab5 boot logs reported board version 3, **LCD ST7121 / ST712x touch**. This is software-reported evidence rather than the rear-sticker marking; no controller model inferred from the ESP32-P4 chip itself.
- **Guarded installation script committed, 2026-11-13:** `scripts/Flash-Tab5Network.ps1` checks private double-read backup and hashes, ESP32-P4/16MB COM port, security eFuses, expected ST7121 runtime variant and build; defaults to no upload and requires `-Upload` plus typed confirmation before writing. New firmware CI and on-laptop execution pending.
- The operator has previously specified that the 512GB microSD **stays in the Tab5**. The replacement source contains no direct microSD access and the upload tool programs ESP32-P4 internal SPI flash; there is no evidence of an independent microSD copy. Preservation and residual recovery risks remain documented.

## Locked product decisions
1. Touch-first UI with large buttons. No terminal entry on the Tab5.
2. Six MVP controls: Wi-Fi Scan, Devices, Ping, Port Test, DNS, Run All.
3. Display actual measured values and live progress; label unsupported/partial clearly.
4. Authorized subnet / selected host before network probing; bounded tests; cancel.
5. Works without NucBox for ordinary MVP testing. NucBox advanced extensions optional later.
6. Preserve previous firmware and microSD; no destructive flash until independent backup gate passes.
7. GitHub is canonical. Every feature/change/removal updates documentation with code.

## Immediate next work item (one at a time)
**Bring up the guarded Windows preflight first, then explicitly upload only after its gates pass.** A previous runtime log already reports ST7121 LCD; the script independently validates the private dual-read flash backup and secure boot/encryption state. The operator wants to retain the microSD in the unit; the preview has no SD access, but separate microSD backup is unverified. Use `-Upload` with explicit typed confirmation only after the preflight checks succeed. Preserve the created directory privately and report only PASS/FAIL, backup sizes, and matching hash (not raw images or private device identifiers). Independently back up the microSD, record LCD sticker revision, and assess secure-boot/flash-encryption restoration limitations. No firmware upload until all backup and restore gates are met.

## Evidence for next milestone
- Redacted Windows port listing; exact LCD sticker text.
- **Completed:** ESP32-P4 v1.3, 16 MB flash, COM3 identification via esptool 5.6.0.
- Local private flash backup with file length and SHA-256 plus private SD backup manifest.
- Rehearsed or justified recovery strategy.
- State documentation update and decision record with any hardware constraints.

## Change discipline
**At the start of every new coding session**: read this file, README.md, DEFINITION_OF_DONE.md, ARCHITECTURE.md, TEST_PLAN.md, and relevant hardware contracts. Inspect current HEAD, open PRs and tests. At the end of **each meaningful GitHub change**: update this file with verified progress/blockers, CHANGELOG.md with what changed, and docs/DECISIONS.md for design changes/removals. Unverified progress stays labeled pending; never silently mark a feature complete. Commit code/tests/docs together when possible. See CONTRIBUTING.md.
