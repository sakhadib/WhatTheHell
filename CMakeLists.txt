cmake_minimum_required(VERSION 3.15)
project(wth VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    src/main.cpp
    src/error_parser.cpp
    src/pattern_matcher.cpp
    src/sanitizer.cpp
)

# Header files
set(HEADERS
    include/error_parser.h
    include/pattern_matcher.h
    include/sanitizer.h
)

# Create executable
add_executable(wth ${SOURCES} ${HEADERS})

target_include_directories(wth PRIVATE include)

# Platform-specific settings
if(WIN32)
    target_compile_definitions(wth PRIVATE WINDOWS_BUILD)
elseif(UNIX)
    target_compile_definitions(wth PRIVATE UNIX_BUILD)
endif()

# Installation rules
install(TARGETS wth DESTINATION bin)
install(DIRECTORY scripts/ DESTINATION share/wth/scripts
        FILES_MATCHING PATTERN "*.ps1" PATTERN "*.sh")
