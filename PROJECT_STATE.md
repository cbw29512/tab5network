# Project State — read before every change

**Project:** Tab5 Network Tester (working name Pocket Kali)  
**Last reviewed:** 2026-11-13  
**Source of truth:** GitHub `cbw29512/tab5network` main branch  
**Current phase:** Initial TOUCH UI firmware source committed on a feature branch; firmware build and physical USB flashing have NOT been verified.

## Current verified facts
- User selected a visual six-button touchscreen network tester, standalone for basic tests.
- Development host is a **Windows laptop connected by USB** to an existing M5Stack Tab5.
- Repository `cbw29512/tab5network` exists, and is **public**.
- The Tab5 previously hosted Pocket DM; preservation of the old firmware and SD contents takes priority over new flashing.
- Manufacturer documents ESP32-P4 main controller, ESP32-C6 2.4 GHz radio, 16 MB flash, 32 MB PSRAM and 1280×720 touch display. LCD driver revision varies.
- Full initial documentation and living-change workflow are committed to GitHub.
- Feature branch `feature/touch-ui-preflight-v0` commit `63dbda1` contains the first source-level ESP32-P4 touch dashboard and read-only Windows USB inspection script.
- Dashboard has six large touch buttons, geometry-tested hit detection, and honest Scope Required / Unsupported result screens. **No network scans or packets are implemented.**
- PlatformIO config pins documented M5Stack-supported upstream tags; GitHub compile validation is pending as this entry is written.
- Documentation check is active in GitHub Actions: [run 43448788566](https://github.com/cbw29512/tab5network/actions/runs/43448788566) **passed** (source Markdown integrity only, not firmware tests).
- Code pull requests changing source/tests/build scripts require changes to both PROJECT_STATE.md and CHANGELOG.md, enforced by scripts/check_docs.py.

## Not verified / not implemented
- Current Tab5 COM port, exact LCD/touch hardware revision, flash security configuration and old firmware backup.
- Local Windows PlatformIO/Python/esptool versions and matching drivers.
- Firmware source for touchscreen preview exists; actual firmware build, physical touch, Wi-Fi and network diagnostics are unverified.
- SD-card logging, portable report export, NucBox integration or software release.
- Real hardware acceptance tests and USB flashing/restore.
- Actual verified build binaries, flash/restore tests or release tags. Toolchain versions have been selected from upstream documentation but are not yet a successful build.

## Locked product decisions
1. Touch-first UI with large buttons. No terminal entry on the Tab5.
2. Six MVP controls: Wi-Fi Scan, Devices, Ping, Port Test, DNS, Run All.
3. Display actual measured values and live progress; label unsupported/partial clearly.
4. Authorized subnet / selected host before network probing; bounded tests; cancel.
5. Works without NucBox for ordinary MVP testing. NucBox advanced extensions optional later.
6. Preserve previous firmware and microSD; no destructive flash until independent backup gate passes.
7. GitHub is canonical. Every feature/change/removal updates documentation with code.

## Immediate next work item (one at a time)
**First verify the GitHub host tests and PlatformIO compile. Then run `scripts/Inspect-Tab5.ps1` from Windows (read-only by default)** to record the physical LCD revision and USB COM identifier, and safely prepare private verified flash/microSD backups before any flashing. The source is not yet an approved flash candidate.

## Evidence for next milestone
- Redacted Windows port listing; exact LCD sticker text.
- Safely verified ESP32-P4 flash ID and storage size.
- Local private flash backup with file length and SHA-256 plus private SD backup manifest.
- Rehearsed or justified recovery strategy.
- State documentation update and decision record with any hardware constraints.

## Change discipline
**At the start of every new coding session**: read this file, README.md, DEFINITION_OF_DONE.md, ARCHITECTURE.md, TEST_PLAN.md, and relevant hardware contracts. Inspect current HEAD, open PRs and tests. At the end of **each meaningful GitHub change**: update this file with verified progress/blockers, CHANGELOG.md with what changed, and docs/DECISIONS.md for design changes/removals. Unverified progress stays labeled pending; never silently mark a feature complete. Commit code/tests/docs together when possible. See CONTRIBUTING.md.
