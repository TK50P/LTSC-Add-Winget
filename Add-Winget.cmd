@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===============================
:: Admin check
:: ===============================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Run this script as Administrator.
    pause
    exit /b 1
)

:: ===============================
:: Architecture detection
:: ===============================
set ARCH=
set PROC=%PROCESSOR_ARCHITECTURE%

if /I "%PROC%"=="AMD64" set ARCH=x64
if /I "%PROC%"=="x86" (
    if defined PROCESSOR_ARCHITEW6432 (
        set ARCH=x64
    ) else (
        set ARCH=x86
    )
)
if /I "%PROC%"=="ARM64" set ARCH=arm64

if not defined ARCH (
    echo [ERROR] Unsupported CPU architecture: %PROC%
    pause
    exit /b 1
)

echo Detected architecture: %ARCH%
echo.

:: ===============================
:: OS version check (silent pass)
:: ===============================

for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 16299 goto :version

:: ===============================
:: Base directory
:: ===============================
set BASEDIR=%~dp0

:: ===============================
:: Install VC++ Runtime (UWP)
:: ===============================
echo Installing Microsoft.VCLibs...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-AppxPackage -Path '%BASEDIR%Microsoft.VCLibs.140.00_14.0.33519.0_%ARCH%__8wekyb3d8bbwe.Appx'"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-AppxPackage -Path '%BASEDIR%Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_%ARCH%__8wekyb3d8bbwe.Appx'"

:: ===============================
:: Install Windows App Runtime
:: ===============================
echo Installing Windows App Runtime...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-AppxPackage -Path '%BASEDIR%Microsoft.WindowsAppRuntime.1.8_%ARCH%.msix'"

:: ===============================
:: Install App Installer (winget)
:: ===============================
echo Installing App Installer (winget)...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-AppxPackage -Path '%BASEDIR%Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'"

:: ===============================
:: Done
:: ===============================
echo.
echo Installation complete.
echo You may need to reboot to function winget properly.
pause

:version
    echo [ERROR] Unsupported Windows version.
    echo Required: Windows 10 Version 1709 (Build %MIN_BUILD%) or later.
    echo Editing Script might work but not guaranteed to work.
