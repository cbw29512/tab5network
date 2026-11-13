# Test plan and evidence matrix

**Never substitute mocked results for real network diagnostics on hardware.** Sample data may be used in a UI mockup only if labeled clearly.

## Initial source-test coverage added (not a device pass)
`tests/controller_test.cpp` checks fail-closed default state, scope gating, unsupported backends, invalid selections, generation counter and touch hitboxes at 1280x720. `.github/workflows/firmware-source.yml` compiles with host g++ and attempts a pinned PlatformIO ESP32-P4 firmware compile. Source CI **passed** on run 43451215326 at head `337995f` (host C++ tests, Windows PowerShell script syntax, PlatformIO ESP32-P4 compile). This does **not** prove screen, radio or USB behavior.

## Read-only flash backup validation gate (still pending on actual hardware)
- 2026-11-13: ESP32-P4 identification succeeded on COM3 with esptool 5.6.0 (chip v1.3 / 16 MB).
- `scripts/Backup-Tab5Flash.ps1` must refuse wrong ports, unexpected chip size and backup paths inside the repo; should perform two independent `read-flash 0 ALL` operations, verify **16,777,216 bytes each**, compare SHA-256 and leave old Pocket DM flash unchanged.
- A passing script run is only a **read consistency check**, not proof that raw flash is restorable under secure boot/flash encryption. Record restoration security limitations and back up microSD independently.
- A second verified physical run and private manifest are pending. CI syntax validation is required but does not prove actual flash reads.

## Windows reproducible build gate
After PlatformIO is installed, run `scripts/Build-Tab5Network.ps1` from PowerShell. Capture success/failure, Git SHA, output firmware size and SHA-256 without uploading. **Do not flash before backup gates.** The command is committed but has not been run on the user's Windows laptop.

## Test tiers
- **T0 source checks:** schema parsing, pure state transitions, error logging, input validation, report serialization, cancellation, bounded target enumeration. Run offline on a developer laptop.
- **T1 host simulation:** fake Wi-Fi/ICMP/TCP/DNS adapters produce success, timeout, partial, unsupported, SD missing/full and cancellation. No packet transmission.
- **T2 device integration:** physical touch, graphics, Wi-Fi initialization, PSRAM/stack health, SD write/read, serial logging, reboot.
- **T3 authorized LAN:** real 2.4 GHz network and owned test hosts, compare output to independent laptop tests.
- **T4 recovery:** original firmware/SD backup verified; failed flash/boot recovery rehearsed under an explicit safe plan.

## Required scenarios
| ID | Test | Expected observation |
|---|---|---|
| UI-00 | Cold boot after flashing replacement | Six large on-screen buttons appear directly; no face/avatar, overlay or face-dismiss step. Verify on device, not in a mockup |
| UI-01 | Tap every home button | Correct screen, no double-trigger |
| UI-02 | Tap CANCEL mid-scan | No new probes scheduled; partial results preserved |
| UI-03 | Disconnect Wi-Fi during run | Clear error; return home; no stale result |
| WF-01 | Scan 2.4 GHz channels | SSID/channel/RSSI from physical radio; no fabricated 5 GHz |
| WF-02 | No APs / radio unavailable | Empty or unsupported state, not pass |
| SC-01 | No approved profile | No host probe transmitted |
| SC-02 | Disallowed target | Rejected before any network activity |
| SC-03 | 16 authorized hosts | Host budget enforced; no unbounded sweep |
| PG-01 | Known gateway reachable | Latency and packet loss measured |
| PG-02 | Unresponsive host | Timeout and loss displayed |
| PT-01 | Selected known TCP listener | Port reachable, correctly labeled |
| PT-02 | Port refused / filtered | Differentiate TCP refusal from timeout when API permits |
| DN-01 | Known DNS lookup | Resolver, result and response time |
| DN-02 | DNS timeout | Failure visible; other tests remain usable |
| RA-01 | Run All mixed results | Partial, not automatic overall pass |
| SD-01 | SD absent/full | No corruption; save error shown |
| SD-02 | Reboot after save | Prior report readable |
| BO-01 | Restart during test | Stale active run not reported as pass |
| RC-01 | Backup/restore preflight | Tested and recorded before flashing |

## Evidence record format
Each tested milestone must record: date, source commit SHA, firmware binary hash, device LCD revision, toolchain/lib revisions, scenario ID, expected/actual, result, sanitized serial log path and reviewer initials. **Never commit network passwords, private reports or firmware dumps.**

## Definition of release
The v0.1 tag must correspond to a commit where all required A0–A8 gates in DEFINITION_OF_DONE.md are verified on the Tab5 and documented in CHANGELOG.md and PROJECT_STATE.md. Green CI alone is insufficient.
