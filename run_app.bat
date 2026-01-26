@echo off
echo ===========================================
echo Setting up Manakrishi App Infrastructure
echo ===========================================

REM Check if flutter is available
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: 'flutter' command not found.
    echo Please make sure Flutter is installed and added to your PATH.
    pause
    exit /b
)

echo.
echo 1. Generating Android/iOS folders...
call flutter create . --org com.manakrishi --project-name manakrishi_app

echo.
echo 2. Installing dependencies...
call flutter pub get

echo.
echo 3. Generating Localization Files...
call flutter gen-l10n

echo.
echo 4. Launching App...
echo Note: Ensure an emulator is running or a device is connected.
call flutter run

pause
