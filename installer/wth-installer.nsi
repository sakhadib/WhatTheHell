; WTH (What The Hell) - Windows Installer Script
; Requires NSIS (Nullsoft Scriptable Install System)
; Download from: https://nsis.sourceforge.io/

!define PRODUCT_NAME "WTH (What The Hell)"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "WTH Project"
!define PRODUCT_WEB_SITE "https://github.com/yourusername/wth"

; Includes
!include "MUI2.nsh"
!include "FileFunc.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME

; License page (you should add a LICENSE.txt file)
; !insertmacro MUI_PAGE_LICENSE "LICENSE.txt"

; Directory page
!insertmacro MUI_PAGE_DIRECTORY

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.md"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; Installer settings
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "wth-installer.exe"
InstallDir "$PROGRAMFILES\wth"
InstallDirRegKey HKLM "Software\WTH" "Install_Dir"
ShowInstDetails show
ShowUnInstDetails show

; Request admin privileges
RequestExecutionLevel admin

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    SetOverwrite on
    
    ; Copy main executable
    File "..\build\wth.exe"
    
    ; Copy README
    File "..\README.md"
    
    ; Create scripts directory
    CreateDirectory "$INSTDIR\scripts"
    SetOutPath "$INSTDIR\scripts"
    
    ; Copy shell integration scripts
    File "..\scripts\wth-hook.ps1"
    File "..\scripts\wth-hook.sh"
    
    ; Add to PATH
    EnVar::SetHKLM
    EnVar::AddValue "PATH" "$INSTDIR"
    
SectionEnd

Section "PowerShell Integration" SEC02
    ; Create PowerShell profile if it doesn't exist
    nsExec::ExecToLog 'powershell -Command "if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }"'
    
    ; Add hook to PowerShell profile
    nsExec::ExecToLog 'powershell -Command "$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue; if ($profileContent -notlike \"*wth-hook.ps1*\") { Add-Content -Path $PROFILE -Value \"`n# WTH Error Capture Hook`n. \"$INSTDIR\scripts\wth-hook.ps1\"\" }"'
    
    DetailPrint "PowerShell integration added to profile"
SectionEnd

Section -Post
    ; Write uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    ; Write registry keys for Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH" "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH" "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH" "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    WriteRegStr HKLM "Software\WTH" "Install_Dir" "$INSTDIR"
    
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH" "EstimatedSize" "$0"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Core WTH application and files"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Automatically add error capture to PowerShell"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller
Section Uninstall
    ; Remove from PATH
    EnVar::SetHKLM
    EnVar::DeleteValue "PATH" "$INSTDIR"
    
    ; Remove PowerShell profile hook
    nsExec::ExecToLog 'powershell -Command "$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue; $profileContent = $profileContent -replace \"(?m)^# WTH Error Capture Hook\r?\n.*wth-hook\.ps1.*\r?\n\", \"\"; Set-Content -Path $PROFILE -Value $profileContent"'
    
    ; Remove files
    Delete "$INSTDIR\wth.exe"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\scripts\wth-hook.ps1"
    Delete "$INSTDIR\scripts\wth-hook.sh"
    Delete "$INSTDIR\uninstall.exe"
    
    ; Remove directories
    RMDir "$INSTDIR\scripts"
    RMDir "$INSTDIR"
    
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTH"
    DeleteRegKey HKLM "Software\WTH"
    
    SetAutoClose true
SectionEnd
