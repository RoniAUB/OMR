@echo off
REM ============================================================================
REM OMR Models Setup Script - Windows Batch File
REM This is a wrapper that calls the PowerShell script
REM ============================================================================

echo.
echo ========================================================
echo        OMR Models Setup Script
echo ========================================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not available on this system.
    pause
    exit /b 1
)

REM Run the PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -File "%~dp0setup_all_omr_models.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Setup encountered errors. Please check the output above.
    pause
    exit /b 1
)

echo.
echo Setup completed successfully!
pause
