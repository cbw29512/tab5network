[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidatePattern('^COM[0-9]{1,3}$')][string]$Port,
    [Parameter(Mandatory=$true)][ValidateSet('ILI9881C','ST7123','ST7121')][string]$LcdRevision,
    [string]$BackupFolder = '',
    [switch]$Upload
)
# DATA: TNK1-FLASH-BACKUP (two full images, one SHA-256).
# STATE: PRECHECK -> BACKUP_VERIFIED -> SECURITY_OK -> BUILT -> UPLOAD (opt-in).
# No SD-card APIs, full-chip erase or automatic target selection.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$tempEfuse = Join-Path $env:TEMP ('tab5-efuse-' + [guid]::NewGuid().ToString('N') + '.json')

try {
    if ((git -C $repo status --porcelain)) {
        throw 'Repository has local changes. Protect them before flashing.'
    }
    $branch = (& git -C $repo branch --show-current).Trim()
    if ($LASTEXITCODE -ne 0 -or $branch -ne 'feature/touch-ui-preflight-v0') {
        throw "Expected the tested feature branch; found '$branch'."
    }
    if ($LcdRevision -ne 'ST7121') {
        throw 'This build has only previous runtime identification for ST7121. Do not guess another LCD variant.'
    }

    $ports = @(Get-CimInstance Win32_PnPEntity | Where-Object {
        $_.Name -match ('\(' + [regex]::Escape($Port) + '\)') -and
        $_.PNPDeviceID -match 'VID_303A&PID_1001'
    })
    if ($ports.Count -ne 1) {
        throw "$Port is not uniquely identified as the expected Espressif USB device."
    }
    if ([string]::IsNullOrWhiteSpace($BackupFolder)) {
        $backupRoot = Join-Path $env:USERPROFILE 'Tab5PrivateBackups'
        $matches = @(Get-ChildItem -LiteralPath $backupRoot -Filter 'private-manifest.json' -Recurse -File -ErrorAction Stop)
        if ($matches.Count -ne 1) {
            throw 'Specify -BackupFolder with the verified private backup session directory.'
        }
        $BackupFolder = $matches[0].DirectoryName
    }
    $backupFull = [IO.Path]::GetFullPath($BackupFolder)
    if ($backupFull.StartsWith(($repo.TrimEnd('\') + '\'), [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Backup folder must be outside this public Git repository.'
    }
    $manifestPath = Join-Path $backupFull 'private-manifest.json'
    $backup = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($backup.format -ne 'TNK1-FLASH-BACKUP' -or
        $backup.chip -ne 'ESP32-P4' -or
        [int]$backup.flash_bytes -ne 16777216 -or
        [int]$backup.read_count -ne 2 -or
        [string]$backup.matching_sha256 -notmatch '^[0-9a-fA-F]{64}$') {
        throw 'Private backup manifest is incomplete or incompatible.'
    }
    foreach ($name in @('flash-pass1.bin','flash-pass2.bin')) {
        $path = Join-Path $backupFull $name
        $file = Get-Item -LiteralPath $path -ErrorAction Stop
        if ($file.Length -ne 16777216) { throw "$name is not a complete 16 MB flash image." }
        if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $backup.matching_sha256) {
            throw "$name SHA-256 differs from the private backup manifest."
        }
    }
    Write-Host 'PASS: original Pocket DM flash backed up twice; hashes match.'

    # Read-only ROM identity; suppress unique MAC address in output.
    $identity = (& python -m esptool --chip esp32p4 --port $Port flash-id 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0 -or
        $identity -notmatch 'Connected to ESP32-P4' -or
        $identity -notmatch 'Detected flash size:\s*16\s*MB') {
        throw 'ESP32-P4 / 16MB flash identity check failed.'
    }
    # Read only the two documented ESP32-P4 security eFuses; no key fields.
    & python -m espefuse --chip esp32p4 --port $Port summary --format json --file $tempEfuse SECURE_BOOT_EN SPI_BOOT_CRYPT_CNT | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $tempEfuse)) {
        throw 'Cannot verify boot security eFuses: no upload allowed.'
    }
    $security = Get-Content -LiteralPath $tempEfuse -Raw | ConvertFrom-Json
    foreach ($name in @('SECURE_BOOT_EN','SPI_BOOT_CRYPT_CNT')) {
        $field = $security.$name
        if ($null -eq $field -or [string]$field.raw_value -notmatch '^0x[0-9a-fA-F]+$') {
            throw "Missing/unreadable security fuse $name."
        }
        if ([Convert]::ToInt32(([string]$field.raw_value).Substring(2),16) -ne 0) {
            throw "$name is enabled; flash/restore requires a separate security plan."
        }
    }
    Write-Host 'PASS: secure boot and flash encryption eFuses are disabled.'

    # Existing touchscreen preview has no application SD I/O. Keep SD untouched.
    $source = (Get-Content -LiteralPath (Join-Path $repo 'src\main.cpp') -Raw) +
              (Get-Content -LiteralPath (Join-Path $repo 'src\screens.cpp') -Raw)
    if ($source -match '\bSD(?:_MMC)?\s*[.(]' -or $source -match '#include\s*[<"]SD') {
        throw 'SD access appeared in firmware source. Stop and review preservation.'
    }
    Push-Location $repo
    try {
        & python -m platformio run -e tab5
        if ($LASTEXITCODE -ne 0) { throw 'PlatformIO build failed.' }
        $binary = Join-Path $repo '.pio\build\tab5\firmware.bin'
        $candidate = Get-Item -LiteralPath $binary -ErrorAction Stop
        if ($candidate.Length -le 0 -or $candidate.Length -ge 16777216) {
            throw 'Built firmware size is invalid.'
        }
        $hash = (Get-FileHash -LiteralPath $binary -Algorithm SHA256).Hash
        Write-Host "BUILD PASS | bytes=$($candidate.Length) | sha256=$hash"
        if (-not $Upload) {
            Write-Host 'PREFLIGHT ONLY. Firmware NOT flashed. Re-run with -Upload to write.'
            exit 0
        }
        Write-Warning 'This writes new bootloader/partition/app regions of internal SPI flash.'
        Write-Warning 'Previous Pocket DM firmware may stop booting. microSD stays untouched by this script.'
        $confirm = Read-Host "Type FLASH $Port to authorize replacement"
        if ($confirm -cne "FLASH $Port") { throw 'Upload cancelled; confirmation did not match.' }
        & python -m platformio run -e tab5 -t upload --upload-port $Port
        if ($LASTEXITCODE -ne 0) { throw 'Firmware upload failed. Preserve backup and inspect recovery guide.' }
        Write-Host 'UPLOAD SUCCESS. Cold boot should display six touchscreen buttons.'
        Write-Host 'No network scanning backend is installed in this preview.'
    } finally { Pop-Location }
} catch {
    Write-Error "TAB5 FLASH STOPPED: $($_.Exception.Message)"
    exit 1
} finally {
    if (Test-Path -LiteralPath $tempEfuse) {
        Remove-Item -LiteralPath $tempEfuse -Force -ErrorAction SilentlyContinue
    }
}
