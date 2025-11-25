#!/bin/bash
# WTH (What The Hell) - Bash/Zsh Hook
# This script captures failed commands and saves their output for wth to analyze

# Path to the error log file
WTH_ERROR_FILE="$HOME/.wth_last_error"

# Temporary file to store command output
WTH_TEMP_OUTPUT="/tmp/wth_output_$$"

# Hook function that runs after each command
__wth_capture_error() {
    local exit_code=$?
    
    # Only capture if the command failed (exit code != 0)
    if [ $exit_code -ne 0 ]; then
        # Try to get the last command's stderr from our trap
        if [ -f "$WTH_TEMP_OUTPUT" ] && [ -s "$WTH_TEMP_OUTPUT" ]; then
            # File exists and has content
            echo "$exit_code" > "$WTH_ERROR_FILE"
            cat "$WTH_TEMP_OUTPUT" >> "$WTH_ERROR_FILE"
            rm -f "$WTH_TEMP_OUTPUT"
        else
            # Fallback: just store the exit code
            echo "$exit_code" > "$WTH_ERROR_FILE"
            echo "Command exited with code $exit_code" >> "$WTH_ERROR_FILE"
        fi
    fi
    
    return $exit_code
}

# For Bash: use DEBUG trap to capture command output
if [ -n "$BASH_VERSION" ]; then
    # Bash-specific implementation
    __wth_debug_trap() {
        # Clear the temp file before each command
        : > "$WTH_TEMP_OUTPUT"
    }
    
    # Set up traps
    trap '__wth_debug_trap' DEBUG
    PROMPT_COMMAND="__wth_capture_error${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    
elif [ -n "$ZSH_VERSION" ]; then
    # Zsh-specific implementation
    autoload -Uz add-zsh-hook
    
    __wth_preexec() {
        # Clear the temp file before each command
        : > "$WTH_TEMP_OUTPUT"
    }
    
    __wth_precmd() {
        __wth_capture_error
    }
    
    add-zsh-hook preexec __wth_preexec
    add-zsh-hook precmd __wth_precmd
fi

# Wrapper function to explicitly capture command output
wth_run() {
    local temp_err="/tmp/wth_err_$$"
    
    # Run the command and capture stderr
    "$@" 2> >(tee "$temp_err" >&2)
    local exit_code=$?
    
    # If command failed, save the error
    if [ $exit_code -ne 0 ]; then
        echo "$exit_code" > "$WTH_ERROR_FILE"
        cat "$temp_err" >> "$WTH_ERROR_FILE" 2>/dev/null
    fi
    
    rm -f "$temp_err"
    return $exit_code
}

echo "WTH error capture enabled. Run failed commands, then type 'wth' to analyze."
