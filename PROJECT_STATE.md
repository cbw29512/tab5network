# Project State — read before every change

**Project:** Tab5 Network Tester (working name Pocket Kali)  
**Last reviewed:** 2026-11-13  
**Source of truth:** GitHub `cbw29512/tab5network` main branch  
**Current phase:** Requirements and documentation baseline; **no network-testing firmware has been built or flashed**.

## Current verified facts
- User selected a visual six-button touchscreen network tester, standalone for basic tests.
- Development host is a **Windows laptop connected by USB** to an existing M5Stack Tab5.
- Repository `cbw29512/tab5network` exists, and is **public**.
- The Tab5 previously hosted Pocket DM; preservation of the old firmware and SD contents takes priority over new flashing.
- Manufacturer documents ESP32-P4 main controller, ESP32-C6 2.4 GHz radio, 16 MB flash, 32 MB PSRAM and 1280×720 touch display. LCD driver revision varies.
- The project documentation and workflow baseline are being committed to GitHub.

## Not verified / not implemented
- Current Tab5 COM port, exact LCD/touch hardware revision, flash security configuration and old firmware backup.
- Local Windows PlatformIO/Python/esptool versions and matching drivers.
- Working touchscreen firmware or runtime diagnostics.
- SD-card logging, portable report export, NucBox integration or software release.
- Real hardware acceptance tests and USB flashing/restore.
- Toolchain pins, built binaries or release tags.

## Locked product decisions
1. Touch-first UI with large buttons. No terminal entry on the Tab5.
2. Six MVP controls: Wi-Fi Scan, Devices, Ping, Port Test, DNS, Run All.
3. Display actual measured values and live progress; label unsupported/partial clearly.
4. Authorized subnet / selected host before network probing; bounded tests; cancel.
5. Works without NucBox for ordinary MVP testing. NucBox advanced extensions optional later.
6. Preserve previous firmware and microSD; no destructive flash until independent backup gate passes.
7. GitHub is canonical. Every feature/change/removal updates documentation with code.

## Immediate next work item (one at a time)
**Complete the non-destructive Tab5 Windows preflight.** Obtain physical board revision and USB COM identification, inspect boot/flash details, and create privately stored verified flash and SD backups. Only then prepare a touch-only screen build and guarded USB flashing scripts. Do not claim those steps have happened until logs/hashes are reviewed.

## Evidence for next milestone
- Redacted Windows port listing; exact LCD sticker text.
- Safely verified ESP32-P4 flash ID and storage size.
- Local private flash backup with file length and SHA-256 plus private SD backup manifest.
- Rehearsed or justified recovery strategy.
- State documentation update and decision record with any hardware constraints.

## Change discipline
**At the start of every new coding session**: read this file, README.md, DEFINITION_OF_DONE.md, ARCHITECTURE.md, TEST_PLAN.md, and relevant hardware contracts. Inspect current HEAD, open PRs and tests. At the end of **each meaningful GitHub change**: update this file with verified progress/blockers, CHANGELOG.md with what changed, and docs/DECISIONS.md for design changes/removals. Unverified progress stays labeled pending; never silently mark a feature complete. Commit code/tests/docs together when possible. See CONTRIBUTING.md.
