# Handoff guide — give this project to another developer

## What this repository is
The authoritative, version-controlled source and documentation for **Tab5 Network Tester**, a touch-driven authorized network diagnostic appliance for M5Stack Tab5. It is not a Kali Linux image. **There is no working firmware release yet.**

## New-developer onboarding
1. Read README.md, PROJECT_STATE.md, docs/DEFINITION_OF_DONE.md, docs/ARCHITECTURE.md, docs/HARDWARE.md, SECURITY.md.
2. Clone `https://github.com/cbw29512/tab5network.git` and record HEAD SHA.
3. Read docs/SETUP_WINDOWS.md for read-only Windows PowerShell detection.
4. Read docs/FLASH_RECOVERY.md before any hardware write.
5. Confirm Tab5 physical LCD variant and toolchain compatibility. Do not assume the original owner's COM port or Wi-Fi configuration.
6. Check docs/TEST_PLAN.md and CHANGELOG.md. Build only once firmware/toolchain files actually exist.
7. For each new feature, first update schema/state contracts if affected, implement, test on hardware if required, record evidence, and update PROJECT_STATE.md plus CHANGELOG.md in the same pull request.

## Source-of-truth map
- **README.md:** quick start and navigation
- **PROJECT_STATE.md:** the current verified status and next blocker
- **CHANGELOG.md:** chronological modifications and release history
- **docs/DEFINITION_OF_DONE.md:** product commitments and acceptance gates
- **docs/ARCHITECTURE.md:** records, state machine and hardware boundary
- **docs/HARDWARE.md:** manufacturer capability, revision and missing device observations
- **docs/SETUP_WINDOWS.md:** clean laptop prerequisites and USB discovery
- **docs/FLASH_RECOVERY.md:** preserve old firmware/SD and recover if necessary
- **docs/TEST_PLAN.md:** reproducible verification cases and evidence
- **docs/DECISIONS.md:** decisions and tradeoffs, including removed features
- **SECURITY.md:** authorization, target safety and secrets
- **CONTRIBUTING.md:** change-control requirements

## Working rules
Do not delete documentation of removed features: mark as superseded in docs/DECISIONS.md and add a removal entry in CHANGELOG.md. Do not promote a feature from planned to working without physical proof where applicable. Keep source files modular (target under 150 lines) and split files that grow beyond that threshold.

## First USB installation (not yet hardware-tested)
Use the repository's `scripts/Flash-Tab5Network.ps1` with explicit port and prior verified LCD ST7121. The script defaults to preflight/build and requires `-Upload` plus typed confirmation for any flash write. Backups stay private, and the microSD stays installed per operator preference. See `docs/FLASH_RECOVERY.md` and record the real results in PROJECT_STATE.md. Do not claim this is a functioning scanner until physical touch and network adapters are tested.

## Release bundle to deliver once ready
A tagged GitHub source revision; pinned toolchain/dependencies; verified binary plus SHA-256; Windows build and flash scripts; sample sanitized report; supported-hardware matrix; known limitations; backup and restore guide; proof of physical acceptance tests.

**Licensing alert:** this repository currently has no license. External developers may view the public code but are not automatically granted redistribution rights. Add an explicit license only after the project owner decides the terms.

## Troubleshooting handoff
- Screen blank after flash: first suspect LCD driver revision mismatch; do not erase flash.
- No USB port: verify proper cable, download mode, Device Manager, correct driver.
- No Wi-Fi: verify the C6 host firmware/driver and radio interface rather than claiming the hardware is faulty.
- No report: check SD detection/mount and preserve previous reports.
- Missing confidence: stop, document the blocker in PROJECT_STATE.md and restore the known-good state.
