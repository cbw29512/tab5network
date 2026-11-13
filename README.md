# Tab5 Network Tester
**Working name:** Pocket Kali / Tab5 Network Test Lab  
**Target:** M5Stack Tab5 (ESP32-P4 + ESP32-C6), controlled from a Windows laptop over USB-C  
**Status:** DOCUMENTATION BASELINE — firmware is **not yet built, installed, or hardware-certified**.  
**Repository visibility:** PUBLIC. Never commit network secrets, private scan data, firmware dumps, or personal information.

A touch-first, portable, **authorized** network diagnostic instrument. All on-device tests are selected by large buttons, show visual progress/results, and can export reports to microSD. No command line is required on the Tab5. PowerShell on the Windows development laptop handles setup, build, backup and flashing.

## Start here
1. [Definition of Done and first MVP](docs/DEFINITION_OF_DONE.md)
2. [Windows laptop setup](docs/SETUP_WINDOWS.md)
3. [USB firmware backup, flashing and recovery](docs/FLASH_RECOVERY.md)
4. [Architecture, data schema and state transitions](docs/ARCHITECTURE.md)
5. [Hardware and source links](docs/HARDWARE.md)
6. [Acceptance test plan](docs/TEST_PLAN.md)
7. [Handoff checklist for another developer](docs/HANDOFF.md)
8. [Safety and security](SECURITY.md)
9. [Project status and change log](CHANGELOG.md)

## MVP screens
- **Wi-Fi scan:** nearby 2.4 GHz access points, channel, RSSI and security details when exposed by the supported stack.
- **Devices:** discover responding hosts **only on a user-approved local network**.
- **Ping:** gateway/selected host packet loss and latency.
- **Port test:** small, bounded TCP connect checks for a chosen, authorized host.
- **DNS test:** local resolver reachability and lookup timing.
- **Run All:** run enabled checks sequentially, cancel safely and produce a report.

**Operating rule:** standalone basic tests first; NucBox integration or advanced tools may be added later, but are not prerequisites for the MVP. Never run unbounded scans, deauthentication, exploits, or covert collection.

## Current milestone
- [x] Existing GitHub repository identified.
- [x] Project scope, documentation and data/state contracts drafted.
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

## Distribution
This public repository currently has **no software license**. Public visibility alone does not grant redistribution/reuse rights. Obtain an explicit license decision before offering a downloadable firmware or accepting contributions. No copyrighted D&D data or credentials belong here.
