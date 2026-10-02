@echo off
rem Entry point for PowerShell / cmd. Codex on Windows runs commands in PowerShell, so it calls gsheet (bash) through this shim.
rem CHERE_INVOKING: keep the current directory. A login shell cds to HOME otherwise, which breaks relative @file paths.
rem -l: Git Bash sources ~/.bashrc as a login shell, so mise shims are on PATH.
rem Full path to bash.exe: plain "bash" resolves to the WSL launcher in PowerShell.
set CHERE_INVOKING=1
"%ProgramFiles%\Git\bin\bash.exe" -l "%~dp0gsheet" %*
