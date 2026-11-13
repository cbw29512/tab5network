[CmdletBinding()]
param()
# BUILD-ONLY script. It never uploads firmware or touches the Tab5.
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
try {
    $pio = Get-Command pio -ErrorAction SilentlyContinue
    if ($null -eq $pio) {
        throw "PlatformIO CLI not found. Install it before running this script."
    }
    $config = Join-Path $repo "platformio.ini"
    if (-not (Test-Path -LiteralPath $config)) {
        throw "platformio.ini missing; checkout the complete repository."
    }
    Push-Location $repo
    try {
        Write-Host "Building pinned ESP32-P4 source. NO DEVICE UPLOAD."
        & $pio.Source run -e tab5
        if ($LASTEXITCODE -ne 0) { throw "PlatformIO build exited $LASTEXITCODE." }
        $binary = Join-Path $repo ".pio\build\tab5\firmware.bin"
        if (-not (Test-Path -LiteralPath $binary)) {
            throw "The expected firmware binary is missing after build."
        }
        $file = Get-Item -LiteralPath $binary
        $hash = Get-FileHash -LiteralPath $binary -Algorithm SHA256
        Write-Host "BUILD SUCCEEDED (NOT HARDWARE TESTED)"
        Write-Host "Binary: $binary"
        Write-Host "Bytes: $($file.Length)"
        Write-Host "SHA256: $($hash.Hash)"
        Write-Host "Do not flash until the independent firmware/SD backup gate passes."
    } finally {
        Pop-Location
    }
} catch {
    Write-Error "BUILD FAILED: $($_.Exception.Message)"
    exit 1
}
