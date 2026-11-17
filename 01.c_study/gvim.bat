@echo off
setlocal

rem Opens the C/C++ study folder in gvim. The editing settings are the Handmade
rem Hero ones (gvim_handmade.vim in this folder, or else in the parent folder);
rem gvim_c_study.vim adds building and running single C and C++ files.
rem   gvim.bat                  the study folder (file list)
rem   gvim.bat c\01_hello.c     a file (an existing or a new one)

rem The newest Vim 9.x under Program Files, e.g. C:\Program Files\Vim\vim92.
rem If gvim is installed elsewhere, put its full path after gvim_gui= below.
set "gvim_gui="
if not defined gvim_gui for /d %%V in ("%ProgramFiles(x86)%\Vim\vim9*" "%ProgramFiles%\Vim\vim9*") do (
    if exist "%%~V\gvim.exe" set "gvim_gui=%%~V\gvim.exe"
)
if not defined gvim_gui (
    >&2 echo gvim was not found in "%ProgramFiles%\Vim\vim9*". Install Vim 9 ^(gvim^).
    exit /b 1
)
if exist "%gvim_gui%" goto gvim_found
>&2 echo gvim was not found at "%gvim_gui%".
exit /b 1
:gvim_found
if not exist "%~dp0gvim_handmade.vim" if not exist "%~dp0..\gvim_handmade.vim" (
    >&2 echo gvim_handmade.vim was not found in "%~dp0" or its parent folder.
    exit /b 1
)

rem A relative file name is taken from the current folder, then from this folder.
set "file=."
if not "%~1"=="" set "file=%~f1"
if not "%~1"=="" if not exist "%~f1" if exist "%~dp0%~1" set "file=%~dp0%~1"

call "%~dp0shell.bat"
if errorlevel 1 exit /b %errorlevel%

for %%P in ("%~dp0.") do set "HH_PROJECT=%%~fP"
pushd "%~dp0" || exit /b 1
start "" "%gvim_gui%" -N -u "%~dp0gvim_c_study.vim" -U NONE "%file%"
set "launch_status=%errorlevel%"
popd
exit /b %launch_status%
