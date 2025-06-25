@echo off
setlocal enabledelayedexpansion

:: 1. Point to your Downloads directory
set "DOWNLOADS=%USERPROFILE%\Downloads"

:: 2. Find the newest .zip with “Export” in its name
for /f "delims=" %%F in (
  'dir "%DOWNLOADS%\*Export*.zip" /b /a-d /o-d'
) do (
  set "LATEST_ZIP=%%F"
  goto :found
)

echo [X] No Export zip found in %DOWNLOADS%
goto :eof

:found
echo [OK] Latest export zip is: "!LATEST_ZIP!"

:: 3. Create temp folder in Downloads
set "TEMP_DIR=%DOWNLOADS%\notion-temp"
if exist "%TEMP_DIR%" (
    :: If temp folder exists, delete it
    echo.
    echo [i] Deleting existing temp folder...
    rmdir /s /q "%TEMP_DIR%"
)
mkdir "%TEMP_DIR%"
echo [OK] Created temp folder: %TEMP_DIR%

:: 4. Unzip the latest export zip into temp folder
echo.
echo [i] Extracting "!LATEST_ZIP!" to temp folder...
powershell -nologo -noprofile -command "Expand-Archive -LiteralPath '%DOWNLOADS%\!LATEST_ZIP!' -DestinationPath '%TEMP_DIR%'"
echo [OK] Extraction complete.

:: 5. Call external PowerShell script to clean files/folders
echo.
echo [i] Cleaning filenames and folders...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0cleanup-notion.ps1" "%TEMP_DIR%"

