# WTH (What The Hell) - PowerShell Installer
# Run this script as Administrator to install WTH

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Configuration
$InstallDir = "$env:ProgramFiles\wth"
$ScriptsDir = "$InstallDir\scripts"
$ExecutableName = "wth.exe"
$BuildDir = Join-Path $PSScriptRoot "..\build"

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WTH {
    Write-Host "Installing WTH (What The Hell)..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check if executable exists
    $exePath = Join-Path $BuildDir $ExecutableName
    if (-not (Test-Path $exePath)) {
        Write-Host "ERROR: Executable not found at $exePath" -ForegroundColor Red
        Write-Host "Please build the project first using build.bat" -ForegroundColor Yellow
        exit 1
    }
    
    # Create installation directory
    Write-Host "Creating installation directory: $InstallDir"
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
    
    # Copy executable
    Write-Host "Copying executable..."
    Copy-Item -Path $exePath -Destination $InstallDir -Force
    
    # Copy README
    $readmePath = Join-Path $PSScriptRoot "..\README.md"
    if (Test-Path $readmePath) {
        Copy-Item -Path $readmePath -Destination $InstallDir -Force
    }
    
    # Copy scripts
    Write-Host "Copying shell integration scripts..."
    $scriptsSource = Join-Path $PSScriptRoot "..\scripts"
    Copy-Item -Path "$scriptsSource\*" -Destination $ScriptsDir -Force
    
    # Add to PATH
    Write-Host "Adding to system PATH..."
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable(
            "PATH",
            "$currentPath;$InstallDir",
            "Machine"
        )
        Write-Host "Added $InstallDir to PATH" -ForegroundColor Green
    } else {
        Write-Host "Already in PATH" -ForegroundColor Yellow
    }
    
    # Add to PowerShell profile
    Write-Host ""
    Write-Host "Setting up PowerShell integration..." -ForegroundColor Cyan
    
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not (Test-Path $profilePath)) {
        New-Item -Path $profilePath -ItemType File -Force | Out-Null
    }
    
    $hookLine = ". `"$ScriptsDir\wth-hook.ps1`""
    $profileContent = Get-Content -Path $profilePath -Raw -ErrorAction SilentlyContinue
    
    if ($profileContent -notlike "*wth-hook.ps1*") {
        Add-Content -Path $profilePath -Value "`n# WTH Error Capture Hook"
        Add-Content -Path $profilePath -Value $hookLine
        Write-Host "Added hook to PowerShell profile: $profilePath" -ForegroundColor Green
    } else {
        Write-Host "Hook already in profile" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To start using WTH:" -ForegroundColor Cyan
    Write-Host "1. Restart your PowerShell session (or run: . `$PROFILE)"
    Write-Host "2. Run a command that fails"
    Write-Host "3. Type 'wth' to see the explanation"
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  PS> python nonexistent.py"
    Write-Host "  PS> wth"
    Write-Host ""
}

function Uninstall-WTH {
    Write-Host "Uninstalling WTH..." -ForegroundColor Cyan
    Write-Host ""
    
    # Remove from PATH
    Write-Host "Removing from system PATH..."
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -like "*$InstallDir*") {
        $newPath = ($currentPath -split ';' | Where-Object { $_ -ne $InstallDir }) -join ';'
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "Removed from PATH" -ForegroundColor Green
    }
    
    # Remove from PowerShell profile
    Write-Host "Removing from PowerShell profile..."
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (Test-Path $profilePath) {
        $profileContent = Get-Content -Path $profilePath -Raw
        $profileContent = $profileContent -replace "(?m)^# WTH Error Capture Hook\r?\n.*wth-hook\.ps1.*\r?\n", ""
        Set-Content -Path $profilePath -Value $profileContent
        Write-Host "Removed hook from profile" -ForegroundColor Green
    }
    
    # Remove installation directory
    Write-Host "Removing installation files..."
    if (Test-Path $InstallDir) {
        Remove-Item -Path $InstallDir -Recurse -Force
        Write-Host "Removed $InstallDir" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Uninstallation complete!" -ForegroundColor Green
    Write-Host ""
}

# Main script
if (-not (Test-Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

if ($Uninstall) {
    Uninstall-WTH
} else {
    Install-WTH
}
