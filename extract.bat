@echo off
setlocal enabledelayedexpansion

:: Set the path to your extraction tool (e.g., 7-Zip or WinRAR)
set "EXTRACTOR=C:\Program Files\7-Zip\7z.exe"

:: Set the root directory to start searching for ZIP files
set "ROOT_DIR=C:\path\to\your\root_directory"

:: Change to the root directory
cd /d "%ROOT_DIR%"

:: Recursively find and extract ZIP files
for /r %%F in (*.zip) do (
    echo Extracting %%F
    "%EXTRACTOR%" x "%%F" -o"%%~dpF" -y
)

echo Extraction complete.
pause
