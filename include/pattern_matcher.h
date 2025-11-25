#ifndef PATTERN_MATCHER_H
#define PATTERN_MATCHER_H

#include <string>
#include <vector>
#include <regex>

struct Pattern {
    std::regex regex;
    std::string explanation_template;
    std::string fix_template;
    std::string language;
};

struct MatchResult {
    bool matched;
    std::string explanation;
    std::string fix_command;
};

class PatternMatcher {
public:
    PatternMatcher();
    
    // Try to match the error output against known patterns
    MatchResult matchError(const std::string& error_output, int exit_code);
    
private:
    std::vector<Pattern> patterns;
    
    void initializePatterns();
    MatchResult tryMatch(const Pattern& pattern, const std::string& text);
    std::string replaceTemplate(const std::string& template_str, const std::smatch& matches);
};

#endif // PATTERN_MATCHER_H
