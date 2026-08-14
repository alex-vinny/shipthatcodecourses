@echo off
rem Windows shim so `scripts\stc.cmd ...` works from PowerShell / cmd.
rem It just hands off to Git Bash; the real script is scripts/stc.
setlocal

set "STC_DIR=%~dp0"
set "STC_DIR=%STC_DIR:\=/%"

set "STC_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%STC_BASH%" set "STC_BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not exist "%STC_BASH%" set "STC_BASH=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
if not exist "%STC_BASH%" (
  echo [stc] Could not find Git Bash ^(bash.exe^).
  echo [stc] Install Git for Windows, or run scripts/stc from WSL or the devcontainer.
  exit /b 1
)

rem cwd is deliberately left alone so relative paths in arguments still resolve.
"%STC_BASH%" "%STC_DIR%stc" %*
exit /b %ERRORLEVEL%
