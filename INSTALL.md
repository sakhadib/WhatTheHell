# WTH - Build and Installation Guide

## Quick Start (Windows)

### Option 1: Using Pre-built Installer (Recommended)

1. Download `wth-installer.exe`
2. Run as Administrator
3. Follow the installation wizard
4. Restart PowerShell

### Option 2: Build from Source + PowerShell Installer

1. **Install a C++ Compiler** (choose one):
   - **Visual Studio Build Tools** (Recommended)
     - Download from: https://visualstudio.microsoft.com/downloads/
     - Select "Build Tools for Visual Studio"
     - Install "Desktop development with C++"
   
   - **MinGW-w64** (Alternative)
     - Download from: https://www.mingw-w64.org/
     - Add to PATH

2. **Build the executable**:
   ```cmd
   REM Open "Developer Command Prompt for VS" (if using Visual Studio)
   cd d:\4_Projects\WhatTheHell
   build.bat
   ```

3. **Install using PowerShell**:
   ```powershell
   # Run PowerShell as Administrator
   cd d:\4_Projects\WhatTheHell\installer
   .\install.ps1
   ```

4. **Restart PowerShell** to activate the hook

### Option 3: Manual Build with MSVC

```cmd
REM Open Developer Command Prompt for VS
cd d:\4_Projects\WhatTheHell
mkdir build
cd build

REM Compile
cl /EHsc /std:c++17 /D WINDOWS_BUILD ^
   /I ..\include ^
   ..\src\main.cpp ^
   ..\src\error_parser.cpp ^
   ..\src\pattern_matcher.cpp ^
   ..\src\sanitizer.cpp ^
   /Fe:wth.exe

REM Install manually
copy wth.exe "C:\Program Files\wth\"
mkdir "C:\Program Files\wth\scripts"
copy ..\scripts\*.ps1 "C:\Program Files\wth\scripts\"
```

### Option 4: Using CMake (if installed)

```powershell
cd d:\4_Projects\WhatTheHell
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019"  # or your VS version
cmake --build . --config Release
cd ..
.\installer\install.ps1
```

## Linux/macOS Installation

### Requirements
- GCC 7+ or Clang 5+
- Make or CMake (optional)

### Build and Install

```bash
cd /path/to/WhatTheHell

# Make build script executable
chmod +x build.sh

# Build
./build.sh

# Install (requires sudo)
sudo cp build/wth /usr/local/bin/
sudo mkdir -p /usr/share/wth/scripts
sudo cp scripts/wth-hook.sh /usr/share/wth/scripts/

# Add to shell profile
echo 'source /usr/share/wth/scripts/wth-hook.sh' >> ~/.bashrc
source ~/.bashrc

# For Zsh
echo 'source /usr/share/wth/scripts/wth-hook.sh' >> ~/.zshrc
source ~/.zshrc
```

### Using CMake (Linux/macOS)

```bash
mkdir build && cd build
cmake ..
make
sudo make install

# Add to shell profile (same as above)
```

## Creating the Windows Installer (NSIS)

If you want to create a distributable installer:

1. **Install NSIS**:
   - Download from: https://nsis.sourceforge.io/
   - Install to default location

2. **Build the executable** (see above)

3. **Create installer**:
   ```cmd
   cd d:\4_Projects\WhatTheHell\installer
   "C:\Program Files (x86)\NSIS\makensis.exe" wth-installer.nsi
   ```

4. The installer will be created as `wth-installer.exe`

## Verifying Installation

After installation and restarting your shell:

```powershell
# Test that wth is in PATH
wth --version

# Test error capture
python -c "import nonexistent"  # This will fail
wth  # Should show: Python module 'nonexistent' not found
```

## Troubleshooting

### "wth not found"
- Windows: Restart PowerShell or run `$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")`
- Linux/Mac: Restart terminal or run `source ~/.bashrc` (or ~/.zshrc)

### No errors captured
- Windows: Check if hook is loaded: `Get-Content $PROFILE`
- Linux/Mac: Check if hook is sourced: `grep wth ~/.bashrc`
- Reload profile: `. $PROFILE` (PowerShell) or `source ~/.bashrc` (Bash)

### Compiler not found
- Windows: Install Visual Studio Build Tools or MinGW-w64
- Linux: `sudo apt install build-essential` (Debian/Ubuntu) or `sudo yum install gcc-c++` (RHEL/CentOS)
- macOS: `xcode-select --install`

### Permission denied during installation
- Run PowerShell/terminal as Administrator/sudo
- Check antivirus software isn't blocking the installation

## Uninstallation

### Windows (PowerShell Installer)
```powershell
# Run as Administrator
cd d:\4_Projects\WhatTheHell\installer
.\install.ps1 -Uninstall
```

### Windows (NSIS Installer)
- Use "Add or Remove Programs" in Windows Settings
- Or run the uninstaller from the installation directory

### Linux/macOS
```bash
sudo rm /usr/local/bin/wth
sudo rm -rf /usr/share/wth
# Remove from shell profile manually
```

## Development Build

For development purposes:

```bash
# Don't install, just build and test
cd d:\4_Projects\WhatTheHell\build

# Run directly
.\wth.exe --help

# Test manually by creating error file
echo "1" > "$env:USERPROFILE\.wth_last_error"
echo "ModuleNotFoundError: No module named 'pandas'" >> "$env:USERPROFILE\.wth_last_error"
.\wth.exe
```

## System Requirements

- **Windows**: Windows 7 or later
- **Linux**: Any modern distribution with glibc 2.17+
- **macOS**: macOS 10.12 or later
- **RAM**: < 10 MB
- **Disk**: < 5 MB

## Next Steps

After installation, see README.md for usage examples and configuration options.
