#include "sanitizer.h"

Sanitizer::Sanitizer() {
    initializePatterns();
}

void Sanitizer::initializePatterns() {
    // AWS Keys
    sensitive_patterns.push_back(
        std::regex(R"((AKIA[0-9A-Z]{16}))", std::regex::icase)
    );
    
    // Generic API Keys
    sensitive_patterns.push_back(
        std::regex(R"((sk-[a-zA-Z0-9]{20,}))", std::regex::icase)
    );
    
    // GitHub tokens
    sensitive_patterns.push_back(
        std::regex(R"((ghp_[a-zA-Z0-9]{36}))", std::regex::icase)
    );
    
    // Generic tokens/secrets
    sensitive_patterns.push_back(
        std::regex(R"((token|secret|password|passwd|pwd)[=:]\s*['\"]?([^\s'\"]{8,})['\"]?)", std::regex::icase)
    );
    
    // Bearer tokens
    sensitive_patterns.push_back(
        std::regex(R"(Bearer\s+([a-zA-Z0-9\-._~+/]+=*))", std::regex::icase)
    );
    
    // Basic Auth
    sensitive_patterns.push_back(
        std::regex(R"(Basic\s+([A-Za-z0-9+/=]+))", std::regex::icase)
    );
    
    // Private keys (header/footer only)
    sensitive_patterns.push_back(
        std::regex(R"(-----BEGIN [A-Z\s]+PRIVATE KEY-----[\s\S]*?-----END [A-Z\s]+PRIVATE KEY-----)", std::regex::icase)
    );
    
    // Database connection strings
    sensitive_patterns.push_back(
        std::regex(R"((postgresql|mysql|mongodb):\/\/[^:]+:([^@]+)@)", std::regex::icase)
    );
    
    // Email addresses (partial sanitization)
    sensitive_patterns.push_back(
        std::regex(R"(([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))")
    );
}

std::string Sanitizer::sanitize(const std::string& text) {
    std::string result = text;
    
    // AWS Keys
    result = std::regex_replace(result, sensitive_patterns[0], "[AWS_KEY_REDACTED]");
    
    // Generic API Keys
    result = std::regex_replace(result, sensitive_patterns[1], "[API_KEY_REDACTED]");
    
    // GitHub tokens
    result = std::regex_replace(result, sensitive_patterns[2], "[GITHUB_TOKEN_REDACTED]");
    
    // Generic tokens/secrets - keep the key name but hide the value
    result = std::regex_replace(result, sensitive_patterns[3], "$1=[REDACTED]");
    
    // Bearer tokens
    result = std::regex_replace(result, sensitive_patterns[4], "Bearer [REDACTED]");
    
    // Basic Auth
    result = std::regex_replace(result, sensitive_patterns[5], "Basic [REDACTED]");
    
    // Private keys
    result = std::regex_replace(result, sensitive_patterns[6], "[PRIVATE_KEY_REDACTED]");
    
    // Database connection strings - keep the structure but hide password
    result = std::regex_replace(result, sensitive_patterns[7], "$1://[USER]:[REDACTED]@");
    
    // Email addresses - partial obfuscation
    std::smatch email_match;
    std::string temp = result;
    result = "";
    std::string::const_iterator search_start(temp.cbegin());
    
    while (std::regex_search(search_start, temp.cend(), email_match, sensitive_patterns[8])) {
        result += email_match.prefix();
        std::string username = email_match[1].str();
        std::string domain = email_match[2].str();
        
        // Obfuscate username but keep first and last char
        if (username.length() > 2) {
            result += username[0];
            result += "***";
            result += username[username.length() - 1];
        } else {
            result += "***";
        }
        result += "@" + domain;
        
        search_start = email_match.suffix().first;
    }
    result += std::string(search_start, temp.cend());
    
    return result;
}
