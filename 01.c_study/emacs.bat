@echo off
setlocal

rem Opens the C/C++ study folder in GNU Emacs. The editing settings are the
rem Handmade Hero ones (handmade.emacs, a copy of Casey's .emacs from the day
rem folders); emacs_c_study.el adds building, running and debugging single C
rem and C++ files.
rem   emacs.bat                  the study folder
rem   emacs.bat c\01_hello.c     a file (an existing or a new one)

rem The newest GNU Emacs under Program Files, e.g. C:\Program Files\Emacs\emacs-31.1.
rem If Emacs is installed elsewhere, put the full path of runemacs.exe after emacs_gui= below.
set "emacs_gui="
if not defined emacs_gui for /d %%V in ("%ProgramFiles%\Emacs\emacs-*") do (
    if exist "%%~V\bin\runemacs.exe" set "emacs_gui=%%~V\bin\runemacs.exe"
)
if not defined emacs_gui (
    >&2 echo GNU Emacs was not found in "%ProgramFiles%\Emacs". Install GNU Emacs.
    exit /b 1
)
if exist "%emacs_gui%" goto emacs_found
>&2 echo GNU Emacs was not found at "%emacs_gui%".
exit /b 1
:emacs_found
if not exist "%~dp0emacs_c_study.el" (
    >&2 echo emacs_c_study.el was not found in "%~dp0".
    exit /b 1
)
if not exist "%~dp0handmade.emacs" (
    >&2 echo handmade.emacs was not found in "%~dp0".
    exit /b 1
)

rem A relative file name is taken from the current folder, then from this folder.
set "file="
if not "%~1"=="" set "file=%~f1"
if not "%~1"=="" if not exist "%~f1" if exist "%~dp0%~1" set "file=%~dp0%~1"

call "%~dp0shell.bat"
if errorlevel 1 exit /b %errorlevel%

pushd "%~dp0" || exit /b 1
if defined file (
    start "" "%emacs_gui%" -q -l "%~dp0emacs_c_study.el" "%file%"
) else (
    start "" "%emacs_gui%" -q -l "%~dp0emacs_c_study.el"
)
set "launch_status=%errorlevel%"
popd
exit /b %launch_status%
