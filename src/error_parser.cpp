#include "error_parser.h"
#include <fstream>
#include <sstream>
#include <cstdlib>

#ifdef WINDOWS_BUILD
#include <windows.h>
#include <shlobj.h>
#else
#include <unistd.h>
#include <pwd.h>
#endif

ErrorParser::ErrorParser() {}

std::string ErrorParser::getErrorFilePath() {
#ifdef WINDOWS_BUILD
    char path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPathA(NULL, CSIDL_PROFILE, NULL, 0, path))) {
        std::string home(path);
        return home + "\\.wth_last_error";
    }
    return "C:\\.wth_last_error";
#else
    const char* home = getenv("HOME");
    if (home == nullptr) {
        struct passwd* pwd = getpwuid(getuid());
        if (pwd) {
            home = pwd->pw_dir;
        }
    }
    std::string home_str = home ? home : "/tmp";
    return home_str + "/.wth_last_error";
#endif
}

std::string ErrorParser::readFile(const std::string& path) {
    std::ifstream file(path);
    if (!file.is_open()) {
        return "";
    }
    
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

std::vector<std::string> ErrorParser::splitLines(const std::string& content) {
    std::vector<std::string> lines;
    std::stringstream ss(content);
    std::string line;
    
    while (std::getline(ss, line)) {
        lines.push_back(line);
    }
    
    return lines;
}

ErrorInfo ErrorParser::parseLastError() {
    ErrorInfo info;
    info.success = false;
    info.exit_code = 0;
    
    std::string filepath = getErrorFilePath();
    std::string content = readFile(filepath);
    
    if (content.empty()) {
        info.explanation = "No error captured. Run a command that fails, then try 'wth'.";
        return info;
    }
    
    // Parse the file format: EXIT_CODE\n<output>
    auto lines = splitLines(content);
    if (lines.empty()) {
        info.explanation = "Error file is empty.";
        return info;
    }
    
    // First line should be the exit code
    try {
        info.exit_code = std::stoi(lines[0]);
    } catch (...) {
        info.exit_code = -1;
    }
    
    // Check if the command was actually successful
    if (info.exit_code == 0) {
        info.explanation = "Last command finished successfully.";
        info.success = true;
        return info;
    }
    
    // Reconstruct the error output (everything after the first line)
    std::string error_output;
    for (size_t i = 1; i < lines.size(); ++i) {
        error_output += lines[i];
        if (i < lines.size() - 1) {
            error_output += "\n";
        }
    }
    
    info.explanation = error_output;
    info.success = true;
    
    return info;
}
