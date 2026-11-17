@echo off
setlocal

rem Runs a study program, prints its exit code and waits for a key, so the
rem output stays on screen. gvim's F5 starts it in a new console window, in
rem the source file's folder.
rem   run.bat c\build\01_hello.exe [arguments]

if "%~1"=="" (
    >&2 echo Usage: run.bat program.exe [arguments]
    exit /b 1
)
if not exist "%~1" (
    >&2 echo Not found: "%~1". Build it first ^(Alt+m in gvim, or build.bat^).
    exit /b 1
)

title %~nx1
"%~f1" %2 %3 %4 %5 %6 %7 %8 %9
set "status=%errorlevel%"
echo.
echo ---- %~nx1 exited with code %status% ----
pause
rem Always 0: Windows Terminal keeps a window open after a nonzero exit code,
rem and the program's code was already printed above.
exit /b 0
