[CmdletBinding()]
param(
    [string]$Port = "",
    [switch]$VerifyChip
)
# READ-ONLY preflight. Never backs up, erases, or flashes automatically.
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
try {
    Write-Host "Tab5 Network Tester - Windows read-only preflight"
    Write-Host "Privacy: only USB vendor/product IDs are shown, not device-instance serials."
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
    foreach ($command in @("git", "python", "pio")) {
        $found = Get-Command $command -ErrorAction SilentlyContinue
        if ($null -eq $found) {
            Write-Warning "$command is not on PATH (optional at this inspection stage)."
        } else {
            Write-Host "$command path: $($found.Source)"
        }
    }
    $ports = @(Get-CimInstance Win32_PnPEntity |
        Where-Object { $_.Name -match '\(COM\d+\)' } |
        Select-Object Name, @{ Name = "USB_VID_PID"; Expression = {
            # Device-instance suffixes can be unique IDs; do not print them.
            if ($_.PNPDeviceID -match '(VID_[0-9A-Fa-f]{4}&PID_[0-9A-Fa-f]{4})') {
                $Matches[1].ToUpperInvariant()
            } else {
                "Not available"
            }
        }})
    if ($ports.Count -eq 0) {
        Write-Warning "No COM devices found. Verify USB data cable and download mode."
    } else {
        $ports | Format-Table -AutoSize
    }
    if ($VerifyChip) {
        # Reading the flash ID is not the same as backing up the flash image.
        if ([string]::IsNullOrWhiteSpace($Port)) {
            throw "Supply -Port COMx after visually confirming the Tab5 in Device Manager."
        }
        if ($Port -notmatch '^COM\d{1,3}$') {
            throw "Invalid COM port syntax: $Port"
        }
        $match = @($ports | Where-Object { $_.Name -match ('\(' + [regex]::Escape($Port) + '\)') })
        if ($match.Count -ne 1) {
            throw "The selected port was not uniquely present in the Windows device list."
        }
        if ($null -eq (Get-Command python -ErrorAction SilentlyContinue)) {
            throw "Python/esptool is required for an explicit chip identification."
        }
        & python -m esptool --chip esp32p4 --port $Port flash-id
        if ($LASTEXITCODE -ne 0) {
            throw "esptool flash-id failed. Confirm the chip and ROM download mode."
        }
        Write-Host "Chip probe completed. THIS IS NOT A FIRMWARE BACKUP."
    }
    Write-Host "Next: record LCD sticker, then follow docs/FLASH_RECOVERY.md."
} catch {
    Write-Error "Tab5 read-only preflight failed: $($_.Exception.Message)"
    exit 1
}
