#include "error_parser.h"
#include "pattern_matcher.h"
#include "sanitizer.h"
#include <iostream>
#include <string>

// ANSI color codes for terminal formatting
#ifdef WINDOWS_BUILD
#include <windows.h>

void enableANSI() {
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hOut == INVALID_HANDLE_VALUE) return;
    
    DWORD dwMode = 0;
    if (!GetConsoleMode(hOut, &dwMode)) return;
    
    dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(hOut, dwMode);
}
#else
void enableANSI() {
    // ANSI is supported by default on Unix-like systems
}
#endif

const std::string RESET = "\033[0m";
const std::string BOLD = "\033[1m";
const std::string RED = "\033[31m";
const std::string GREEN = "\033[32m";
const std::string CYAN = "\033[36m";
const std::string WHITE = "\033[37m";

void printHelp() {
    std::cout << BOLD << "wth" << RESET << " - What The Hell (Error Translator)\n\n";
    std::cout << "Usage:\n";
    std::cout << "  wth              Analyze the last failed command\n";
    std::cout << "  wth --help       Show this help message\n";
    std::cout << "  wth --version    Show version information\n\n";
    std::cout << "To enable automatic error capturing, add this to your shell profile:\n\n";
    
#ifdef WINDOWS_BUILD
    std::cout << "PowerShell:\n";
    std::cout << "  Add to your $PROFILE:\n";
    std::cout << "  . \"C:\\Program Files\\wth\\scripts\\wth-hook.ps1\"\n\n";
#else
    std::cout << "Bash/Zsh:\n";
    std::cout << "  Add to your ~/.bashrc or ~/.zshrc:\n";
    std::cout << "  source /usr/share/wth/scripts/wth-hook.sh\n\n";
#endif
}

void printVersion() {
    std::cout << "wth version 1.0.0\n";
    std::cout << "Translating 'Computer Error' to 'Human Fix'\n";
}

int main(int argc, char* argv[]) {
    enableANSI();
    
    // Handle command line arguments
    if (argc > 1) {
        std::string arg = argv[1];
        if (arg == "--help" || arg == "-h") {
            printHelp();
            return 0;
        } else if (arg == "--version" || arg == "-v") {
            printVersion();
            return 0;
        } else {
            std::cerr << "Unknown option: " << arg << "\n";
            std::cerr << "Try 'wth --help' for more information.\n";
            return 1;
        }
    }
    
    // Parse the last error
    ErrorParser parser;
    ErrorInfo error = parser.parseLastError();
    
    if (!error.success) {
        std::cerr << RED << "✗ " << RESET << error.explanation << "\n";
        return 1;
    }
    
    // Check if last command was successful
    if (error.exit_code == 0) {
        std::cout << GREEN << "✓ " << RESET << error.explanation << "\n";
        return 0;
    }
    
    // Sanitize the error output
    Sanitizer sanitizer;
    std::string sanitized = sanitizer.sanitize(error.explanation);
    
    // Try to match against known patterns
    PatternMatcher matcher;
    MatchResult match = matcher.matchError(sanitized, error.exit_code);
    
    // Print the result
    std::cout << RED << "✗ " << RESET << BOLD << match.explanation << RESET << "\n";
    
    if (!match.fix_command.empty()) {
        std::cout << CYAN << "→ " << RESET << "Try: " << GREEN << match.fix_command << RESET << "\n";
    }
    
    return 0;
}
