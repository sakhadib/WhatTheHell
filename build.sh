#!/bin/bash
# Build script for WTH using GCC/Clang

echo "Building WTH (What The Hell)..."
echo

# Check for compiler
if command -v g++ &> /dev/null; then
    CXX=g++
elif command -v clang++ &> /dev/null; then
    CXX=clang++
else
    echo "ERROR: No C++ compiler found!"
    echo "Please install g++ or clang++"
    exit 1
fi

echo "Using compiler: $CXX"

# Create build directory
mkdir -p build
cd build

# Compile the project
echo "Compiling..."
$CXX -std=c++17 -D UNIX_BUILD \
    -I ../include \
    ../src/main.cpp \
    ../src/error_parser.cpp \
    ../src/pattern_matcher.cpp \
    ../src/sanitizer.cpp \
    -o wth

if [ $? -eq 0 ]; then
    echo
    echo "Build successful! Executable: build/wth"
    echo
    echo "To install, run:"
    echo "  sudo cp wth /usr/local/bin/"
    echo "  sudo mkdir -p /usr/share/wth/scripts"
    echo "  sudo cp ../scripts/wth-hook.sh /usr/share/wth/scripts/"
else
    echo
    echo "Build failed!"
    exit 1
fi

cd ..
