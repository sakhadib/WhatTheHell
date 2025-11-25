#include "pattern_matcher.h"
#include <algorithm>

PatternMatcher::PatternMatcher() {
    initializePatterns();
}

void PatternMatcher::initializePatterns() {
    // Python Errors
    patterns.push_back({
        std::regex(R"((ModuleNotFoundError|ImportError):\s*No module named '([^']+)')"),
        "Python module '$2' not found.",
        "pip install $2",
        "python"
    });
    
    patterns.push_back({
        std::regex(R"(FileNotFoundError:.*'([^']+)')"),
        "File '$1' does not exist.",
        "Check if the file path is correct.",
        "python"
    });
    
    patterns.push_back({
        std::regex(R"((TypeError|ValueError|AttributeError|KeyError):\s*(.+))"),
        "Python $1: $2",
        "Review your code logic and variable types.",
        "python"
    });
    
    patterns.push_back({
        std::regex(R"(IndentationError:\s*(.+))"),
        "Python indentation error: $1",
        "Fix the indentation in your Python code.",
        "python"
    });
    
    patterns.push_back({
        std::regex(R"(SyntaxError:\s*(.+))"),
        "Python syntax error: $1",
        "Check your Python syntax.",
        "python"
    });
    
    // Node.js Errors
    patterns.push_back({
        std::regex(R"(ReferenceError:\s*([^\s]+)\s*is not defined)"),
        "Variable '$1' is not defined.",
        "Declare the variable or check for typos.",
        "nodejs"
    });
    
    patterns.push_back({
        std::regex(R"(Error: Cannot find module '([^']+)')"),
        "Node.js module '$1' not found.",
        "npm install $1",
        "nodejs"
    });
    
    patterns.push_back({
        std::regex(R"((TypeError|SyntaxError):\s*(.+))"),
        "Node.js $1: $2",
        "Review your JavaScript code.",
        "nodejs"
    });
    
    // Git Errors
    patterns.push_back({
        std::regex(R"(fatal:\s*not a git repository)"),
        "Not a git repository.",
        "git init",
        "git"
    });
    
    patterns.push_back({
        std::regex(R"(fatal:\s*(.+))"),
        "Git error: $1",
        "Review the git command and repository state.",
        "git"
    });
    
    patterns.push_back({
        std::regex(R"(error:\s*failed to push some refs)"),
        "Git push failed. Remote has changes you don't have locally.",
        "git pull --rebase && git push",
        "git"
    });
    
    patterns.push_back({
        std::regex(R"(CONFLICT\s*\(.*\):\s*Merge conflict in (.+))"),
        "Merge conflict in '$1'.",
        "Resolve conflicts manually, then git add and git commit.",
        "git"
    });
    
    // Bash/Shell Errors
    patterns.push_back({
        std::regex(R"(command not found:\s*(\S+))"),
        "Command '$1' not found.",
        "Install '$1' or check if it's in your PATH.",
        "bash"
    });
    
    patterns.push_back({
        std::regex(R"(([^:]+):\s*command not found)"),
        "Command '$1' not found.",
        "Install '$1' or check if it's in your PATH.",
        "bash"
    });
    
    patterns.push_back({
        std::regex(R"(Permission denied)"),
        "Permission denied.",
        "Check file permissions or try running with elevated privileges.",
        "bash"
    });
    
    patterns.push_back({
        std::regex(R"(No such file or directory)"),
        "File or directory not found.",
        "Check if the path exists.",
        "bash"
    });
    
    // Compiler Errors (C/C++)
    patterns.push_back({
        std::regex(R"(error:\s*'([^']+)'\s*was not declared in this scope)"),
        "Variable or function '$1' not declared.",
        "Declare '$1' before using it or include the right header.",
        "cpp"
    });
    
    patterns.push_back({
        std::regex(R"(undefined reference to `([^']+)')"),
        "Linker error: '$1' is not defined.",
        "Link the library that contains '$1' or implement the function.",
        "cpp"
    });
    
    // Package Manager Errors
    patterns.push_back({
        std::regex(R"(npm ERR!.*EACCES.*permission denied)"),
        "NPM permission denied.",
        "Try 'npm install' without sudo, or fix npm permissions.",
        "npm"
    });
    
    patterns.push_back({
        std::regex(R"(Could not find a version that satisfies the requirement (.+))"),
        "Pip cannot find package '$1'.",
        "Check the package name or try updating pip.",
        "pip"
    });
    
    // PowerShell Errors
    patterns.push_back({
        std::regex(R"(The term '([^']+)' is not recognized)"),
        "PowerShell command '$1' not recognized.",
        "Install the command or check if it's in your PATH.",
        "powershell"
    });
    
    // Generic exit code patterns
    patterns.push_back({
        std::regex(R"(exit\s+(?:code|status)\s*[:=]?\s*(\d+))"),
        "Command exited with code $1.",
        "Check the command documentation for exit code meanings.",
        "generic"
    });
}

std::string PatternMatcher::replaceTemplate(const std::string& template_str, const std::smatch& matches) {
    std::string result = template_str;
    
    // Replace $1, $2, etc. with captured groups
    for (size_t i = 1; i < matches.size(); ++i) {
        std::string placeholder = "$" + std::to_string(i);
        std::string replacement = matches[i].str();
        
        size_t pos = 0;
        while ((pos = result.find(placeholder, pos)) != std::string::npos) {
            result.replace(pos, placeholder.length(), replacement);
            pos += replacement.length();
        }
    }
    
    return result;
}

MatchResult PatternMatcher::tryMatch(const Pattern& pattern, const std::string& text) {
    MatchResult result;
    result.matched = false;
    
    std::smatch matches;
    if (std::regex_search(text, matches, pattern.regex)) {
        result.matched = true;
        result.explanation = replaceTemplate(pattern.explanation_template, matches);
        result.fix_command = replaceTemplate(pattern.fix_template, matches);
    }
    
    return result;
}

MatchResult PatternMatcher::matchError(const std::string& error_output, int exit_code) {
    MatchResult result;
    result.matched = false;
    
    // Try each pattern
    for (const auto& pattern : patterns) {
        result = tryMatch(pattern, error_output);
        if (result.matched) {
            return result;
        }
    }
    
    // If no pattern matched, return a generic message
    if (exit_code != 0) {
        result.matched = true;
        result.explanation = "Command failed with exit code " + std::to_string(exit_code) + ".";
        result.fix_command = "Review the error output above for details.";
    } else {
        result.explanation = "Could not parse the error.";
        result.fix_command = "";
    }
    
    return result;
}
