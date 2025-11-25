@echo off
REM Build script for WTH using MSVC (Visual Studio Developer Command Prompt required)

echo Building WTH (What The Hell)...
echo.

REM Check if we're in a VS Developer Command Prompt
where cl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: MSVC compiler not found!
    echo Please run this script from a Visual Studio Developer Command Prompt.
    echo Or install Visual Studio Build Tools from:
    echo https://visualstudio.microsoft.com/downloads/
    pause
    exit /b 1
)

REM Create build directory
if not exist build mkdir build
cd build

REM Compile the project
echo Compiling...
cl /EHsc /std:c++17 /D WINDOWS_BUILD ^
   /I ..\include ^
   ..\src\main.cpp ^
   ..\src\error_parser.cpp ^
   ..\src\pattern_matcher.cpp ^
   ..\src\sanitizer.cpp ^
   /Fe:wth.exe

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful! Executable: build\wth.exe
    echo.
    echo To install, run as administrator:
    echo   copy wth.exe "C:\Program Files\wth\"
    echo   mkdir "C:\Program Files\wth\scripts"
    echo   copy ..\scripts\*.ps1 "C:\Program Files\wth\scripts\"
) else (
    echo.
    echo Build failed!
    pause
    exit /b 1
)

cd ..
pause
