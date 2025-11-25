# WTH Quick Setup - Automated Build and Install Script
# This script will guide you through the installation process

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   WTH (What The Hell) - Setup Wizard                    ║
║   Translating "Computer Error" to "Human Fix"           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host ""

# Check for admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some installation steps may fail without admin rights." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Write-Host "Exiting. Please run PowerShell as Administrator and try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Step 1: Checking for C++ compiler..." -ForegroundColor Cyan

# Check for MSVC
$hasMSVC = $false
try {
    $null = Get-Command cl -ErrorAction Stop
    $hasMSVC = $true
    Write-Host "✓ Found MSVC compiler" -ForegroundColor Green
} catch {
    Write-Host "✗ MSVC not found" -ForegroundColor Yellow
}

# Check for MinGW
$hasMinGW = $false
try {
    $null = Get-Command g++ -ErrorAction Stop
    $hasMinGW = $true
    Write-Host "✓ Found MinGW g++ compiler" -ForegroundColor Green
} catch {
    Write-Host "✗ MinGW not found" -ForegroundColor Yellow
}

if (-not $hasMSVC -and -not $hasMinGW) {
    Write-Host ""
    Write-Host "❌ No C++ compiler found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "You need to install a C++ compiler to build WTH." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "1. Visual Studio Build Tools (Recommended)"
    Write-Host "   Download: https://visualstudio.microsoft.com/downloads/"
    Write-Host "   Select 'Desktop development with C++'"
    Write-Host ""
    Write-Host "2. MinGW-w64"
    Write-Host "   Download: https://www.mingw-w64.org/"
    Write-Host ""
    
    $openURL = Read-Host "Open Visual Studio downloads page? (y/N)"
    if ($openURL -eq 'y' -or $openURL -eq 'Y') {
        Start-Process "https://visualstudio.microsoft.com/downloads/"
    }
    
    Write-Host ""
    Write-Host "After installing a compiler, please run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Step 2: Building WTH executable..." -ForegroundColor Cyan

$buildDir = Join-Path $PSScriptRoot "build"

# Create build directory
if (Test-Path $buildDir) {
    Remove-Item -Path $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildDir | Out-Null

Set-Location $buildDir

$buildSuccess = $false

if ($hasMSVC) {
    Write-Host "Using MSVC compiler..." -ForegroundColor Cyan
    
    $sources = @(
        "..\src\main.cpp",
        "..\src\error_parser.cpp",
        "..\src\pattern_matcher.cpp",
        "..\src\sanitizer.cpp"
    )
    
    $cmd = "cl /EHsc /std:c++17 /D WINDOWS_BUILD /I ..\include $($sources -join ' ') /Fe:wth.exe 2>&1"
    
    try {
        $output = Invoke-Expression $cmd
        if (Test-Path "wth.exe") {
            $buildSuccess = $true
            Write-Host "✓ Build successful!" -ForegroundColor Green
        } else {
            Write-Host "✗ Build failed" -ForegroundColor Red
            Write-Host $output
        }
    } catch {
        Write-Host "✗ Build failed: $_" -ForegroundColor Red
    }
    
} elseif ($hasMinGW) {
    Write-Host "Using MinGW compiler..." -ForegroundColor Cyan
    
    try {
        $output = g++ -std=c++17 -D WINDOWS_BUILD `
            -I ..\include `
            ..\src\main.cpp `
            ..\src\error_parser.cpp `
            ..\src\pattern_matcher.cpp `
            ..\src\sanitizer.cpp `
            -o wth.exe 2>&1
        
        if (Test-Path "wth.exe") {
            $buildSuccess = $true
            Write-Host "✓ Build successful!" -ForegroundColor Green
        } else {
            Write-Host "✗ Build failed" -ForegroundColor Red
            Write-Host $output
        }
    } catch {
        Write-Host "✗ Build failed: $_" -ForegroundColor Red
    }
}

Set-Location $PSScriptRoot

if (-not $buildSuccess) {
    Write-Host ""
    Write-Host "❌ Failed to build WTH" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can try building manually:" -ForegroundColor Cyan
    Write-Host "  1. Open 'Developer Command Prompt for VS'"
    Write-Host "  2. Run: build.bat"
    exit 1
}

Write-Host ""
Write-Host "Step 3: Installing WTH..." -ForegroundColor Cyan

if ($isAdmin) {
    # Run installer
    & "$PSScriptRoot\installer\install.ps1"
} else {
    Write-Host "⚠️  Cannot install without admin privileges" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To complete installation, run PowerShell as Administrator and execute:" -ForegroundColor Cyan
    Write-Host "  cd '$PSScriptRoot\installer'"
    Write-Host "  .\install.ps1"
    Write-Host ""
    Write-Host "Or manually copy the files:" -ForegroundColor Cyan
    Write-Host "  1. Copy build\wth.exe to a directory in your PATH"
    Write-Host "  2. Source the hook: . '$PSScriptRoot\scripts\wth-hook.ps1'"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Setup Complete!                                         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart PowerShell (or run: . `$PROFILE)"
Write-Host "2. Try it out:"
Write-Host "     PS> python -c 'import pandas'"
Write-Host "     PS> wth"
Write-Host ""
Write-Host "For more information, see README.md" -ForegroundColor Gray
Write-Host ""
