# USB flashing, preservation and recovery — Windows / Tab5

**Status: NOT EXECUTED on the connected device.** This is a safety procedure, not a claim that a usable firmware backup exists. **Do not flash Pocket Kali before completing and verifying backup.**

## Critical preservation rules
- The Tab5 previously ran Pocket DM. Existing firmware, partition data, configuration and microSD may contain personal or irreplaceable data.
- A flash dump is **not** a microSD backup. Copy the SD card separately, verify the copy, and keep both backups **outside this public repository**.
- Never use `erase-flash`, `--force`, or a generic full-device factory reset during the initial MVP.
- Never assume COM5 (or any port). Identify the active USB port after entering download mode.
- Before writing anything, verify the device reports ESP32-P4 and identify its actual flash size/partition layout.
- Protected flash, secure boot and encryption can make a raw dump insufficient to restore; stop and investigate rather than claiming a good backup.
- Keep a manufacturer factory recovery option available, but recognize it does **not** recreate the user's existing Pocket DM configuration.

## Stage 0 — verify exact device and revision
Read [HARDWARE.md](HARDWARE.md) and [SETUP_WINDOWS.md](SETUP_WINDOWS.md). Photograph/record the rear LCD driver sticker locally. Inspect USB devices using the read-only PowerShell example. Power the Tab5 properly and use a known USB **data** cable.

## Stage 1 — enter ROM download mode
M5Stack: with a USB cable/battery connected, press and hold the Reset/Power control approximately 2 seconds until the internal green LED blinks rapidly; release. Confirm the exact port using Device Manager. Reference: https://docs.m5stack.com/en/guide/tab5/restore_factory

## Stage 2 — read and back up flash
Espressif documents reading flash with `read-flash 0 ALL`, which automatically uses the detected flash size when supported. Official instructions: https://docs.espressif.com/projects/esptool/en/latest/esp32p4/esptool/basic-commands.html

**Operator-controlled example — original manual fallback.** COM3 was chip-confirmed as ESP32-P4 v1.3/16 MB on 2026-11-13. Prefer the guarded, committed `scripts/Backup-Tab5Flash.ps1` after its CI syntax gate passes: it performs **two independent full flash reads** and compares byte counts and SHA-256 hashes, refusing an unexpected chip/flash size. It stores the backup under `%USERPROFILE%\\Tab5PrivateBackups` by default, *not* inside the public repository. The actual backup has **not yet been performed**. Manual fallback (not yet exercised on hardware):
```powershell
try {
    $ErrorActionPreference = "Stop"
    $Port = "COMx" # Replace only after positive verification in Device Manager.
    if ($Port -eq "COMx") { throw "Set the actual verified COM port before proceeding." }
    $BackupDir = Join-Path $env:USERPROFILE "Documents\Tab5PrivateBackups"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    python -m esptool --chip esp32p4 --port $Port flash-id
    if ($LASTEXITCODE -ne 0) { throw "Chip or flash identification failed." }
    $Dump = Join-Path $BackupDir "tab5-original-full-flash.bin"
    if (Test-Path -LiteralPath $Dump) { throw "Backup exists; do not overwrite it." }
    python -m esptool --chip esp32p4 --port $Port read-flash 0 ALL $Dump
    if ($LASTEXITCODE -ne 0) { throw "Flash backup failed." }
    Get-Item -LiteralPath $Dump | Select-Object Name,Length
    Get-FileHash -LiteralPath $Dump -Algorithm SHA256
} catch {
    Write-Error "STOP: Tab5 flash backup was not verified: $($_.Exception.Message)"
}
```
Record actual size, SHA-256, flash-ID output and tool version in a **private** backup manifest. The guarded script performs a second read and compares hashes. A hash and successful read alone do not demonstrate restoration: retain restore documentation and confirm the firmware format/security state.

## Stage 3 — protect microSD contents
1. Shut down the Tab5 properly, remove microSD, and copy **all files** to a private directory on the laptop or external storage.
2. Compare counts/sizes and compute a SHA-256 manifest for both source and copy. Store the manifest privately.
3. Do not format, shrink, repartition or use the original card as a scratch drive for the MVP.
4. Develop initially with another microSD card where possible.

## Stage 4 — approve a specific candidate for flashing
Only once there is a successful build and tested firmware artifact (the current `scripts/Build-Tab5Network.ps1` is **build-only and never uploads**):
1. Identify exact source commit, toolchain, M5Unified/M5GFX revision, LCD hardware driver and binary hash.
2. Verify image compatibility, partition/flash layout, known working recovery path, and signed-off acceptance of replacing the current firmware.
3. Build a **guarded** `scripts/Flash-Tab5Network.ps1` that refuses missing backups, unknown chip, mismatched hashes and ambiguous port.
4. Flash through the explicitly selected USB port; collect serial log, check screen/touch and reboot. Never autoselect a port or erase flash as a convenience.

**There is no flash script or approved candidate yet.**

## Stage 5 — recovery
If the new firmware will not boot or respond:
1. Stop further writes and record error/serial output.
2. Return to M5Stack download mode and verify the port.
3. Restore the **known compatible** previously captured image according to the backup's recorded security, partition and programming requirements; no generic write command is prescribed until those specifics are confirmed.
4. If original recovery is unavailable, M5Stack documents M5Burner factory firmware restore: https://docs.m5stack.com/en/guide/tab5/restore_factory . **Factory firmware is not the old Pocket DM firmware.**
5. Reinstall separately backed-up SD data only after the recovered firmware and SD schema are verified.

## Proof to record in PROJECT_STATE.md before first flash
[ ] USB COM port and hardware ID confirmed
[ ] LCD controller revision confirmed
[x] Flash ID/size recorded — ESP32-P4 v1.3, 16 MB, esptool 5.6.0 (2026-11-13)
[ ] Full flash dump created and hashed privately
[ ] Independent SD copy and hash manifest created privately
[ ] Restore plan tested or recovery limits explicitly accepted
[ ] Build/test binaries fingerprinted
[ ] Flash operation explicitly authorized
