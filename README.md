# WTH (What The Hell)

**Translating "Computer Error" to "Human Fix"**

## Overview

`wth` is a command-line tool that analyzes error messages from failed commands and provides simple, actionable explanations and fixes in plain English.

## Features

- 🎯 **One error, one sentence** - No more parsing through stack traces
- 🔒 **Privacy-first** - Automatically scrubs API keys and sensitive data
- ⚡ **Fast** - Built in C++ for instant startup
- 🌐 **Cross-platform** - Works on Windows, Linux, and macOS
- 🔧 **Smart pattern matching** - Recognizes errors from Python, Node.js, Git, Bash, and more

## Installation

### Windows

1. Download and run the installer: `wth-installer.exe`
2. Follow the installation wizard
3. The installer will automatically set up shell integration for PowerShell

### Linux/macOS

```bash
# Build from source
mkdir build && cd build
cmake ..
make
sudo make install

# Add to your shell profile
echo 'source /usr/share/wth/scripts/wth-hook.sh' >> ~/.bashrc
source ~/.bashrc
```

## Usage

1. Run a command that fails:
   ```bash
   python script.py
   # ImportError: No module named 'pandas'
   # ... 20 lines of stack trace ...
   ```

2. Type `wth`:
   ```bash
   wth
   # ✗ Python module 'pandas' not found.
   # → Try: pip install pandas
   ```

That's it!

## Supported Error Types

- **Python**: ImportError, ModuleNotFoundError, SyntaxError, IndentationError, TypeError, etc.
- **Node.js**: ReferenceError, Module not found, SyntaxError
- **Git**: Merge conflicts, push failures, repository errors
- **Bash/Shell**: Command not found, permission denied, file not found
- **Compilers**: C/C++ undefined references, undeclared variables
- **Package Managers**: npm, pip errors

## Manual Usage

If automatic capture doesn't work, you can manually save error output:

```bash
# PowerShell
your-command 2>&1 | Out-File -FilePath "$env:USERPROFILE\.wth_last_error"
wth

# Bash/Zsh
your-command 2>&1 | tee ~/.wth_last_error
wth
```

## Building from Source

### Requirements

- CMake 3.15+
- C++17 compatible compiler (GCC 7+, Clang 5+, MSVC 2017+)
- Windows: Visual Studio 2017+ or MinGW-w64
- Linux/macOS: GCC or Clang

### Build Steps

```bash
# Clone the repository
git clone https://github.com/sakhadib/WhatTheHell.git
cd WhatTheHell

# Create build directory
mkdir build && cd build

# Configure and build
cmake ..
cmake --build . --config Release

# Install (requires admin/sudo)
cmake --install .
```

### Windows-specific

```powershell
# Using Visual Studio
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019"
cmake --build . --config Release

# Using MinGW
mkdir build
cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
```

## Privacy & Security

`wth` automatically sanitizes:
- AWS keys
- API tokens
- GitHub tokens
- Passwords and secrets
- Private keys
- Database connection strings
- Email addresses (partial)

All processing happens **locally** on your machine. No data is sent anywhere unless you explicitly configure an LLM API (future feature).

## Project Structure

```
wth/
├── src/
│   ├── main.cpp              # Main CLI application
│   ├── error_parser.cpp      # Reads and parses error files
│   ├── pattern_matcher.cpp   # Regex pattern matching engine
│   └── sanitizer.cpp         # Sensitive data scrubber
├── include/
│   ├── error_parser.h
│   ├── pattern_matcher.h
│   └── sanitizer.h
├── scripts/
│   ├── wth-hook.ps1          # PowerShell integration
│   └── wth-hook.sh           # Bash/Zsh integration
├── installer/
│   └── wth-installer.nsi     # Windows installer script
└── CMakeLists.txt            # Build configuration
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request to:
https://github.com/sakhadib/WhatTheHell

## License

MIT License - see LICENSE file for details

## Roadmap

- [ ] LLM fallback for unknown errors
- [ ] `wth --fix` auto-execution mode
- [ ] Language pack downloads
- [ ] VS Code extension
- [ ] More error pattern libraries

## Author

**sakhadib** - [GitHub](https://github.com/sakhadib)

Built with frustration and determination.
