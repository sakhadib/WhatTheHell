# 🚀 QUICK START - WTH (What The Hell)

## For Users Who Just Want It Working

### Windows (Recommended Method)

Open PowerShell and run:

```powershell
cd d:\4_Projects\WhatTheHell
.\setup.ps1
```

This will:
1. Check if you have a compiler (and guide you if you don't)
2. Build the executable automatically
3. Install it to your system
4. Set up error capturing

**That's it!** Restart PowerShell and you're done.

---

## Manual Installation (If Setup Script Fails)

### Step 1: Install a C++ Compiler

**Option A: Visual Studio Build Tools** (Recommended)
1. Download: https://visualstudio.microsoft.com/downloads/
2. Select "Build Tools for Visual Studio"
3. Install "Desktop development with C++"

**Option B: MinGW-w64**
1. Download: https://www.mingw-w64.org/
2. Install and add to PATH

### Step 2: Build WTH

**With MSVC:**
```cmd
# Open "Developer Command Prompt for VS"
cd d:\4_Projects\WhatTheHell
build.bat
```

**With MinGW:**
```powershell
cd d:\4_Projects\WhatTheHell
g++ -std=c++17 -D WINDOWS_BUILD -I include src/*.cpp -o build/wth.exe
```

### Step 3: Install WTH

```powershell
# Run PowerShell as Administrator
cd d:\4_Projects\WhatTheHell\installer
.\install.ps1
```

### Step 4: Restart PowerShell

Close and reopen PowerShell (or run `. $PROFILE`)

---

## Testing It Out

```powershell
# Try a command that will fail
python -c "import pandas"

# Now ask "what the hell?"
wth
```

You should see:
```
✗ Python module 'pandas' not found.
→ Try: pip install pandas
```

---

## If It Doesn't Work

### "wth: command not found"
```powershell
# Refresh your PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Or restart PowerShell
```

### "No error captured"
```powershell
# Check if the hook is loaded
Get-Content $PROFILE

# You should see a line with "wth-hook.ps1"
# If not, reload it:
. $PROFILE
```

### Still not working?
```powershell
# Load the hook manually
. "C:\Program Files\wth\scripts\wth-hook.ps1"

# Then try your failing command again
```

---

## Uninstall

```powershell
# Run as Administrator
cd d:\4_Projects\WhatTheHell\installer
.\install.ps1 -Uninstall
```

---

## More Info

- Full documentation: `README.md`
- Installation guide: `INSTALL.md`
- Project overview: `PROJECT_OVERVIEW.md`

---

## Linux/macOS Quick Start

```bash
cd /path/to/WhatTheHell
chmod +x build.sh
./build.sh

# Install
sudo cp build/wth /usr/local/bin/
sudo mkdir -p /usr/share/wth/scripts
sudo cp scripts/wth-hook.sh /usr/share/wth/scripts/

# Add to shell profile
echo 'source /usr/share/wth/scripts/wth-hook.sh' >> ~/.bashrc
source ~/.bashrc
```

---

**Need help?** Check PROJECT_OVERVIEW.md for troubleshooting and detailed explanations.
