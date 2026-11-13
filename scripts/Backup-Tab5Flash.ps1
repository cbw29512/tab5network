[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^COM[0-9]{1,3}$')]
    [string]$Port,
    [string]$BackupRoot = (Join-Path $env:USERPROFILE 'Tab5PrivateBackups')
)
# Read-only ESP32-P4 backup. Never erases, writes flash or alters the SD card.
# Save firmware dumps outside GitHub: flash may contain passwords and tokens.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-SafeEsptool {
    param([Parameter(Mandatory = $true)][string[]]$ArgumentList)
    try {
        # PowerShell 5.1 may promote benign native stderr to a terminating error.
        $oldPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $output = @(& python -m esptool @ArgumentList 2>&1)
            $exitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $oldPreference
        }
        $message = ($output | Out-String)
        # Do not reveal the device MAC when users paste the result into chat.
        $message = $message -replace '(?i)(?:[0-9a-f]{2}:){5}[0-9a-f]{2}', '[MAC REDACTED]'
        Write-Host $message
        if ($exitCode -ne 0) {
            throw "esptool exited with status $exitCode"
        }
        return $message
    } catch {
        Write-Error "ESP32-P4 read-only command failed: $($_.Exception.Message)"
        throw
    }
}

try {
    $repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    $targetRoot = [IO.Path]::GetFullPath($BackupRoot)
    $repoBoundary = $repoRoot.TrimEnd('\') + '\'
    if ($targetRoot.Equals($repoRoot, [StringComparison]::OrdinalIgnoreCase) -or
        $targetRoot.StartsWith($repoBoundary, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Private firmware backup must be OUTSIDE the public Git repository.'
    }
    if ($null -eq (Get-Command python -ErrorAction SilentlyContinue)) {
        throw 'Python was not found. Run the verified Python 3.12 installation.'
    }
    $ports = @(Get-CimInstance Win32_PnPEntity | Where-Object {
        $_.Name -match ('\(' + [regex]::Escape($Port) + '\)') -and
        $_.PNPDeviceID -match 'VID_303A&PID_1001'
    })
    if ($ports.Count -ne 1) {
        throw "Port $Port is not exactly one expected Espressif USB device; inspect first."
    }

    # Re-confirm chip and flash size; USB port assignments can change.
    $identity = Invoke-SafeEsptool -ArgumentList @(
        '--chip', 'esp32p4', '--port', $Port, 'flash-id'
    )
    if ($identity -notmatch 'Connected to ESP32-P4' -or
        $identity -notmatch 'Detected flash size:\s*16\s*MB') {
        throw 'Unexpected chip/flash size. No backup read was started.'
    }

    $session = 'tab5-original-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
    $folder = Join-Path $targetRoot $session
    if (Test-Path -LiteralPath $folder) {
        throw 'Backup session already exists. Refusing overwrite.'
    }
    New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
    $expectedBytes = 16777216
    $files = @(
        (Join-Path $folder 'flash-pass1.bin'),
        (Join-Path $folder 'flash-pass2.bin')
    )
    $hashes = @()
    foreach ($file in $files) {
        # ALL is the documented flash-size autodetection parameter.
        [void](Invoke-SafeEsptool -ArgumentList @(
            '--chip', 'esp32p4', '--port', $Port, 'read-flash', '0', 'ALL', $file
        ))
        $info = Get-Item -LiteralPath $file -ErrorAction Stop
        if ($info.Length -ne $expectedBytes) {
            throw "Incomplete flash read: expected $expectedBytes bytes."
        }
        $hashes += (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
    }
    if ($hashes[0] -ne $hashes[1]) {
        throw 'Two independent flash reads differ. Retain files privately and investigate.'
    }

    $manifest = [ordered]@{
        format = 'TNK1-FLASH-BACKUP'
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        chip = 'ESP32-P4'
        flash_bytes = $expectedBytes
        read_count = 2
        matching_sha256 = $hashes[0]
        files = @('flash-pass1.bin', 'flash-pass2.bin')
        restoration_tested = $false
        micro_sd_backed_up = $false
    }
    $manifest | ConvertTo-Json -Depth 3 |
        Set-Content -LiteralPath (Join-Path $folder 'private-manifest.json') -Encoding UTF8
    Write-Host 'PASS: Two full 16 MB flash reads match.' -ForegroundColor Green
    Write-Host "Private backup folder: $folder"
    Write-Host "SHA256: $($hashes[0])"
    Write-Warning 'This is not proof of restorable firmware. Backup microSD separately.'
    Write-Warning 'Do not upload this private folder or its contents to GitHub.'
} catch {
    Write-Error "STOP: No firmware was written. Flash backup failed: $($_.Exception.Message)"
    exit 1
}
