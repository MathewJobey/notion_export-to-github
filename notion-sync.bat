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

echo No Export zip found in %DOWNLOADS%
goto :eof

:found
echo [OK] Latest export zip is: "!LATEST_ZIP!"

