# Security and authorized-use policy

This project is a defensive, operator-controlled network diagnostic instrument. Use it **only** on networks and hosts owned by the operator or covered by explicit permission.

- No remote host sweeps by default. The user must choose an authorized IPv4 range/host before probing.
- Bounded, cancelable host discovery, connect-timeout checks and DNS/ping only.
- No credential interception, password cracking, exploitation, deauthentication, traffic disruption, stealth, persistence or attack automation in MVP.
- Default port probing must use an explicitly selected host, conservative documented list of TCP ports and bounded timing.
- Wi-Fi SSIDs may be sensitive and must be presented carefully; do not automatically upload logs.
- Network credentials, firmware dumps, serial numbers, token files and real scan results are **never committed**, especially because the GitHub repository is PUBLIC.
- Data schema must not put passwords or secret tokens in `TestRun` or exported reports.
- Sanitize logging; log failure categories, not secret payloads.
- Future expansions should get a scope and safety review in docs/DECISIONS.md before implementation.
- Report a security issue privately to the repository owner. Do not file exploits or secrets in public issues.

**No security audit or penetration-test certification is claimed.**
