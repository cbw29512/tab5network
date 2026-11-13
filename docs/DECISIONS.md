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

## ADR-007 — First build is fail-closed touch navigation, not a simulated scanner
- Date: 2026-11-13
- Status: **accepted**
- Decision: Build hardware-targeted touch UI source using pinned official M5Stack Arduino/PlatformIO baseline. All network tools remain unimplemented until approved profiles and real C6 driver adapters exist.
- Why: Real touch geometry and screen compatibility can be validated independently from network permissions and C6 firmware. No fabricated security findings.
- Impact: Pure state controller and hitbox geometry can be host-tested. Only a verified build and backed-up Tab5 can be flashed.
- Follow-up: compile verification, hardware touch acceptance, then explicit user-selected scope and genuine Wi-Fi adapter.

## ADR-008 — Use a process-scoped PowerShell exception and redact serial identifiers
- Date: 2026-11-13
- Status: **accepted**
- Context: The first actual Windows preflight was blocked by a default execution policy; the retry with a child `powershell.exe -NoProfile -ExecutionPolicy Bypass` succeeded. The original inspector printed a unique Windows PNP instance ID.
- Decision: For reviewed local scripts, document a process-scoped bypass only; do not change global or permanent machine policy. By default print COM port and public VID/PID without device-instance suffixes.
- Verification: User's first inspection succeeded; new redaction code requires a repeat/local verification. No platform policy change is required; managed Group Policy may still block execution.
- Scope: This is development-tool convenience and output privacy, not permission to install unreviewed scripts.

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
