#ifndef ERROR_PARSER_H
#define ERROR_PARSER_H

#include <string>
#include <vector>

struct ErrorInfo {
    std::string explanation;
    std::string fix_command;
    bool success;
    int exit_code;
};

class ErrorParser {
public:
    ErrorParser();
    
    // Read the last error from the temp file
    ErrorInfo parseLastError();
    
    // Get the path to the error log file
    static std::string getErrorFilePath();
    
private:
    std::string readFile(const std::string& path);
    std::vector<std::string> splitLines(const std::string& content);
};

#endif // ERROR_PARSER_H
