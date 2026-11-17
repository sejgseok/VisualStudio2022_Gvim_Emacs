# Repository Guidelines

## Project Structure & Module Organization

- `Space_Galaga/main.c` manages the Win32 window, input messages, fullscreen mode, fixed-step timing, and GDI back buffer.
- `Space_Galaga/game.h` defines game state and the public `Game*` API; `game.c` implements gameplay, collisions, enemies, and drawing.
- `tests/game_tests.c` exercises gameplay without opening a window.
- `Space_Galaga.sln` and `Space_Galaga/Space_Galaga.vcxproj` configure Visual Studio builds. Generated outputs belong in ignored `bin/` and `obj/` directories.

Graphics are drawn with GDI; there is no separate asset directory or external game engine.

## Build, Test, and Development Commands

Install Visual Studio 2022 with Desktop development with C++, MSVC v143, and a Windows 10/11 SDK. Run commands from the repository root in an x64 Developer PowerShell:

```powershell
msbuild .\Space_Galaga.sln /m /p:Configuration=Release /p:Platform=x64
.\bin\x64\Release\Space_Galaga.exe
```

Use `Configuration=Debug` for debugging; `Platform=Win32` selects x86. Visual Studio also supports Ctrl+Shift+B to build and F5 to debug.

Build and run the standalone tests:

```powershell
New-Item -ItemType Directory -Force obj/tests, bin/tests
cl /nologo /TC /std:c17 /utf-8 /W4 /WX /MTd /Od /RTC1 /Foobj/tests/ /Febin/tests/game_tests.exe tests/game_tests.c Space_Galaga/game.c /link /SUBSYSTEM:CONSOLE user32.lib gdi32.lib
.\bin\tests\game_tests.exe
```

## Coding Style & Naming Conventions

Use C17, four-space indentation, opening function braces on separate lines, and same-line braces for control blocks. Follow existing PascalCase function/type names, camelCase fields, uppercase constants, and `g_` prefixes for file-level application state. Keep internal helpers `static` and public declarations in `game.h`.

Preserve UTF-8 encoding and existing Korean comments/UI text. Compile cleanly with `/W4 /WX`; no formatter or linter configuration is provided.

## Testing Guidelines

Tests use standard C `assert`, with no external framework or numeric coverage threshold. Extend `tests/game_tests.c` for rule changes, using a fixed random seed and 1/120-second updates. Preserve the ten-minute simulation checks. Manually verify rendering, resizing, fullscreen, and focus behavior when changing window or drawing code.

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout. Use concise imperative commit subjects, such as `Fix pause state after focus loss`. Keep changes focused. Pull requests should describe behavior changes, link relevant issues, and report build configurations and test results. Include screenshots for visual changes.
