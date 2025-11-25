# WTH Standalone Installer
# This installer works from any location

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Configuration
$InstallDir = "$env:ProgramFiles\wth"
$ScriptsDir = "$InstallDir\scripts"
$ExecutableName = "wth.exe"
$ExecutablePath = Join-Path $ScriptDir $ExecutableName

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   WTH (What The Hell) - Installer                       ║
║   Translating "Computer Error" to "Human Fix"           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host ""

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WTH {
    Write-Host "Installing WTH..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check if executable exists
    if (-not (Test-Path $ExecutablePath)) {
        Write-Host "ERROR: $ExecutableName not found at $ExecutablePath" -ForegroundColor Red
        Write-Host "Please ensure wth.exe is in the same directory as this installer." -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Create installation directory
    Write-Host "Creating installation directory: $InstallDir"
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
    
    # Copy executable
    Write-Host "Copying executable..."
    Copy-Item -Path $ExecutablePath -Destination $InstallDir -Force
    
    # Create PowerShell hook script
    Write-Host "Creating shell integration script..."
    $hookScript = @'
# WTH (What The Hell) - PowerShell Hook
$WTH_ERROR_FILE = "$env:USERPROFILE\.wth_last_error"

function global:Invoke-WthHook {
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
        if ($Error.Count -gt 0) {
            $exitCode = 1
        } else {
            $exitCode = 0
        }
    }
    
    if ($exitCode -ne 0 -and $exitCode -ne $null) {
        $errorOutput = ""
        if ($Error.Count -gt 0) {
            $lastError = $Error[0]
            $errorOutput = $lastError.ToString()
            if ($lastError.Exception) {
                $errorOutput += "`n" + $lastError.Exception.Message
            }
            if ($lastError.ScriptStackTrace) {
                $errorOutput += "`n" + $lastError.ScriptStackTrace
            }
        }
        
        if ([string]::IsNullOrWhiteSpace($errorOutput)) {
            $errorOutput = "Command exited with code $exitCode"
        }
        
        try {
            $content = "$exitCode`n$errorOutput"
            [System.IO.File]::WriteAllText($WTH_ERROR_FILE, $content)
        } catch {
            # Silently fail
        }
    }
    $global:LASTEXITCODE = $exitCode
}

$global:__WTH_ORIGINAL_PROMPT = $function:prompt
function global:prompt {
    $result = & $global:__WTH_ORIGINAL_PROMPT
    Invoke-WthHook
    return $result
}

Write-Host "WTH error capture enabled. Run failed commands, then type 'wth' to analyze." -ForegroundColor Green
'@
    
    Set-Content -Path "$ScriptsDir\wth-hook.ps1" -Value $hookScript -Force
    
    # Add to PATH
    Write-Host "Adding to system PATH..."
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable(
            "PATH",
            "$currentPath;$InstallDir",
            "Machine"
        )
        Write-Host "✓ Added $InstallDir to PATH" -ForegroundColor Green
    } else {
        Write-Host "✓ Already in PATH" -ForegroundColor Yellow
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
        Write-Host "✓ Added hook to PowerShell profile" -ForegroundColor Green
    } else {
        Write-Host "✓ Hook already in profile" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  Installation Complete!                                  ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "To start using WTH:" -ForegroundColor Cyan
    Write-Host "1. Close this window and restart PowerShell"
    Write-Host "2. Run a command that fails"
    Write-Host "3. Type 'wth' to see the explanation"
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  PS> python -c 'import pandas'"
    Write-Host "  PS> wth"
    Write-Host ""
    Read-Host "Press Enter to close"
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
        Write-Host "✓ Removed from PATH" -ForegroundColor Green
    }
    
    # Remove from PowerShell profile
    Write-Host "Removing from PowerShell profile..."
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (Test-Path $profilePath) {
        $profileContent = Get-Content -Path $profilePath -Raw
        $profileContent = $profileContent -replace "(?m)^# WTH Error Capture Hook\r?\n.*wth-hook\.ps1.*\r?\n", ""
        Set-Content -Path $profilePath -Value $profileContent
        Write-Host "✓ Removed hook from profile" -ForegroundColor Green
    }
    
    # Remove installation directory
    Write-Host "Removing installation files..."
    if (Test-Path $InstallDir) {
        Remove-Item -Path $InstallDir -Recurse -Force
        Write-Host "✓ Removed $InstallDir" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  Uninstallation Complete!                                ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to close"
}

# Main script
if (-not (Test-Administrator)) {
    Write-Host "ERROR: This installer must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please right-click 'WTH-Installer.bat' and select 'Run as administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

if ($Uninstall) {
    Uninstall-WTH
} else {
    Install-WTH
}
