@echo off
:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell is not installed on this system.
    exit /b 1
)

:: Call the PowerShell script with bypassed execution policy
powershell.exe -ExecutionPolicy Bypass -File "%~dp0ps-configure.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0ps-install.ps1"