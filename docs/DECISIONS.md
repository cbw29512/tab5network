# Architecture and product decisions (living record)

Use a new numbered entry when any existing decision is amended. Keep the old entry intact and link the superseding entry. Every feature removal must record why, impact, code/tests removed and possible migration needs. Statuses: `accepted`, `proposed`, `superseded`, `rejected`.

## ADR-001 — Touch-first network-testing device
- Date: 2026-11-13
- Status: **accepted**
- Decision: Use a standalone, high-visibility testing dashboard with six large buttons, graph/table results and on-device cancellation. Do not expose a Linux terminal as the normal user experience.
- Why: The user wants fast push-button diagnostics on a 1280×720 touch screen.
- Implications: Build test UI and state before adding advanced tooling.

## ADR-002 — Dedicated GitHub project
- Date: 2026-11-13
- Status: **accepted**
- Decision: `cbw29512/tab5network` is the canonical repository for code, documentation, scripts, test fixtures, configs and release history. Keep Tab5 Network Tester independent from Pocket DM/iPhone repositories.
- Implications: All implementation changes, fixes and removals update PROJECT_STATE.md, CHANGELOG.md and affected contracts. Never commit secrets.

## ADR-003 — Windows USB deployment
- Date: 2026-11-13
- Status: **accepted**
- Decision: Build/flash from a Windows laptop through an explicitly identified USB COM port, with PowerShell scripts and non-destructive preflight checks.
- Implications: No guessed ports or automatic erase. First verify backup and board revision.

## ADR-004 — Standalone MVP, optional NucBox later
- Date: 2026-11-13
- Status: **accepted**
- Decision: Basic Wi-Fi, discovery, ping, port and DNS tests run locally on supported Tab5 firmware. Advanced Nmap or other remote tools are future options only.
- Implications: No NucBox requirement or remote authentication protocol in v0.1.

## ADR-005 — Authorized, bounded testing
- Date: 2026-11-13
- Status: **accepted**
- Decision: Require explicit authorized host scope before active probes; keep a conservative rate/host budget, timeouts, visible cancellation and precise error states.
- Implications: No exploitation or Wi-Fi disruption features in the MVP.

## ADR-006 — Toolchain selection
- Date: 2026-11-13
- Status: **proposed**
- Options: M5Stack-documented PlatformIO/Arduino with M5Unified/M5GFX, or ESP-IDF with board support package.
- Pending evidence: exact LCD controller, current ESP32-C6 host Wi-Fi capability, native USB upload, SD library and clean reproducible Windows build.
- No pinned toolchain or runtime framework is approved yet.

## Decision template
```markdown
## ADR-NNN — Title
- Date:
- Status:
- Replaces (if any):
- Context and options:
- Decision:
- Why:
- Data/state/security implications:
- Verification:
- Follow-up:
```
