@echo off
setlocal EnableDelayedExpansion

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
set "SCRIPTDIR=%~dp0"
set "BACKUPFILE=%SCRIPTDIR%CurrentVersion_ORIGINAL_BACKUP.reg"

if not exist "%BACKUPFILE%" (
    echo No backup file found at:
    echo   %BACKUPFILE%
    echo Nothing to revert to - run apply_and_backup.bat first
    echo on this PC to have captured one.
    pause
    exit /b 1
)

echo Restoring from: %BACKUPFILE%
reg import "%BACKUPFILE%"

if errorlevel 1 (
    echo.
    echo Import reported an error - see message above.
    pause
    exit /b 1
)

echo.
echo Import command completed. Verifying actual values now:
reg query "%KEY%" /v CurrentBuild
reg query "%KEY%" /v CurrentBuildNumber
reg query "%KEY%" /v DisplayVersion
reg query "%KEY%" /v EditionID
echo.
echo Compare the above against the contents of:
echo   %BACKUPFILE%
echo to confirm the revert actually took effect.
pause
