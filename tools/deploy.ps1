$ErrorActionPreference = "Stop"

. "$PSScriptRoot\config.ps1"

Write-Host ""
Write-Host "====================================="
Write-Host " UART Engine - Deploy"
Write-Host "====================================="
Write-Host ""

# ---------------------------------------------------
# Validate local structure
# ---------------------------------------------------

if (!(Test-Path $Config.LocalComponent)) {
    throw "Component directory not found:`n$($Config.LocalComponent)"
}

$requiredFiles = @(
    "__init__.py",
    "manifest.json"
)

foreach ($file in $requiredFiles) {

    if (!(Test-Path (Join-Path $Config.LocalComponent $file))) {
        throw "Missing file: $file"
    }
}

Write-Host "[OK] Local structure"

# ---------------------------------------------------
# Test SSH
# ---------------------------------------------------

Write-Host "Checking SSH..."

& $Config.SSH $Config.SSHHost "echo Connected" | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "SSH connection failed."
}

Write-Host "[OK] SSH"

# ---------------------------------------------------
# Create remote directory
# ---------------------------------------------------

& $Config.SSH $Config.SSHHost "sudo mkdir -p $($Config.RemoteComponent)"

# ---------------------------------------------------
# Convert local path
# ---------------------------------------------------

$localPath = (Resolve-Path $Config.LocalComponent).Path

if ($IsWindows -or $env:OS -eq "Windows_NT") {

    $drive = $localPath.Substring(0,1).ToLower()
    $rest  = $localPath.Substring(2).Replace("\","/")

    $rsyncExe = (Get-Command rsync).Source

    if ($rsyncExe -match "cwrsync") {
        $localPath = "/cygdrive/$drive$rest"
    }
    else {
        $localPath = "/$drive$rest"
    }
}

# ---------------------------------------------------
# Deploy
# ---------------------------------------------------

Write-Host "Deploying..."

$rsyncArgs = @(
    "-av",
    "--delete",
    "--no-owner",
    "--no-group",
    "--rsync-path=sudo /usr/bin/rsync",
    "--exclude=__pycache__",
    "--exclude=.git",
    "--exclude=.idea",
    "--exclude=.pytest_cache",
    "--exclude=*.pyc",
    "-e",
    $Config.SSH,
    "$localPath/",
    "$($Config.SSHHost):$($Config.RemoteComponent)/"
)

Write-Host ""
Write-Host ("rsync " + ($rsyncArgs -join " "))
Write-Host ""

$oldArgConv = $env:MSYS2_ARG_CONV_EXCL
$env:MSYS2_ARG_CONV_EXCL = "*"

try {

    & rsync @rsyncArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Deployment failed."
    }

}
finally {

    if ($null -eq $oldArgConv) {
        Remove-Item Env:MSYS2_ARG_CONV_EXCL -ErrorAction SilentlyContinue
    }
    else {
        $env:MSYS2_ARG_CONV_EXCL = $oldArgConv
    }
}

# ---------------------------------------------------
# Remove cache
# ---------------------------------------------------

Write-Host "Cleaning cache..."

& $Config.SSH $Config.SSHHost "sudo find $($Config.RemoteComponent) -type d -name __pycache__ -exec rm -rf {} +"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to clean cache."
}

Write-Host ""
Write-Host "====================================="
Write-Host " Deploy completed successfully."
Write-Host "====================================="
Write-Host ""
Write-Host ""