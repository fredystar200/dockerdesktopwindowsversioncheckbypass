@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: Generic backup + apply for:
:: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion
:: Values touched: CurrentBuild, CurrentBuildNumber,
::                 DisplayVersion, EditionID
::
:: Works on any PC: reads whatever is CURRENTLY on the machine
:: and backs that up before changing anything.
::
:: Safety rule: the backup file has a FIXED name and is only ever
:: written ONCE. If it already exists, this script will NOT touch
:: it again - so re-running this script (e.g. by accident, after
:: values are already changed) can never overwrite your real
:: original values with already-modified ones.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
set "SCRIPTDIR=%~dp0"
set "BACKUPFILE=%SCRIPTDIR%CurrentVersion_ORIGINAL_BACKUP.reg"
set "TMPFILE=%SCRIPTDIR%CurrentVersion_ORIGINAL_BACKUP.tmp"

if exist "%BACKUPFILE%" (
    echo ==============================================
    echo  Backup already exists - skipping backup step
    echo ==============================================
    echo Found: %BACKUPFILE%
    echo This machine already has an original backup captured.
    echo Delete that file yourself first if you deliberately want
    echo to recapture the current values as the "original".
    echo.
    goto :Apply
)

echo ==============================================
echo  Capturing current values as the original backup
echo ==============================================
echo Target key : %KEY%
echo Backup file: %BACKUPFILE%
echo.

> "%TMPFILE%" echo Windows Registry Editor Version 5.00
>> "%TMPFILE%" echo.
>> "%TMPFILE%" echo [%KEY%]

set "MISSING="

for %%V in (CurrentBuild CurrentBuildNumber DisplayVersion EditionID) do (
    call :BackupValue "%%V"
)

if defined MISSING (
    echo.
    echo WARNING: One or more values could not be auto-captured.
    echo          Open the backup file and check/fix those lines manually.
)

:: Convert the draft into proper UTF-16LE, matching what reg.exe/regedit
:: actually expect .reg files to be.
powershell -NoProfile -Command ^
  "Get-Content -LiteralPath '%TMPFILE%' | Set-Content -LiteralPath '%BACKUPFILE%' -Encoding Unicode"

if not exist "%BACKUPFILE%" (
    echo.
    echo ERROR: Failed to write the backup file. Aborting - not applying
    echo new values without a confirmed backup.
    pause
    exit /b 1
)

del "%TMPFILE%" >nul 2>&1
echo.
echo Backup captured successfully: %BACKUPFILE%
echo.

:Apply
echo ==============================================
echo  Applying new values
echo ==============================================
reg add "%KEY%" /v CurrentBuild       /t REG_SZ /d "28000"       /f
if errorlevel 1 goto :PermError
reg add "%KEY%" /v CurrentBuildNumber /t REG_SZ /d "28000"       /f
if errorlevel 1 goto :PermError
reg add "%KEY%" /v DisplayVersion     /t REG_SZ /d "22H2"        /f
if errorlevel 1 goto :PermError
reg add "%KEY%" /v EditionID          /t REG_SZ /d "Professional" /f
if errorlevel 1 goto :PermError

echo.
echo Done. Current values now:
reg query "%KEY%" /v CurrentBuild
reg query "%KEY%" /v CurrentBuildNumber
reg query "%KEY%" /v DisplayVersion
reg query "%KEY%" /v EditionID
echo.
echo To revert on this PC, run revert.bat (it uses %BACKUPFILE%).
echo.
pause
exit /b 0

:PermError
echo.
echo ERROR: reg add failed - likely a TrustedInstaller ownership issue
echo on this machine. Your backup (if captured) is safe at:
echo   %BACKUPFILE%
pause
exit /b 1

:: --------------------------------------------------------------
:BackupValue
set "VALNAME=%~1"
set "VTYPE="
set "VDATA="

for /f "skip=1 tokens=1,2,*" %%A in ('reg query "%KEY%" /v "%VALNAME%" 2^>nul') do (
    if not defined VTYPE if /i "%%A"=="%VALNAME%" (
        set "VTYPE=%%B"
        set "VDATA=%%C"
    )
)

if not defined VDATA (
    echo   [!] %VALNAME% not found or unreadable - skipping.
    set "MISSING=1"
    exit /b
)

if /i "!VTYPE!"=="REG_SZ" (
    >> "%TMPFILE%" echo "%VALNAME%"="!VDATA!"
    echo   [OK] %VALNAME% = "!VDATA!" ^(REG_SZ^)
) else if /i "!VTYPE!"=="REG_DWORD" (
    >> "%TMPFILE%" echo "%VALNAME%"=dword:!VDATA!
    echo   [OK] %VALNAME% = !VDATA! ^(REG_DWORD^)
) else (
    echo   [!] %VALNAME% has type "!VTYPE!" - not auto-captured.
    set "MISSING=1"
)
exit /b
