@echo off
setlocal

rem Builds one C or C++ source file with Visual Studio 2022.
rem   build.bat c\01_hello.c      from cmd or PowerShell in this folder
rem   Alt+m in gvim               gvim_c_study.vim passes the file in CS_SOURCE
rem The program is written to build\<name>.exe in the source file's folder.

if not "%~1"=="" (
    set "source=%~f1"
) else (
    set "source=%CS_SOURCE%"
)
if not defined source (
    >&2 echo Usage: build.bat file.c  or  build.bat file.cpp
    exit /b 1
)
for %%F in ("%source%") do (
    set "source=%%~fF"
    set "source_dir=%%~dpF"
    set "name=%%~nF"
    set "ext=%%~xF"
)
if not exist "%source%" (
    >&2 echo Not found: "%source%"
    exit /b 1
)

rem C17 for .c files, C++20 for .cpp files.
if /i "%ext%"==".c" (
    set "LanguageFlags=-std:c17"
) else if /i "%ext%"==".cpp" (
    set "LanguageFlags=-std:c++20 -EHsc -Zc:__cplusplus"
) else (
    >&2 echo "%name%%ext%" is not a .c or .cpp file. Open the program's source file and build again.
    exit /b 1
)

call "%~dp0shell.bat"
if errorlevel 1 exit /b %errorlevel%

rem Debug build: no optimization, debug information (.pdb), the debug C runtime,
rem run-time checks (uninitialized variables, stack corruption), warning level 4.
rem Warnings are shown but do not stop the build (no -WX).
rem -source-charset:utf-8: gvim saves files as UTF-8 without a BOM. String
rem literals stay in the Windows code page (949 on Korean Windows), so Korean
rem text prints correctly in the console and scanf reads Korean input.
rem -D_CRT_SECURE_NO_WARNINGS: textbook functions such as scanf and strcpy
rem compile without warning C4996.
set CommonCompilerFlags=-nologo -FC -Z7 -Od -MTd -RTC1 -W4 -source-charset:utf-8 -D_CRT_SECURE_NO_WARNINGS
set CommonLinkerFlags=-incremental:no user32.lib gdi32.lib

set "build_dir=%source_dir%build"
if not exist "%build_dir%\" mkdir "%build_dir%"
pushd "%build_dir%" || exit /b 1

rem A running program locks its exe, and the link would fail with LNK1168.
if not exist "%name%.exe" goto compile
2>nul (>>"%name%.exe" call ) && goto compile
>&2 echo %name%.exe is running. Close it ^(Shift+F5 in gvim^) and build again.
popd
exit /b 1

:compile
cl %CommonCompilerFlags% %LanguageFlags% "%source%" -Fe"%name%.exe" /link %CommonLinkerFlags%
set "status=%errorlevel%"
popd
if "%status%"=="0" echo Built %build_dir%\%name%.exe
exit /b %status%
