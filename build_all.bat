@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Building Flutter app for all platforms
echo ========================================

echo.
echo [1/6] Cleaning project...
call flutter clean
if !errorlevel! neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/6] Getting dependencies...
call flutter pub get
if !errorlevel! neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [3/6] Building Android APK...
call flutter build apk --release
if !errorlevel! neq 0 (
    echo ERROR: Android APK build failed
    pause
    exit /b 1
)

echo.
echo [4/6] Building Android App Bundle...
call flutter build appbundle --release
if !errorlevel! neq 0 (
    echo ERROR: Android AAB build failed
    pause
    exit /b 1
)

echo.
echo [5/6] Building Web...
call flutter build web --release
if !errorlevel! neq 0 (
    echo ERROR: Web build failed
    pause
    exit /b 1
)

echo.
echo [6/6] Building Windows...
call flutter build windows --release
if !errorlevel! neq 0 (
    echo ERROR: Windows build failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo Files location:
echo - Android APK: build\app\outputs\flutter-apk\app-release.apk
echo - Android AAB: build\app\outputs\bundle\release\app-release.aab
echo - Web: build\web\
echo - Windows: build\windows\x64\runner\Release\
echo.

pause
