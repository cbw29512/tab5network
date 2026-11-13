# Definition of Done — Tab5 Network Tester MVP 0.1

Status: **approved product direction; implementation not yet certified**. Updated: 2026-11-13.

## Product objective
A portable, touch-only network diagnostic instrument for networks the operator owns or is explicitly authorized to test. A Windows laptop is used for firmware builds/flashing over USB-C; normal testing does not require a computer or NucBox.

## Required screens and interactions
1. **Home / cold boot:** immediately show six large *on-screen touch buttons* — WI-FI SCAN, DEVICES, PING, PORT TEST, DNS, RUN ALL — plus settings, battery/connection indicator where supported, and report access. **No Pocket DM face/avatar or animated face screen, face overlay, splash requiring dismissal, or hardware-button navigation.**
2. **Scope:** host tests require an explicitly approved local IPv4 subnet or individual host. Default is **no authorized target**; no automatic sweep of every reachable network.
3. **Test:** show target, elapsed time, progress, current step, measured values and prominent CANCEL. Every test has timeout/failure/unsupported feedback.
4. **Results:** human-readable graphical bars/tables and clear measured values (SSID/channel/RSSI, discovered IPs, packet loss/latency, TCP reachability, DNS response). A reachable port is not inherently a vulnerability.
5. **Run All:** sequentially runs only enabled, supported and in-scope checks; partial completion is labeled partial, not passed.
6. **Reports:** timestamped JSON and readable summary on microSD. Report failures cannot corrupt previous reports. No secrets saved in reports.
7. **Recovery:** verified previous firmware backup before first flash; device-recovery instructions and code to reproduce a known-good build.

## Acceptance gates (all required for MVP release)
| ID | Verification | Status |
|---|---|---|
| A0 | GitHub source, docs, decisions, change log, reproducible instructions | Documentation committed; full reproducible build pending |
| A1 | Confirm board revision, boot/download procedure, Windows USB port and toolchain | ESP32-P4 v1.3/16 MB/COM3 confirmed; LCD revision and local build pending |
| A2 | Backup ESP32-P4 flash, copy microSD content, SHA-256 and prove restoration method | Pending physical test |
| A3 | Full touchscreen UI, button navigation and cancellation | Not implemented |
| A4 | Real on-device 2.4 GHz Wi-Fi scanning and authorized network connection | Not implemented |
| A5 | Real bounded discovery, ICMP, DNS and TCP connectivity tests | Not implemented |
| A6 | Run All with progress/error propagation and SD report round-trip | Not implemented |
| A7 | Unit/contract checks and repeatable USB flash on Windows | Not implemented |
| A8 | Another developer can reproduce it from clean Windows clone | Not tested |

## Out of scope for MVP
Full Kali Linux, exploitation frameworks, credential collection, password cracking, Wi-Fi deauthentication, jamming, stealth scans, unbounded network scanning, remote NucBox dependencies, and any claim of 5 GHz scanning by the built-in radio.

## Exit criteria
Release only after every gate passes on the **actual Tab5**. Record test logs, firmware binary SHA-256, source commit SHA, toolchain/library versions, tested hardware screen revision and known limitations in a signed-off release entry. CI is not a substitute for physical-device tests.
