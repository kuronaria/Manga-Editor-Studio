@echo off
REM ================================================================
REM  Git line-ending cleanup for manga-image-translator
REM  Jalankan dari root project (double-click atau lewat terminal).
REM  Skrip berhenti SEBELUM commit supaya kamu bisa review dulu.
REM ================================================================

cd /d "%~dp0"

echo [1/5] Menghapus .git\index.lock yang nyangkut (jika ada)...
if exist ".git\index.lock" (
    del ".git\index.lock"
    echo       lock dihapus.
) else (
    echo       tidak ada lock.
)

echo [2/5] Set penanganan line-ending (attributes yang urus)...
git config core.autocrlf false

echo [3/5] Renormalisasi semua file tracked ke LF di repo...
git add --renormalize .

echo [4/5] Stage file housekeeping (.gitattributes / .gitignore)...
git add .gitattributes .gitignore

echo [5/5] Ini yang BENAR-BENAR akan di-commit:
echo ----------------------------------------------------------------
git diff --cached --stat
echo ----------------------------------------------------------------
echo.
echo Cek daftar di atas. Seharusnya ~9 file nyata + .gitattributes/.gitignore,
echo BUKAN ratusan file. Kalau sudah benar, commit dengan:
echo.
echo     git commit -m "chore: normalize line endings + housekeeping"
echo.
pause
