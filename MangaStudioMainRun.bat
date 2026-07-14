@echo off
REM =================================================================
REM ==                                                             ==
REM ==              MANGA TRANSLATION STUDIO - LAUNCHER              ==
REM ==                                                             ==
REM =================================================================

REM Set the working directory to this script's location.
cd /d "%~dp0"

REM --- FIX: detect the Python interpreter to use. ---
REM Prefer the local venv; fall back to the system Python if venv is missing.
set "PY_EXE=.\venv\Scripts\python.exe"
set "PYW_EXE=.\venv\Scripts\pythonw.exe"

if exist "%PY_EXE%" goto MENU

echo [WARNING] Local 'venv' folder not found.
echo [WARNING] Falling back to the system Python. Make sure PySide6 and all
echo [WARNING] manga-image-translator requirements are installed there, e.g.:
echo.
echo     python -m venv venv
echo     venv\Scripts\pip install -r requirements.txt
echo     venv\Scripts\pip install PySide6
echo.
set "PY_EXE=python"
set "PYW_EXE=pythonw"

where python >nul 2>nul
if errorlevel 1 (
    echo [ERROR] No Python found on PATH either. Please install Python first.
    pause
    exit /b 1
)

:MENU
cls
echo.
echo  =========================================
echo       MANGA TRANSLATION STUDIO LAUNCHER
echo  =========================================
echo.
echo  Please choose a launch mode:
echo.
echo    [1] Normal Mode (No Console Window)
echo.
echo    [2] Debug Mode  (With Console Window)
echo.
echo    [Q] Quit
echo.
echo  =========================================
echo.

CHOICE /C 12Q /M "Enter your choice: "

IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO DEBUG_MODE
IF ERRORLEVEL 1 GOTO NORMAL_MODE

:NORMAL_MODE
echo [INFO] Launching in Normal (Silent) Mode...
start "" "%PYW_EXE%" MangaStudioMain.py
GOTO END

:DEBUG_MODE
echo [INFO] Launching in Debug (Console) Mode...
echo -----------------------------------------------------------------
"%PY_EXE%" MangaStudioMain.py
echo -----------------------------------------------------------------
echo [DEBUG] Script has finished or was stopped.
pause
GOTO END

:END
exit /b
