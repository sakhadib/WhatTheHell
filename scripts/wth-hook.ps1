# WTH (What The Hell) - PowerShell Hook
# This script captures failed commands and saves their output for wth to analyze

# Path to the error log file
$WTH_ERROR_FILE = "$env:USERPROFILE\.wth_last_error"

# Store the last command output temporarily
$global:WTH_LAST_OUTPUT = ""
$global:WTH_LAST_EXITCODE = 0

# Hook function that runs after each command
function global:Invoke-WthHook {
    # Get the last command exit code
    $exitCode = $LASTEXITCODE
    
    # If the exit code is null, check for errors in the error stream
    if ($null -eq $exitCode) {
        if ($Error.Count -gt 0) {
            $exitCode = 1
        } else {
            $exitCode = 0
        }
    }
    
    # Only capture if the command failed
    if ($exitCode -ne 0 -and $exitCode -ne $null) {
        # Get the last error from the error stream
        $errorOutput = ""
        
        if ($Error.Count -gt 0) {
            # Get the most recent error
            $lastError = $Error[0]
            $errorOutput = $lastError.ToString()
            
            # Add exception details if available
            if ($lastError.Exception) {
                $errorOutput += "`n" + $lastError.Exception.Message
            }
            
            # Add script stack trace if available
            if ($lastError.ScriptStackTrace) {
                $errorOutput += "`n" + $lastError.ScriptStackTrace
            }
        }
        
        # If we don't have error stream content, try to capture the last output
        if ([string]::IsNullOrWhiteSpace($errorOutput)) {
            # This is a fallback - PowerShell doesn't easily let us capture arbitrary command output
            $errorOutput = "Command exited with code $exitCode"
        }
        
        # Write to the error file
        try {
            # Format: EXIT_CODE\nOUTPUT
            $content = "$exitCode`n$errorOutput"
            [System.IO.File]::WriteAllText($WTH_ERROR_FILE, $content)
        } catch {
            # Silently fail if we can't write the file
        }
    }
    
    # Reset the last exit code to avoid affecting the prompt
    $global:LASTEXITCODE = $exitCode
}

# Wrapper function for common commands to capture output
function global:Invoke-WthCommand {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Command,
        
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    try {
        # Execute the command and capture both stdout and stderr
        $output = & $Command @Arguments 2>&1 | Tee-Object -FilePath $tempFile
        $exitCode = $LASTEXITCODE
        
        # If command failed, save the output
        if ($exitCode -ne 0) {
            $errorContent = Get-Content -Path $tempFile -Raw
            $content = "$exitCode`n$errorContent"
            [System.IO.File]::WriteAllText($WTH_ERROR_FILE, $content)
        }
        
        # Return the output
        return $output
    } finally {
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
}

# Add the hook to the prompt
$global:__WTH_ORIGINAL_PROMPT = $function:prompt

function global:prompt {
    # Call the original prompt
    $result = & $global:__WTH_ORIGINAL_PROMPT
    
    # Run our hook
    Invoke-WthHook
    
    return $result
}

Write-Host "WTH error capture enabled. Run failed commands, then type 'wth' to analyze." -ForegroundColor Green
