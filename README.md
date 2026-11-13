# Tab5 Network Tester
**Working name:** Pocket Kali / Tab5 Network Test Lab  
**Target:** M5Stack Tab5 (ESP32-P4 + ESP32-C6), controlled from a Windows laptop over USB-C  
**Status:** SOURCE PREVIEW — touch UI firmware is committed on a feature branch; it is **not yet proven to build, installed, or hardware-certified**.  
**Repository visibility:** PUBLIC. Never commit network secrets, private scan data, firmware dumps, or personal information.

A touch-first, portable, **authorized** network diagnostic instrument. All on-device tests are selected by large buttons, show visual progress/results, and can export reports to microSD. No command line is required on the Tab5. PowerShell on the Windows development laptop handles setup, build, backup and flashing.

## Start here
1. **[Live project status — read first](PROJECT_STATE.md)**
2. [Definition of Done and first MVP](docs/DEFINITION_OF_DONE.md)
3. [Windows laptop setup](docs/SETUP_WINDOWS.md)
4. [USB firmware backup, flashing and recovery](docs/FLASH_RECOVERY.md)
5. [Architecture, data schema and state transitions](docs/ARCHITECTURE.md)
6. [Hardware and source links](docs/HARDWARE.md)
7. [Acceptance test plan](docs/TEST_PLAN.md)
8. [Handoff checklist for another developer](docs/HANDOFF.md)
9. [Safety and security](SECURITY.md)
10. [Changelog — every feature, fix and removal](CHANGELOG.md)
11. [Architecture/product decision history](docs/DECISIONS.md)
12. [Contributing and update policy](CONTRIBUTING.md)

## MVP screens
- **Wi-Fi scan:** nearby 2.4 GHz access points, channel, RSSI and security details when exposed by the supported stack.
- **Devices:** discover responding hosts **only on a user-approved local network**.
- **Ping:** gateway/selected host packet loss and latency.
- **Port test:** small, bounded TCP connect checks for a chosen, authorized host.
- **DNS test:** local resolver reachability and lookup timing.
- **Run All:** run enabled checks sequentially, cancel safely and produce a report.

**Operating rule:** standalone basic tests first; NucBox integration or advanced tools may be added later, but are not prerequisites for the MVP. Never run unbounded scans, deauthentication, exploits, or covert collection.

## First firmware source preview
Branch: `feature/touch-ui-preflight-v0`. Source: `src/main.cpp` and `src/screens.cpp`, backed by pure C++ state and touch-hitbox logic in `include/` and `src/` with `tests/controller_test.cpp`.

**Important:** the six buttons are functional UI navigation only. Wi-Fi scanning and host testing are NOT implemented. Wi-Fi reports `TEST BACKEND NOT INSTALLED`; host tests report `AUTHORIZED TARGET REQUIRED`. The preview does not send probes and must not be mistaken for a completed tester. Code builds and real-device tests must pass before flashing.

The pinned `platformio.ini` uses pioarduino `54.03.21`, M5Unified `0.2.23` and M5GFX `0.2.30`, matching the M5Stack minimum for recent display revisions. GitHub firmware compile runs in `.github/workflows/firmware-source.yml`.

Read-only laptop inspection: `powershell -NoProfile -File scripts/Inspect-Tab5.ps1`. Build without flashing: `powershell -NoProfile -File scripts/Build-Tab5Network.ps1` (requires PlatformIO CLI; not yet Windows-tested). See `docs/SETUP_WINDOWS.md`.

## Current milestone
- [x] Existing GitHub repository identified.
- [x] Project scope, documentation and data/state contracts committed.
- [x] Living-document GitHub Actions check passed ([run 43448788566](https://github.com/cbw29512/tab5network/actions/runs/43448788566)); future code pull requests must update state and changelog.
- [x] Initial source-level touch navigation implementation committed (not device-tested).
- [ ] Confirm GitHub C++ and PlatformIO compile gates on the feature branch.
- [ ] Confirm physical Tab5 screen-controller revision, USB COM port, Wi-Fi coprocessor firmware and microSD behavior.
- [ ] Establish and verify a restorable backup of the current firmware and SD contents.
- [ ] Build/flash touch UI prototype and validate every button.
- [ ] Integrate and test each bounded network diagnostic on real hardware.
- [ ] Save/reopen report on microSD; pass unattended crash and cancellation tests.
- [ ] Tag a reproducible, hardware-tested release and document its SHA-256.

## Hardware caveats
The Tab5 has **16 MB flash, 32 MB PSRAM, a 1280×720 touch display and an ESP32-C6 2.4 GHz radio** connected to the ESP32-P4. It is not a native Kali Linux machine. Display/touch chip revisions differ: verify the device sticker. Built-in 5 GHz scanning is **not** supported. Network functions must be tested against the actual P4 ↔ C6 host interface; no unsupported driver feature should be claimed.

## Toolchain decision (provisional)
M5Stack documents a **PlatformIO + Arduino + M5Unified/M5GFX** build configuration for Tab5; see [HARDWARE](docs/HARDWARE.md). The firmware/toolchain and USB flashing are not yet verified on this laptop or physical device. Versions must be pinned after the first successful build and release.

## Documentation maintenance
Read PROJECT_STATE.md **before every change**. For each code feature, change or removal, update PROJECT_STATE.md and CHANGELOG.md in the same pull request. Record architecture decisions and deprecations in docs/DECISIONS.md. CI checks local documentation links and requires both living history files on code PRs. It cannot independently prove documentation accuracy; hardware tests remain mandatory.

## Distribution
This public repository currently has **no software license**. Public visibility alone does not grant redistribution/reuse rights. Obtain an explicit license decision before offering a downloadable firmware or accepting contributions. No copyrighted D&D data or credentials belong here.
