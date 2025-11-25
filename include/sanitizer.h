#ifndef SANITIZER_H
#define SANITIZER_H

#include <string>
#include <vector>
#include <regex>

class Sanitizer {
public:
    Sanitizer();
    
    // Remove sensitive information from text
    std::string sanitize(const std::string& text);
    
private:
    std::vector<std::regex> sensitive_patterns;
    
    void initializePatterns();
};

#endif // SANITIZER_H
