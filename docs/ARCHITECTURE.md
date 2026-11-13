# Architecture, data schema and state

## Hardware boundary
- **ESP32-P4**: display/touch, application state, local persistence, report rendering.
- **ESP32-C6 companion**: Wi-Fi operations exposed by the supported P4↔C6 host driver. Capabilities must be verified with the selected SDK; do not presume raw packet capture or arbitrary monitor-mode support.
- **microSD**: optional report archive; absence must not block ordinary on-screen testing.
- **Windows development laptop**: build, serial monitor, backup, guarded USB flashing. Laptop is **not** a runtime dependency.

## First committed state implementation (source preview)
- `include/app_state.hpp` provides `Screen`, `Tool`, `Outcome`, `State`, and a `Controller` with generation invalidation, explicit `ScopeRequired`, and `Unsupported` results.
- `include/touch_layout.hpp` supplies a pure six-button geometry map used for both drawing and hit testing.
- `src/screens.cpp` paints and reads M5Unified touch; no network API is imported in the first build.
- No UI control can authorize a host target at this stage; later approval must be tied to a specific owned host/subnet rather than a global boolean.
- The entire v1 report and network profile schema below remains **proposed and not yet stored on a device**.

## Data schema, version 1 (proposal; not yet coded)
- `DeviceSettings { schema_version, display_brightness, selected_profile_id?, enabled_tests[], report_retention_count }`
- `NetworkProfile { profile_id, label, approved_ipv4_cidr?, approved_host_ips[], consent_timestamp?, enabled, max_hosts, max_concurrent_probes, timeout_ms }`
- `WiFiAccessPoint { ssid, bssid?, channel, rssi_dbm, auth_mode?, observed_at }`
- `DeviceRecord { ipv4, mac_address?, hostname?, discovery_method, last_seen_at, response_ms? }`
- `ProbeResult { test_id, type, target?, status, started_at, finished_at?, metrics, error_code?, details? }`
- `TestRun { schema_version, run_id, firmware_version, profile_id?, started_at, finished_at?, status, results[], warnings[] }`

Use explicit `schema_version`, bounded arrays and stable keys. SSIDs and device names are untrusted display strings and must be rendered as text, not interpreted as markup. Credentials, pairing secrets and raw traffic are never included in reports. Report schema changes require an upgrade/migration strategy and fixture tests.

### Enumerations
- `test_type`: `wifi_scan | devices | ping | ports | dns`.
- `probe_status`: `not_started | running | passed | failed | cancelled | unsupported | timed_out`.
- `run_status`: `idle | preparing | running | completed | partial | failed | cancelled`.

## State transitions
```text
BOOT → HARDWARE_CHECK → HOME
HOME → SELECT_SCOPE → READY → RUNNING → RESULTS → HOME
                             |           |
                             |           +→ CANCELLING → CANCELLED → RESULTS
                             +→ INVALID_SCOPE → HOME
RUNNING → TIMED_OUT / FAILED / UNSUPPORTED → RESULTS
```
Only the UI task may change the visible page. Network tasks publish typed events into a bounded queue; they never block drawing or handle touch input directly. Cancel marks a generation/token invalid and stops scheduling additional probes; a running driver call must have a bounded timeout. Ignore stale results from earlier runs.

## Flow for Run All (pseudocode)
```text
on press RUN ALL:
  verify selected test suite and scope
  reject unapproved host targets before any packet is sent
  create run_id and in-memory report
  for each enabled test:
    if cancel requested: stop scheduling; report cancelled
    if driver unavailable: record unsupported and continue
    execute bounded test; update progress and measurements
  derive final status (complete / partial / failed / cancelled)
  save report atomically to microSD if available
  display summary and save error separately
```

## Safety/resource budgets (initial defaults — final values must be tested)
- No network scanning until user explicitly enables an approved profile.
- Default max 16 authorized hosts per discovery run; max one probe in flight; 1s timeout per probe; configurable hard limit only after tests.
- TCP port check starts with a small, documented allowlist and one authorized host; no full 65,535-port sweep.
- Never auto-join an SSID or send host probes just by opening a screen.
- Device test data should be summarized without passwords, DNS secrets, or private packet contents.

## File/module convention
Small focused files: `app_state`, `screens`, `touch`, `network_driver`, `wifi_scan`, `discovery`, `ping`, `port_check`, `dns_check`, `report_store`, `errors`, `logging`. Split a source file as it approaches 150 lines. Keep drivers behind interfaces so mock tests do not depend on hardware.

## Planned verification
Pure state reducers and report serialization are tested on the laptop first. Hardware adapters are separately tested on the physical board. Network code must log meaningful error categories and clean up resources on every early return; no silent successes.
