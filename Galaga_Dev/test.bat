@echo off
setlocal

rem Builds and runs the rule tests: tests\game_tests.c with Space_Galaga\game.c.
rem   test.bat            from cmd or PowerShell in this folder
rem   F7 in gvim          the output goes to the quickfix list
rem The test program is bin\tests\game_tests.exe. It opens no window.

call "%~dp0misc\shell.bat"
if errorlevel 1 exit /b %errorlevel%
pushd "%~dp0" || exit /b 1
if not exist obj\tests\ mkdir obj\tests
if not exist bin\tests\ mkdir bin\tests

rem A test program stopped in the debugger, or showing an error dialog, locks
rem its exe, and the link would fail with LNK1168.
if not exist bin\tests\game_tests.exe goto compile
2>nul (>>bin\tests\game_tests.exe call ) && goto compile
>&2 echo game_tests.exe is still running. Close its dialog or debugger and run the tests again.
popd
exit /b 1

:compile
rem The flags of the test command in README.md, plus -FC (full paths in the
rem messages), -diagnostics:column (the column too, as Visual Studio shows it),
rem and -Z7 with /DEBUG (debug information for :DebugTests in gvim).
cl /nologo /TC /std:c17 /utf-8 /W4 /WX /MTd /Od /RTC1 /FC /diagnostics:column /Z7 /Foobj\tests\ /Febin\tests\game_tests.exe tests\game_tests.c Space_Galaga\game.c /link /DEBUG /INCREMENTAL:NO /SUBSYSTEM:CONSOLE user32.lib gdi32.lib
set "status=%errorlevel%"
if not "%status%"=="0" goto done

echo Running bin\tests\game_tests.exe
bin\tests\game_tests.exe
set "status=%errorlevel%"
echo ---- game_tests.exe exited with code %status% ----

:done
popd
exit /b %status%
