# Windows laptop setup (PowerShell) — operator handoff

Current state: **documentation only; no verified one-command installer or firmware binaries exist yet**. The physical Tab5 is connected to the user's Windows laptop by a USB data cable. Commands here are for inspection; do **not** flash until the recovery gate in FLASH_RECOVERY passes.

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

## 4. Read the recovery procedure
See [FLASH_RECOVERY.md](FLASH_RECOVERY.md). Copy the microSD separately, and take a verified physical flash backup before overwriting the current Pocket DM firmware.

## 5. Build prerequisites (not yet installed or pinned)
- Git for Windows and PowerShell.
- Python and esptool for flash identification, backup and verification.
- M5Stack-compatible ESP32-P4/ESP32-C6 toolchain (manufacturer supplies a PlatformIO/Arduino example; a locked, working version is pending verification).
- USB serial driver if required by Device Manager.
- SHA-256 hashing with `Get-FileHash`.

A future `scripts/Build-Tab5Network.ps1` and `scripts/Flash-Tab5Network.ps1` will perform preflight checks and fail closed on missing backups, unexpected flash size, board revisions or ambiguous COM ports. **Those scripts do not exist yet and must not be advertised as working.**

## 6. Never commit machine-specific settings
Do not check in: `.env`, Wi-Fi credentials, local COM-port choices, firmware dumps, SD images, credentials, or real network reports. Generate and commit a redacted test log and source commit SHA only.
