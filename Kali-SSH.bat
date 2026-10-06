@echo off
title KALI-SSH ^| Owner: ENC
chcp 65001 > nul
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0kali_connect.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Execution finished with errors.
    pause
)
