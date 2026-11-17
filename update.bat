@echo off
cd /d "%~dp0Frontend\food_files_app" || exit /b 1

echo === 1. Checking and upgrading Flutter SDK ===
call flutter upgrade || exit /b 1

echo === 2. Checking outdated packages ===
call flutter pub outdated

echo === 3. Upgrading all packages to latest major versions ===
call flutter pub upgrade --major-versions || exit /b 1

echo === 4. Applying automated Dart fixes ===
call dart fix --apply || exit /b 1

echo === 5. Checking toolchain health ===
call flutter doctor || exit /b 1

echo === 6. Running static analysis ===
call flutter analyze || exit /b 1