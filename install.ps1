# Alter direct installer — CLI + MCP server (Windows).
#
# Usage:
#   iwr https://www.alter-evm.com/install.ps1 -useb | iex

$ErrorActionPreference = "Stop"

$REPO = "VISIALIS/alter"
$BASE_URL = "https://github.com/$REPO/releases/latest/download"

Write-Host "==> " -NoNewline -ForegroundColor Cyan
Write-Host "Starting Alter installation for Windows"

# Detect architecture
$arch = $env:PROCESSOR_ARCHITECTURE.ToLower()
$arch_id = "x64"
if ($arch -eq "arm64") {
    $arch_id = "arm64"
} elseif ($arch -ne "amd64" -and $arch -ne "x64") {
    Write-Host "error: " -NoNewline -ForegroundColor Red
    Write-Host "Unsupported architecture: $arch. Available builds: x64, arm64."
    exit 1
}

# Install directory
$install_dir = $env:ALTER_INSTALL_DIR
if (-not $install_dir) {
    $install_dir = Join-Path $env:USERPROFILE ".local\bin"
}

if (-not (Test-Path $install_dir)) {
    New-Item -ItemType Directory -Force -Path $install_dir | Out-Null
}

$tools = @("alter-cli", "alter-mcp")

foreach ($tool in $tools) {
    $asset = "$tool-windows-${arch_id}.exe"
    $target = Join-Path $install_dir "${tool}.exe"
    
    Write-Host "==> " -NoNewline -ForegroundColor Cyan
    Write-Host "Downloading $asset (latest release)..."
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "$BASE_URL/$asset" -OutFile $target -UseBasicParsing
    } catch {
        Write-Host "error: " -NoNewline -ForegroundColor Red
        Write-Host "Download failed for $asset. Check https://github.com/$REPO/releases"
        exit 1
    }
    
    Write-Host " ✓ " -NoNewline -ForegroundColor Green
    Write-Host "$tool installed to $target"
}

# Verify
Write-Host "==> " -NoNewline -ForegroundColor Cyan
Write-Host "Verifying..."

& (Join-Path $install_dir "alter-cli.exe") --version
& (Join-Path $install_dir "alter-mcp.exe") --version

# Check PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$install_dir*") {
    Write-Host ""
    Write-Host "==> " -NoNewline -ForegroundColor Cyan
    Write-Host "Note: $install_dir is not in your User PATH."
    Write-Host "    Adding it now... (Please restart your terminal to apply)"
    $newPath = "$install_dir;$userPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
}

Write-Host ""
Write-Host " ✓ " -NoNewline -ForegroundColor Green
Write-Host "Alter is ready. Try: alter-cli 0xdAC17F958D2ee523a2206206994597C13D831ec7"
