@echo off
rem Sets up the Visual Studio 2022 x64 tools (cl, MSBuild, devenv). gvim.bat,
rem build.bat and test.bat call it. For a compiler prompt in the solution
rem folder: cmd.exe /k misc\shell.bat
rem The first Visual Studio 2022 edition found in its default folder is used.
rem If Visual Studio is installed elsewhere, put the full path of its
rem VC\Auxiliary\Build\vcvarsall.bat after vcvars= below.

if /i "%VSCMD_ARG_TGT_ARCH%"=="x64" if "%VisualStudioVersion%"=="17.0" exit /b 0

set "vcvars="
for %%E in (Community Professional Enterprise BuildTools) do (
    if not defined vcvars if exist "%ProgramFiles%\Microsoft Visual Studio\2022\%%E\VC\Auxiliary\Build\vcvarsall.bat" (
        set "vcvars=%ProgramFiles%\Microsoft Visual Studio\2022\%%E\VC\Auxiliary\Build\vcvarsall.bat"
    )
)
if not defined vcvars (
    >&2 echo Visual Studio 2022 C++ tools were not found. Install the "Desktop development with C++" workload.
    exit /b 1
)
if exist "%vcvars%" goto call_vcvars
>&2 echo vcvarsall.bat was not found at "%vcvars%".
exit /b 1

:call_vcvars
rem vcvarsall.bat runs vswhere.exe from PATH and prints "'vswhere.exe' is not
rem recognized" when the Visual Studio Installer folder is not in PATH.
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" set "PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer;%PATH%"
call "%vcvars%" x64 >nul
if errorlevel 1 exit /b %errorlevel%
exit /b 0
