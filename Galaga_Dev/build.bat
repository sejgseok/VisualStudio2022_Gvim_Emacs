@echo off
setlocal

rem Builds Space_Galaga.sln with MSBuild, the way Visual Studio builds it, so
rem gvim and Visual Studio share the same bin\ and obj\ folders.
rem   build.bat                  Debug x64, or the configuration gvim passes
rem   build.bat Release          Release x64
rem   build.bat Debug x86        32-bit; the files go to bin\Win32 and obj\Win32
rem   Alt+m in gvim              the configuration shown in gvim's status line
rem The game is bin\<x64 or Win32>\<Debug or Release>\Space_Galaga.exe.

rem The names start with game_ because vcvarsall.bat (misc\shell.bat) sets
rem Platform=x64, and cmd variable names ignore case.
set "game_config=%GALAGA_CONFIG%"
set "game_platform=%GALAGA_PLATFORM%"
if not "%~1"=="" set "game_config=%~1"
if not "%~2"=="" set "game_platform=%~2"
if not defined game_config set "game_config=Debug"
if not defined game_platform set "game_platform=x64"

if /i "%game_config%"=="Debug" (
    set "game_config=Debug"
) else if /i "%game_config%"=="Release" (
    set "game_config=Release"
) else (
    >&2 echo Unknown configuration "%game_config%". Use Debug or Release.
    exit /b 1
)
rem The solution calls the 32-bit platform x86. The project, and its bin and
rem obj folders, call it Win32.
if /i "%game_platform%"=="x64" (
    set "game_platform=x64"
    set "game_folder=x64"
) else if /i "%game_platform%"=="x86" (
    set "game_platform=x86"
    set "game_folder=Win32"
) else if /i "%game_platform%"=="Win32" (
    set "game_platform=x86"
    set "game_folder=Win32"
) else (
    >&2 echo Unknown platform "%game_platform%". Use x64 or x86.
    exit /b 1
)

call "%~dp0misc\shell.bat"
if errorlevel 1 exit /b %errorlevel%

rem A running game, or one in the Visual Studio debugger, locks its exe, and
rem the link would fail with LNK1104.
set "exe=%~dp0bin\%game_folder%\%game_config%\Space_Galaga.exe"
if not exist "%exe%" goto build
2>nul (>>"%exe%" call ) && goto build
>&2 echo Space_Galaga.exe ^(%game_config% %game_platform%^) is running. Close it ^(Shift+F5 in gvim, or stop debugging in Visual Studio^) and build again.
exit /b 1

:build
echo Building Space_Galaga %game_config% %game_platform%
rem -v:minimal lists the compiled files and the errors. NoSummary keeps the
rem errors from being listed a second time at the end, and ShowProjectFile=false
rem drops the project path MSBuild adds to each of them. -nodeReuse:false: no
rem MSBuild processes stay behind after the build.
msbuild "%~dp0Space_Galaga.sln" -nologo -m -nodeReuse:false -v:minimal "-clp:NoSummary;ShowProjectFile=false" "-p:Configuration=%game_config%" "-p:Platform=%game_platform%"
set "status=%errorlevel%"
if "%status%"=="0" echo Built bin\%game_folder%\%game_config%\Space_Galaga.exe
exit /b %status%
