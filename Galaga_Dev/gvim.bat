@echo off
setlocal

rem Opens Space Galaga in gvim with the user's gvim settings, gvim_handmade.vim
rem (the Handmade Hero keys, font and dark theme), plus misc\gvim_galaga.vim,
rem which builds, runs, tests and debugs this solution.
rem   gvim.bat                       Space_Galaga\main.c
rem   gvim.bat Space_Galaga\game.c   a file (an existing or a new one)

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

rem gvim_handmade.vim: a copy in this folder is used first, then the one in the
rem Handmade Hero work folder (so changes there apply here too), then the one in
rem the C/C++ study folder. To use another file, put its full path after hh_vim=.
set "hh_vim="
if not defined hh_vim for %%F in ("%~dp0gvim_handmade.vim" "E:\Work\Dev\02.handmade_dev\01.Dev_work\gvim_handmade.vim" "E:\Work\Dev\01.c_study\gvim_handmade.vim") do (
    if not defined hh_vim if exist "%%~F" set "hh_vim=%%~fF"
)
if not defined hh_vim (
    >&2 echo gvim_handmade.vim was not found. Put its full path after hh_vim= in gvim.bat.
    exit /b 1
)
if exist "%hh_vim%" goto hh_vim_found
>&2 echo gvim_handmade.vim was not found at "%hh_vim%".
exit /b 1
:hh_vim_found
set "GALAGA_HH_VIM=%hh_vim%"

rem A relative file name is taken from the current folder, then from this folder.
set "file=%~dp0Space_Galaga\main.c"
if not "%~1"=="" set "file=%~f1"
if not "%~1"=="" if not exist "%~f1" if exist "%~dp0%~1" set "file=%~dp0%~1"

call "%~dp0misc\shell.bat"
if errorlevel 1 exit /b %errorlevel%

for %%P in ("%~dp0.") do set "HH_PROJECT=%%~fP"
pushd "%~dp0" || exit /b 1
start "" "%gvim_gui%" -N -u "%~dp0misc\gvim_galaga.vim" -U NONE "%file%"
set "launch_status=%errorlevel%"
popd
exit /b %launch_status%
