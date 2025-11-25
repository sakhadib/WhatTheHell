@echo off
REM WTH Installer Wrapper
REM This batch file will launch the PowerShell installer with admin privileges

echo ======================================
echo  WTH (What The Hell) - Installer
echo  Translating "Computer Error" to "Human Fix"
echo ======================================
echo.

REM Check if wth.exe exists
if not exist "%~dp0wth.exe" (
    echo ERROR: wth.exe not found!
    echo Please ensure wth.exe is in the same directory as this installer.
    pause
    exit /b 1
)

REM Launch PowerShell installer with admin privileges
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0install.ps1\"'"

echo.
echo The installer will open in a new window with administrator privileges.
echo Please follow the prompts in that window.
echo.
pause
