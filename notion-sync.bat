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
echo [i] Processing HTML & mkdown files (encoding and links)...
python "%~dp0process_notion_html.py" "%TEMP_DIR%"

:: 6. Sync to GitHub folder
:: Change this to your GitHub folder path 👇
set "GITHUB_DIR=C:\GitHub\Programming-Concepts-Using-Java"  
echo.
echo [i] Syncing cleaned files to GitHub folder...
echo [Robocopy Sync Log - %DATE% %TIME%] > "%GITHUB_DIR%\last-robocopy.log"
robocopy "%TEMP_DIR%" "%GITHUB_DIR%" * /E /PURGE /XD ".git" /XF "README.md" "LICENSE" ".gitignore" ".gitattributes" >> "%GITHUB_DIR%\last-robocopy.log"
echo [OK] Sync complete. Robocopy log saved to last-robocopy.log

:: === Ensure .gitignore exists and ignore last-robocopy.log ===
echo.
echo [i] Ensuring .gitignore excludes last-robocopy.log...
set "GITIGNORE_FILE=%GITHUB_DIR%\.gitignore"
if not exist "%GITIGNORE_FILE%" (
    echo Creating new .gitignore...
    echo last-robocopy.log> "%GITIGNORE_FILE%"
) else (
    findstr /C:"last-robocopy.log" "%GITIGNORE_FILE%" >nul || echo last-robocopy.log>> "%GITIGNORE_FILE%"
)
echo [OK] .gitignore checked.

:: === Git add, commit and push ===
echo.
echo [i] Committing and pushing changes to Git...
cd /d "%GITHUB_DIR%"
git add .

:: Check for actual changes
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo [i] No changes to commit.
    goto :open_repo
)

:: Format datetime safely
set today=%DATE:/=-%
for /f "tokens=1-2 delims=:" %%a in ("%TIME%") do set now=%%a:%%b

git commit -m "Auto-sync from Notion (%today% %now%)"
git push origin main
echo [OK] Git push complete.

:open_repo
:: === Open GitHub repo in browser ===
echo.
echo Opening GitHub repository in browser...
for /f "delims=" %%r in ('git config --get remote.origin.url') do set "REMOTE_URL=%%r"

:: Convert SSH format to HTTPS if needed
echo %REMOTE_URL% | find "git@github.com:" >nul
if %errorlevel% equ 0 (
    set "REMOTE_URL=https://github.com/%REMOTE_URL:git@github.com:=%"
    set "REMOTE_URL=%REMOTE_URL:.git=%"
) else (
    set "REMOTE_URL=%REMOTE_URL:.git=%"
)

start "" "%REMOTE_URL%"

:: 8. Cleanup exported ZIP and temp folder
echo.
echo [i] Cleaning up temp and ZIP files...

:: Delete the original export ZIP
del "%DOWNLOADS%\!LATEST_ZIP!" >nul 2>&1
if exist "%DOWNLOADS%\!LATEST_ZIP!" (
    echo [X] Failed to delete export zip: !LATEST_ZIP!
) else (
    echo [OK] Deleted export zip: !LATEST_ZIP!
)

:: Delete the temp folder
rmdir /s /q "%TEMP_DIR%"
if exist "%TEMP_DIR%" (
    echo [X] Failed to delete temp folder: %TEMP_DIR%
) else (
    echo [OK] Deleted temp folder: %TEMP_DIR%
)

exit /b



