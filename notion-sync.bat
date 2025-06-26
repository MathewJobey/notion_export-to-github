@echo off
setlocal enabledelayedexpansion

:: 1.1 Point to your Downloads directory
set "DOWNLOADS=%USERPROFILE%\Downloads"

:: 1.2 Find the newest .zip with “Export” in its name
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

:: 2. Create temp folder in Downloads
set "TEMP_DIR=%DOWNLOADS%\notion-temp"
if exist "%TEMP_DIR%" (
    :: If temp folder exists, delete it
    echo.
    echo [i] Deleting existing temp folder...
    rmdir /s /q "%TEMP_DIR%"
)
mkdir "%TEMP_DIR%"
echo [OK] Created temp folder: %TEMP_DIR%

:: 3. Unzip the latest export zip into temp folder
echo.
echo [i] Extracting "!LATEST_ZIP!" to temp folder...
powershell -nologo -noprofile -command "Expand-Archive -LiteralPath '%DOWNLOADS%\!LATEST_ZIP!' -DestinationPath '%TEMP_DIR%'"
echo [OK] Extraction complete.

:: 4. Call external PowerShell script to clean files/folders
echo.
echo [i] Cleaning filenames and folders...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0cleanup-notion.ps1" "%TEMP_DIR%"

:: 5. Process HTML files (convert to UTF-8 and fix links)
echo.
echo [i] Processing HTML files (encoding and links)...
python "%~dp0process_notion_html.py" "%TEMP_DIR%"
:step5

:: Set destination GitHub folder
set "GITHUB_DIR=C:\GitHub\Programming-Concepts-Using-Java" :: Ensure your repo path is correct
echo.
echo [i] Syncing cleaned files to GitHub folder...

:: Use robocopy to mirror (add/update/delete)
echo [Robocopy Sync Log - %DATE% %TIME%] > "%GITHUB_DIR%\last-robocopy.log"

robocopy "%TEMP_DIR%" "%GITHUB_DIR%" * /E /PURGE /XD ".git" /XF "README.md" "LICENSE" ".gitignore" ".gitattributes" >> "%GITHUB_DIR%\last-robocopy.log"
 ::make sure to exclude any files you don't want to sync.
echo [OK] Sync complete. Robocopy log saved to last-robocopy.log


