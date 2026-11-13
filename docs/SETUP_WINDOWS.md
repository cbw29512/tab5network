# Windows laptop setup (PowerShell) — operator handoff

Current state: **read-only inspection script and firmware source exist on the feature branch**, but physical flash/build are unverified and there is no approved firmware binary. The physical Tab5 is connected to the user's Windows laptop by a USB data cable. Commands here are for inspection; do **not** flash until the recovery gate in FLASH_RECOVERY passes.

## 1. Clone the version-controlled project
Open PowerShell:
```powershell
try {
    $ErrorActionPreference = "Stop"
    git --version
    git clone https://github.com/cbw29512/tab5network.git
    Set-Location .\tab5network
    git status --short
    git log -1 --oneline
} catch {
    Write-Error "Project clone or Git verification failed: $($_.Exception.Message)"
}
```
Expected: an intact local clone at the repository's recorded commit. Do not continue if clone/authentication fails.

## 2. Identify the USB device (read-only)
Use the script provided in the repository; it NEVER writes firmware or makes backups:

```powershell
try {
    $ErrorActionPreference = 'Stop'
    # The checked-in script is inspected and read-only. This overrides execution
    # policy only in the launched PowerShell process, not machine/user settings.
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\Inspect-Tab5.ps1
    if ($LASTEXITCODE -ne 0) { throw 'Tab5 preflight failed' }
} catch { Write-Error "Device inspection failed: $($_.Exception.Message)" }
```

**Observed laptop checkpoint (2026-11-13):** PowerShell 5.1, Python 3.12 and Git were detected. The only enumerated USB COM device was **COM3** with Espressif `VID_303A&PID_1001`; subsequently `esptool 5.6.0 --chip esp32p4 --port COM3 flash-id` **confirmed ESP32-P4 v1.3 and 16 MB flash**. PlatformIO (`pio`) was not on PATH. The first invocation failed because Windows script execution was disabled; a *child-process* `-ExecutionPolicy Bypass` retry succeeded without changing the permanent policy. Some managed machines may enforce Group Policy and still refuse, in which case do not change policy globally; use the manual CIM inspection fallback.

The inspector now redacts device-instance suffixes so routine diagnostic output is safe to share. The **full unique Windows PNPDeviceID must never be put into public GitHub history**.

The optional `-VerifyChip -Port COMx` performs an explicit **read-only** chip ID query only after you verify the actual COM port and put the device in ROM download mode. Do not use it to auto-select a device.

The Windows COM3 `flash-id` command now confirms the ESP32-P4 v1.3 and 16 MB flash on this laptop. Port numbering may change on another machine or after reconnecting. The chip is identified but LCD revision, storage backup and secure-boot/flash-encryption recovery compatibility remain unknown. No flash/erase command is part of this inspection.

Manual fallback:
```powershell
try {
    $ErrorActionPreference = "Stop"
    $ports = @(Get-CimInstance Win32_PnPEntity |
        Where-Object { $_.Name -match "\(COM\d+\)" } |
        Select-Object Name, PNPDeviceID)
    if ($ports.Count -eq 0) {
        Write-Warning "No COM ports found. Confirm USB data cable, drivers and Tab5 download/runtime mode."
    } else {
        $ports | Format-Table -AutoSize
    }
} catch {
    Write-Error "Unable to enumerate Windows COM devices: $($_.Exception.Message)"
}
```
Record the correct COM port and hardware ID after verifying the device in Device Manager. **Never assume COM5, and never choose a port by guessing**. A different USB connection or firmware mode may enumerate differently.

## 3. Identify the screen revision
Read the sticker on the rear. Note whether it is ILI9881C/GT911 or ST7123/ST7121. Take a photo locally if helpful, but never commit personal metadata. Confirm the active firmware's appearance before installing a replacement.

## 4. Make a private, read-only flash backup (next gate)
After reviewing `scripts/Backup-Tab5Flash.ps1` and checking that **COM3 still belongs to this ESP32-P4**, run from the feature-branch root:

```powershell
try {
    $ErrorActionPreference = 'Stop'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\Backup-Tab5Flash.ps1 -Port COM3
    if ($LASTEXITCODE -ne 0) { throw 'Private flash backup failed' }
} catch { Write-Error "Private Tab5 backup stopped: $($_.Exception.Message)" }
```

This script is a **read-only flash operation**, NOT a firmware restore or microSD backup. By default it creates a new timestamped directory under `%USERPROFILE%\\Tab5PrivateBackups` and writes two 16 MB raw images plus a private SHA-256 manifest. Never upload the images or manifest to GitHub. If the hash comparison fails, **stop** and keep the files private for inspection. The code is designed to be idempotent across runs (no overwrite), but execution on this laptop is still pending.

## 5. Read the recovery procedure
See [FLASH_RECOVERY.md](FLASH_RECOVERY.md). Copy the microSD separately, and take a verified physical flash backup before overwriting the current Pocket DM firmware.

## 5. Build prerequisites (not yet installed or pinned)
- Git for Windows and PowerShell.
- Python and esptool for flash identification, backup and verification.
- `platformio.ini` pins pioarduino platform `54.03.21`, M5Unified `0.2.23` and M5GFX `0.2.30`; this source baseline must still pass the GitHub compile and physical LCD test before flashing.
- USB serial driver if required by Device Manager.
- SHA-256 hashing with `Get-FileHash`.

The checked-in **build-only** script `scripts/Build-Tab5Network.ps1` runs `pio run -e tab5` without uploading and prints the firmware size and SHA-256. In PowerShell from the repository root:

```powershell
try {
    $ErrorActionPreference = 'Stop'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\Build-Tab5Network.ps1
    if ($LASTEXITCODE -ne 0) { throw 'Build failed' }
} catch { Write-Error "Tab5 build error: $($_.Exception.Message)" }
```

Install PlatformIO CLI beforehand if `pio` is not on PATH. The USB device need not be connected to compile. **Do not run `pio run -t upload`** before backups. A future `scripts/Flash-Tab5Network.ps1` will perform preflight checks and fail closed on missing backups, unexpected flash size, board revisions or ambiguous COM ports. **The guarded flash script does not exist.** The build script is committed but the actual Windows run is not yet certified.

## 6. Never commit machine-specific settings
Do not check in: `.env`, Wi-Fi credentials, local COM-port choices, firmware dumps, SD images, credentials, or real network reports. Generate and commit a redacted test log and source commit SHA only.
