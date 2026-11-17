# Emacs C/C++ 가이드

- **작성일:** 2026-11-13 (2026-11-14: 글꼴과 색 `emacs_theme.el`, C/C++ 편집 편의 기능 `emacs_edit.el` 추가)
- **대상 폴더:** 이 문서가 있는 C/C++ 공부 폴더. 이 PC에는 `E:\Work\Dev\01.c_study`(독립 폴더)와 `E:\Work\Dev\02.handmade_dev\01.Dev_work\01.c_study`(Handmade Hero 작업 폴더 안) 두 곳에 같은 파일이 있다. 아래 예의 `E:\Work\Dev\01.c_study`는 쓰는 폴더의 경로로 바꿔 읽는다.
- **목적:** Handmade Hero 날짜 폴더와 같은 Emacs 설정(Casey의 `.emacs`)으로 C와 C++ 코드를 쓰고, 빌드하고, 실행해서 시험하고, Visual Studio 2022로 디버깅한다.
- 같은 폴더의 gvim 환경(`gvim.bat`, `C_C++_빌드가이드.txt`)과 `build.bat`, `run.bat`, `shell.bat`를 함께 쓴다. gvim과 Emacs 중 편한 쪽을 쓰면 된다.
- Emacs 키 전체는 `E:\Work\Dev\02.handmade_dev\01.Dev_work\Emacs_키보드가이드.md`에 있다. 이 문서는 공부 폴더에서 쓰는 키와 순서를 다룬다.

## 목차

1. [구성](#1-구성)
2. [준비](#2-준비)
3. [시작](#3-시작)
4. [따라 하기: 새 프로그램 만들고 실행하기](#4-따라-하기-새-프로그램-만들고-실행하기)
5. [키 요약](#5-키-요약)
6. [현재 프로그램](#6-현재-프로그램)
7. [빌드](#7-빌드)
8. [실행과 시험](#8-실행과-시험)
9. [Visual Studio 2022로 디버깅](#9-visual-studio-2022로-디버깅)
10. [한글 처리](#10-한글-처리)
11. [자주 발생하는 문제](#11-자주-발생하는-문제)
12. [설정을 바꾸거나 다른 PC로 옮길 때](#12-설정을-바꾸거나-다른-pc로-옮길-때)
13. [확인 근거](#13-확인-근거)

---

## 1. 구성

| 파일 | 역할 |
|---|---|
| `emacs.bat` | **Emacs 시작.** `shell.bat`로 Visual Studio 2022 빌드 환경을 준비한 뒤 이 폴더에서 Emacs를 연다. 새로 만든 파일 |
| `emacs_c_study.el` | **공부 폴더용 Emacs 설정.** `handmade.emacs`를 읽은 뒤 빌드, 실행, 디버그 키와 새 파일 틀, UTF-8 저장을 더한다. 새로 만든 파일 |
| `handmade.emacs` | Handmade Hero 날짜 폴더의 `misc\.emacs`(Casey의 설정, day_062 이후와 같은 파일)를 그대로 복사한 것. 키, 색, 동작이 Handmade Hero와 같아진다. 새로 만든 파일 |
| `emacs_theme.el` | 글꼴과 C/C++ 색을 gvim과 같게(JetBrainsMono 12, Ctrl+마우스 휠로 크기). Handmade Hero 날짜 폴더 `misc\emacs_theme.el`의 사본 (2026-11-14) |
| `emacs_edit.el` | gvim과 같은 C/C++ 편집 기능(괄호 자동 완성, `TAB`으로 빠져나가기, 코드 조각, 주석 전환, 줄 번호 등). Handmade Hero 날짜 폴더 `misc\emacs_edit.el`의 사본 (2026-11-14) |
| `build.bat` | 소스 파일 하나를 빌드한다 (gvim과 함께 씀) |
| `run.bat` | 프로그램을 실행하고 종료 코드를 보여 준 뒤 키를 기다린다 (gvim과 함께 씀) |
| `shell.bat` | Visual Studio 2022 x64 컴파일러 환경을 준비한다 (gvim과 함께 씀) |
| `Turboc.h` | 터보 C 스타일 함수(`clrscr`, `gotoxy`, `delay`, `random` 등) 헤더. 어느 폴더의 소스에서나 `#include "Turboc.h"`로 쓴다([7절](#7-빌드)) |
| `c\`, `cpp\` | 예제와 내 프로그램. 빌드한 exe는 소스 파일 옆의 `build\` 폴더에 생긴다 (`c\build\01_hello.exe`) |

읽는 순서:

```
emacs.bat
  └─ shell.bat (Visual Studio 2022 환경)
  └─ runemacs.exe -q -l emacs_c_study.el [파일]
        └─ handmade.emacs (Casey의 설정: 키, 색, 들여쓰기, 두 창)
        └─ 공부 폴더 설정: M-m 빌드, F5 실행, C-F5 빌드 후 실행, S-F5 종료, F6 디버그,
           새 .c/.cpp 파일의 main 틀, .c/.cpp/.h를 UTF-8로 저장, 모드 줄의 [현재 프로그램]
        └─ emacs_theme.el (gvim과 같은 글꼴과 색, Ctrl+마우스 휠 글꼴 크기)
        └─ emacs_edit.el (gvim과 같은 C/C++ 편집 기능, 줄 번호)
```

`-q`로 시작하므로 Windows 사용자 폴더의 개인 Emacs 설정(`.emacs`, `init.el`)은 읽지 않는다.

---

## 2. 준비

| 프로그램 | 내용 |
|---|---|
| Visual Studio 2022 | "C++를 사용한 데스크톱 개발" 워크로드를 설치한다 |
| GNU Emacs | `C:\Program Files\Emacs\emacs-31.1`처럼 기본 위치에 설치한다. `winget install --id GNU.Emacs -e`로 설치해도 된다 |

- `emacs.bat`는 `C:\Program Files\Emacs\emacs-*` 가운데 이름순 마지막 폴더의 `bin\runemacs.exe`를 쓴다. 다른 곳에 설치했으면 `emacs.bat`의 `set "emacs_gui="` 줄 `=` 뒤에 `runemacs.exe`의 전체 경로를 적는다.
- `shell.bat`는 Visual Studio 2022의 Community, Professional, Enterprise, BuildTools 중 처음 찾은 것을 쓴다.

---

## 3. 시작

명령 창이나 PowerShell에서:

```
E:\Work\Dev\01.c_study\emacs.bat                  공부 폴더를 연다
E:\Work\Dev\01.c_study\emacs.bat c\01_hello.c     파일을 바로 연다 (없는 이름이면 새 파일)
```

- 파일 이름은 현재 폴더 기준으로 먼저 찾고, 없으면 공부 폴더 기준으로 찾는다. 그래서 어느 폴더에서 실행해도 `c\01_hello.c`처럼 쓸 수 있다.
- 탐색기에서 `emacs.bat`를 두 번 눌러도 된다. 자주 쓰면 바탕 화면에 `emacs.bat`의 바로 가기를 만든다.
- 시작하면 창이 최대화되고 좌우 두 창으로 나뉜다. 아래 미니버퍼에 `C/C++ study: M-m build, F5 run, C-F5 build and run, S-F5 stop, F6 debug`가 나온다.
- 모드 줄(창 아래 회색 줄) 오른쪽에 `[no program]` 또는 `[01_hello.c]`처럼 **현재 프로그램**이 보인다([6절](#6-현재-프로그램)).

---

## 4. 따라 하기: 새 프로그램 만들고 실행하기

키 표기: `M-` = Alt, `C-` = Ctrl, `S-` = Shift, `RET` = Enter. 예: `M-f` = Alt+F.

1. `emacs.bat`로 Emacs를 연다.
2. **새 파일 만들기:** `M-f`를 누르고 `c/04_test.c`를 입력한 뒤 `C-j`를 누른다(없는 파일을 그 이름 그대로 연다).
   `M-f`에서는 폴더를 **`/`**로 구분한다. `c\04_test.c`처럼 `\`로 입력하면 엉뚱한 파일이 열릴 수 있다. `c/`까지 치면 c 폴더로 들어가고 아래에 그 폴더의 파일 목록이 보인다.
   다음 틀이 자동으로 들어가고 커서는 `main` 안의 빈 줄에 있다.
   ```c
   #include <stdio.h>

   int
   main(void)
   {
       
       return(0);
   }
   ```
   `.cpp` 파일이면 `#include <iostream>`과 `main()`으로 시작한다.
3. **코드 입력:** 예를 들어 `printf("합 = %d\n", 1 + 2);`를 입력한다. 이미 쓴 단어는 앞 몇 글자를 치고 `TAB`을 누르면 완성된다.
4. **저장:** `M-s`
5. **빌드:** `M-m`. 다른 쪽 창의 `*compilation*`에 빌드 결과가 나오고, 성공하면 마지막에 `Built ...\c\build\04_test.exe`와 `Compilation finished`가 보인다.
6. **실행:** `F5`. 새 콘솔 창이 열려 프로그램이 실행되고, 끝나면 `---- 04_test.exe exited with code 0 ----`와 `계속하려면 아무 키나 누르십시오`가 나온다. 아무 키나 누르면 창이 닫힌다.
7. **빌드하고 바로 실행:** 다음부터는 `C-F5` 한 번으로 저장 확인, 빌드, 실행까지 한다(빌드가 실패하면 실행하지 않는다).
8. **오류 연습:** `printf` 줄의 `;`를 지우고 `M-s`, `M-m`을 누른다. `*compilation*`에 `error C2143: 구문 오류: ...`처럼 한글 설명이 붙은 오류가 나온다. `F9`를 누르면 오류 위치로 이동한다. `;`가 빠진 경우에는 그다음 줄이 오류 위치로 나온다. 고친 뒤 `M-s`, `M-m`.

---

## 5. 키 요약

### 공부 폴더에서 더한 키

| 키 | 기능 |
|---|---|
| `M-m` | **현재 프로그램 빌드** (`build.bat "소스 파일"`). 저장하지 않은 파일이 있으면 저장할지 묻는다 (`y` 저장, `!` 모두 저장) |
| `F5` | **실행.** 새 콘솔 창에서, 소스 파일이 있는 폴더에서 실행한다 |
| `C-F5` | **빌드한 뒤 성공하면 실행** |
| `S-F5` | 실행 중인 현재 프로그램 강제 종료 (무한 반복에 빠졌을 때 등) |
| `F6` | **Visual Studio 2022 디버거로 열기** ([9절](#9-visual-studio-2022로-디버깅)) |

gvim(`gvim.bat`)의 공부 폴더 키(`Alt+m`, `F5`, `Ctrl+F5`, `Shift+F5`, `F6`)와 같다.

### 자주 쓰는 Casey 설정 키

Handmade Hero의 Emacs와 같다. 일반 Emacs와 다른 키가 많으니 주의한다(자세한 것은 `Emacs_키보드가이드.md` 3절).

| 키 | 기능 |
|---|---|
| `M-f` / `M-F` | 파일 열기 / 다른 쪽 창에 열기. 폴더는 `/`로 구분하고, 없는 파일은 `C-j`로 연다 |
| `M-b` | 열린 버퍼(파일)로 바꾸기 |
| `M-s` | 저장 (C/C++ 파일은 탭을 공백으로 바꿔 저장) |
| `M-w` | 다른 쪽 창으로 이동 |
| `C-x k RET` | 지금 버퍼 닫기 (`M-k`는 Emacs 31에서 오류) |
| `F9` / `M-n`, `F11` / `M-N`, `F10` | 첫 오류 / 다음 오류 / 이전 오류로 이동 |
| `C-SPC` | 선택 시작 (선택 영역은 색으로 표시되지 않는다) |
| `C-q` / `C-w` / `C-f` | 복사 / 잘라내기 / 붙여넣기 (`C-y`는 들여쓰기) |
| `M-u` | 실행 취소 |
| `TAB` | 단어 자동 완성 (들여쓰기는 `C-y` 또는 `S-TAB`). 닫는 괄호 바로 앞에서는 빠져나가기 |
| `C-s` / `C-r` | 앞 / 뒤 검색 |
| `M-o` | 확인하며 치환 |
| `M-j` | 함수 이름으로 이동 |
| `M-g` | 줄 번호로 이동 |
| `M-c` | 같은 이름의 `.c`/`.cpp` ↔ `.h` 전환 |
| 영역 선택 후 `C-c C-c` | 주석으로 바꾸기 (`C-u C-c C-c`는 해제) |
| `C-g` | 하던 명령 취소 |
| `C-x C-c` | Emacs 종료 |

### 글꼴, 색, 편집 편의 기능 (2026-11-14)

`emacs_theme.el`이 글꼴과 색을, `emacs_edit.el`이 편집 기능을 gvim과 같게 맞춘다. 자세한 것은 같은 폴더의 `Emacs_키보드가이드.md` 2절(글꼴과 색)과 11절(C/C++ 편집 편의 기능)에 있다.

| 키 | 기능 |
|---|---|
| `Ctrl` + 마우스 휠 위 / 아래 | 글꼴 크게 / 작게 |
| `(` `[` `{` `"` `'` | 닫는 문자가 함께 들어간다. 닫는 문자를 치면 그 위를 지나간다 |
| `TAB` | 닫는 괄호·따옴표 앞이면 빠져나가기, 아니면 단어 자동 완성 |
| `M-?` | 괄호 안에서 단어 자동 완성 |
| `M-e` | `if`, `for`, `while`, `switch`, `struct`, `inc` 등을 친 뒤 누르면 코드 조각 |
| `C-;` | 현재 줄 주석 전환 |
| `M-D` / `M-S-<up>`, `M-S-<down>` / `M-RET` | 줄 복제 / 줄 옮기기 / 아래에 새 줄 |
| `F7` | 커서 아래 단어를 공부 폴더 전체에서 찾기 |
| `C-c @ C-c` | 블록 접기 / 펼치기 |

---

## 6. 현재 프로그램

`M-m`, `F5`, `C-F5`, `S-F5`, `F6`가 대상으로 삼는 파일은 **마지막으로 화면에 띄운 `.c` 또는 `.cpp` 파일**이다. 모드 줄 오른쪽에 `[04_test.c]`처럼 보인다.

- `.h` 파일, 빌드 결과 창, 도움말 창으로 옮겨도 현재 프로그램은 바뀌지 않는다. 헤더를 고치다가 `M-m`을 눌러도 마지막 `.c`/`.cpp` 프로그램이 빌드된다.
- 다른 프로그램을 빌드하려면 그 `.c`/`.cpp` 파일을 한 번 띄운다(`M-b`로 바꾸기 등).
- `build.bat`는 소스 파일 하나만 빌드한다. 여러 `.c` 파일로 된 프로그램은 이 환경의 대상이 아니다. `#include`로 넣는 헤더(`.h`)는 함께 컴파일된다.

---

## 7. 빌드

`M-m`은 공부 폴더의 `build.bat`에 현재 프로그램의 전체 경로를 넘긴다. `build.bat`가 하는 일:

- `.c` 파일은 C17(`-std:c17`), `.cpp` 파일은 C++20(`-std:c++20 -EHsc`)으로 컴파일한다.
- 디버그 빌드: 최적화 없음(`-Od`), 디버그 정보(`-Z7`), 디버그용 C 런타임(`-MTd`), 실행 중 검사(`-RTC1`: 초기화하지 않은 변수, 스택 손상 등), 경고 수준 4(`-W4`). 경고가 있어도 빌드는 성공한다.
- 소스를 UTF-8로 읽는다(`-source-charset:utf-8`, [10절](#10-한글-처리)). `scanf`, `strcpy` 같은 교재 함수와 `getch`, `kbhit` 같은 옛 이름의 C4996 경고는 끈다(`-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS`).
- `build.bat`가 있는 폴더를 포함 경로로 넘긴다(`-I`). 그래서 그 폴더의 `Turboc.h`를 `c\`, `cpp\` 등 어느 폴더의 소스에서나 `#include "Turboc.h"`(또는 `<Turboc.h>`)로 쓴다. 함수 목록과 주의할 점은 `C_C++_빌드가이드.txt` 7절, 예제는 `c\04_turboc.c`와 `cpp\03_turboc.cpp`이다. `Turboc.h`는 UTF-8로 바꿔 두었으므로 Emacs에서 열어도 한글 주석이 바르게 보인다.
- 결과: 소스 파일 옆의 `build\이름.exe` (`c\04_test.c` → `c\build\04_test.exe`)

빌드 결과 창(`*compilation*`):

| 키 | 기능 |
|---|---|
| `F9` | 첫 번째 오류로 이동 |
| `M-n`, `F11` / `M-N`, `F10` | 다음 / 이전 오류로 이동 |
| `RET` (그 창에서) | 커서가 있는 오류 줄로 이동 |
| `M-x recompile` | 같은 빌드를 다시 (그 창에서는 `g`) |

- 프로그램이 실행 중이면 exe가 잠겨 있어서 빌드가 `04_test.exe is running. Close it (Shift+F5 in gvim) and build again.`으로 멈춘다. Emacs에서도 `S-F5`로 끄거나 실행 창에서 키를 눌러 닫은 뒤 다시 빌드한다.
- Emacs 없이 명령 창에서 빌드할 때: `cmd.exe /k E:\Work\Dev\01.c_study\shell.bat`로 컴파일러 창을 열고 `cd E:\Work\Dev\01.c_study`, `build.bat c\04_test.c`.

---

## 8. 실행과 시험

### F5로 실행

- 새 콘솔 창(이 PC는 Windows Terminal)에서 실행한다. 창 제목은 프로그램 이름이다.
- **실행 폴더는 소스 파일이 있는 폴더**이다. `fopen("scores.txt", "w")`처럼 상대 경로로 만든 파일은 그 폴더에 생긴다(`c\03_struct_file.c` → `c\scores.txt`). 프로그램이 읽을 파일도 소스 파일과 같은 폴더에 둔다.
- 프로그램이 끝나면 `---- 이름.exe exited with code N ----`로 **종료 코드**(`main`의 `return` 값)가 보이고 키를 기다린다.
- `scanf` 입력은 그 콘솔 창에서 한다. 한글도 입력된다(`c\02_input.c`로 시험해 볼 수 있다).
- 소스를 고치고 빌드하지 않은 채 `F5`를 누르면 `Running 04_test.exe, which is older than the source. M-m rebuilds it.`이라고 알려 준다(예전 exe가 실행된다).
- 실행 창은 Emacs를 닫아도 남아 있다.

### 프로그램 강제 종료

무한 반복이나 입력 대기로 끝나지 않으면 Emacs에서 `S-F5`를 누른다(`taskkill`로 강제 종료). 실행 창에 종료 코드가 표시되고, 아무 키나 누르면 닫힌다.

### 시험하는 방법

- **종료 코드로 확인:** 시험이 성공하면 `return(0);`, 실패하면 `return(1);`처럼 다른 값을 돌려주면 실행 창에서 바로 알 수 있다.
- **같은 입력으로 반복 시험:** 입력할 내용을 텍스트 파일(예: `c\input.txt`)에 적어 두고, 컴파일러 창(`cmd.exe /k shell.bat`)에서 `c\build\02_input.exe < c\input.txt`로 실행하면 매번 같은 입력으로 시험할 수 있다.
- **명령줄 인자:** `F5`는 인자를 넘기지 않는다. 인자가 필요하면 컴파일러 창에서 `run.bat c\build\04_test.exe 인자1 인자2`로 실행한다.
- **빌드부터 실행까지 한 번에:** 고치고 `C-F5`, 결과 확인, 다시 고치고 `C-F5`를 반복한다.

---

## 9. Visual Studio 2022로 디버깅

### 디버거 열기

1. `M-m`으로 빌드해 둔다(디버그 정보 `-Z7`, 최적화 없음 `-Od`로 빌드된다).
2. `F6`을 누르면 Visual Studio 2022가 현재 프로그램을 디버그 대상으로 열린다(`devenv /DebugExe 이름.exe`). 창 제목은 `04_test - Microsoft Visual Studio`이다. 프로그램은 아직 실행되지 않는다.

### 중단점과 단계 실행

| 작업 | Visual Studio 기본 키 | 메뉴 |
|---|---|---|
| 소스 열기 | `Ctrl+O` | 파일 > 열기 > 파일 |
| 중단점 설정/해제 | `F9` | 디버그 > 중단점 설정/해제 |
| 디버깅 시작/계속 | `F5` | 디버그 > 디버깅 시작 |
| 한 줄 실행 | `F10` | 디버그 > 프로시저 단위 실행 |
| 함수 안으로 | `F11` | 디버그 > 한 단계씩 코드 실행 |
| 함수에서 나오기 | `Shift+F11` | 디버그 > 프로시저 나가기 |
| 디버깅 중지 | `Shift+F5` | 디버그 > 디버깅 중지 |
| 지역 변수 보기 | | 디버그 > 창 > 지역 |
| 변수 지켜보기 | | 디버그 > 창 > 조사식 |
| 호출 스택 | | 디버그 > 창 > 호출 스택 |

- 소스를 열지 않고 `F11`(한 단계씩 코드 실행)로 시작하면 `main`에서 멈추면서 소스가 자동으로 열린다.
- 이 PC의 Visual Studio는 키보드 설정에서 `Ctrl+O`, `F5`, `F9`, `Ctrl+S`를 지워 두었다. 이 키가 동작하지 않으면 표의 메뉴를 쓴다. `Alt`를 누르면 메뉴로 이동할 수 있다(예: `Alt+D` 디버그 메뉴).
- 프로그램의 콘솔 창은 디버깅을 시작하면 따로 열린다.

### 고친 뒤 다시 디버깅

1. Visual Studio에서 디버깅을 멈춘다(`Shift+F5`).
2. Emacs에서 고치고 `M-s`, `M-m`. Visual Studio는 빌드를 하지 않는다. 디버깅 중에는 exe가 잠겨 빌드가 `is running`으로 멈추므로 먼저 멈춘다.
3. Visual Studio에서 다시 디버깅 시작. 같은 Visual Studio 창을 계속 써도 된다.

### 주의

- Visual Studio에서 실행할 때의 작업 폴더는 `F5`(Emacs)처럼 소스 폴더가 아닐 수 있다. 상대 경로로 파일을 여는 프로그램은 프로젝트 속성 > 디버깅 > 작업 디렉터리를 소스 폴더로 지정한다.
- Visual Studio를 닫을 때 솔루션 저장 여부를 물으면 저장하지 않아도 된다.

---

## 10. 한글 처리

- 이 Emacs는 `.c`, `.cpp`, `.h` 파일을 **UTF-8로 읽고 저장**한다(BOM 없음, 줄 끝은 원래대로 CRLF). 영문만 있던 파일에 한글을 넣어도 UTF-8로 저장된다. 모드 줄 맨 왼쪽의 `U`가 UTF-8이라는 표시이다.
- `build.bat`가 `-source-charset:utf-8`로 소스를 UTF-8로 읽고, 문자열 상수는 Windows 코드 페이지(949)로 바꾼다. 그래서 콘솔에 한글이 그대로 보이고 `scanf`로 한글을 입력받을 수 있다. `sizeof("한글")`은 5이다.
- 빌드 결과 창의 컴파일러 메시지(`구문 오류: ...`)도 한글로 보인다.
- 다른 곳에서 가져온 CP949(EUC-KR) 소스는 한글이 깨져 보인다. `C-x RET r cp949 RET`로 CP949로 다시 읽은 뒤 `C-x RET f utf-8 RET`, `M-s`로 UTF-8로 바꿔 저장한다.
- 한/영 키가 한글 상태여도 `M-`, `C-` 조합 키는 동작한다. `M-f`로 파일 이름을 입력할 때는 영문 상태로 바꾼다.

---

## 11. 자주 발생하는 문제

| 메시지 또는 증상 | 원인과 해결 |
|---|---|
| `GNU Emacs was not found in "C:\Program Files\Emacs"` | Emacs를 설치하거나 `emacs.bat`의 `emacs_gui=`에 `runemacs.exe` 경로를 적는다 |
| `Visual Studio 2022 C++ tools were not found` | Visual Studio Installer에서 "C++를 사용한 데스크톱 개발"을 설치한다 |
| `Open a .c or .cpp file first` | 아직 `.c`/`.cpp` 파일을 띄우지 않았다. 프로그램 파일을 연다 |
| `Nothing to run. Build 04_test.c first (M-m)` | 아직 빌드하지 않았다. `M-m` 또는 `C-F5` |
| `04_test.exe is running. Close it (Shift+F5 in gvim) and build again.` | 프로그램이 실행 중이거나 디버거가 잡고 있다. `S-F5`, 실행 창에서 키 누르기, 또는 Visual Studio 디버깅 중지 뒤 다시 빌드 |
| `DevEnvDir is not set. Start Emacs with emacs.bat` | Emacs를 `emacs.bat`가 아닌 방법으로 열었다. `emacs.bat`로 다시 연다 |
| 빌드 전에 `Save file ...?`를 묻는다 | 저장하지 않은 파일이 있다. `y`(저장) 또는 `!`(모두 저장) |
| 빌드 결과 창에 `C4828` 경고나 한글이 깨진 오류 | 소스가 UTF-8이 아니다. [10절](#10-한글-처리)의 방법으로 UTF-8로 바꾼다 |
| `fatal error C1083: 포함 파일을 열 수 없습니다. 'Turboc.h'` | `Turboc.h`가 `build.bat`와 같은 폴더에 없다. 공부 폴더 맨 위에 둔다 |
| C++에서 `std::max`, `std::min`이 `C2589`로 실패 | `Turboc.h`가 포함한 `windows.h`의 `min`, `max` 매크로 때문이다. `#include "Turboc.h"` 앞에 `#define NOMINMAX`를 적는다 |
| `M-k`를 누르면 `This command must be called from a menu or a tool bar` | Emacs 31에서 Casey의 `M-k`가 동작하지 않는다. `C-x k RET`로 닫는다 |
| 실행 창이 닫히지 않는다 | `run.bat`가 결과를 보여 주려고 기다리는 중이다. 아무 키나 누른다 |
| 여러 파일로 된 프로그램이 `LNK2019`로 실패 | `build.bat`는 파일 하나만 빌드한다([6절](#6-현재-프로그램)) |
| 새 파일에 `main` 틀이 들어가지 않는다 | 틀은 **없는** 파일을 새로 열 때만 들어간다. 이미 있는 파일은 그대로 연다 |

---

## 12. 설정을 바꾸거나 다른 PC로 옮길 때

- **키, 색, 편집 동작:** `handmade.emacs`, `emacs_theme.el`, `emacs_edit.el`은 Handmade Hero 날짜 폴더의 `misc\.emacs`, `misc\emacs_theme.el`, `misc\emacs_edit.el`과 같은 파일이다. 그쪽 설정을 바꿨으면 이 폴더에도 다시 복사한다. `emacs_theme.el`과 `emacs_edit.el`을 지우면 Casey의 원래 모양과 키로 돌아간다. 공부 폴더에만 해당하는 것(빌드, 실행, 새 파일 틀, UTF-8)은 `emacs_c_study.el`에서 고친다.
- **새 파일 틀:** `emacs_c_study.el`의 `cs--new-file-template` 함수 안의 문자열을 고친다.
- **컴파일 옵션:** `build.bat`의 `CommonCompilerFlags` 줄. gvim과 함께 쓰므로 양쪽에 적용된다.
- **다른 PC로 옮기기:** 독립 폴더 안의 `01.c_study_환경설정.zip`(설정 파일, 안내 문서, 예제. Emacs 파일 다섯 개와 이 문서 포함)을 새 PC에 풀거나, 폴더를 통째로 복사한다(`D:\Work\Dev\01.c_study` 등 어느 위치든 된다). 그다음 Visual Studio 2022와 GNU Emacs를 설치하고 `emacs.bat`를 실행한다. gvim 환경 전체를 옮기는 `Gvim_개발환경구축_설정파일.zip`에도 같은 파일이 들어 있다.
- **라이선스:** `handmade.emacs`는 Casey Muratori(Molly Rocket)의 Handmade Hero `.emacs` 사본이다. 본인의 개인 학습용 PC 사이에서만 옮겨 쓰고, 공개된 곳(GitHub 등)에 올리지 않는다.
- 설정을 바꾼 뒤에는 Emacs를 다시 시작해야 적용된다.

---

## 13. 확인 근거

2026-11-13에 이 PC(Windows 11, GNU Emacs 31.1, Visual Studio Community 2022 17.14)에서 공부 폴더의 임시 복사본으로 확인했다.

- `emacs.bat`: 인자 없이, 그리고 다른 폴더에서 `emacs.bat c\01_hello.c`로 실행해 Emacs가 `-q -l emacs_c_study.el`과 파일 경로로 열림. 프로젝트 안의 `01.c_study`에서도 같은 파일로 열림
- 설정을 읽을 때 오류 없음. `M-m`, `F5`, `C-F5`, `S-F5`, `F6`가 공부 폴더 명령에 연결됨(C++ 파일에서도)
- 모드 줄에 `[01_hello.c]`, `.h` 파일로 옮겨도 현재 프로그램이 유지됨
- 새 `.c`, `.cpp` 파일의 `main` 틀과 커서 위치, 새 `.h`는 빈 파일(Casey의 머리말 없음). `M-f c/04_test.c C-j`로 새 파일, `M-f c/01_h RET`로 기존 파일 열기
- 한글을 넣어 저장한 새 파일과 영문만 있던 파일이 UTF-8(BOM 없음, CRLF)로 저장됨
- `M-m` 빌드 성공(`Built ...`), 오류 빌드에서 한글 메시지 `error C2146: 구문 오류: ...`, `F9`로 오류 줄(7행) 이동
- `C-F5`로 `c\01_hello.c` 빌드 후 실행: 새 콘솔 창에 한글 출력과 `---- 01_hello.exe exited with code 0 ----`, 키를 누르자 창이 닫힘
- `F5`로 `c\02_input.c` 실행(입력 대기) 뒤 `S-F5`로 프로세스가 종료됨
- `F6`으로 Visual Studio 2022가 `01_hello - Microsoft Visual Studio` 창으로 열림
- **글꼴, 색, 편집 기능(2026-11-14):** 공부 폴더의 임시 복사본에서 확인했다.
  - `emacs.bat`로 연 Emacs에 `emacs_theme.el`, `emacs_edit.el`이 읽히고, 글꼴 JetBrainsMono NFM, 바탕 `#1E1E1E`, 줄 번호, `M-m` `F5` `C-F5` `S-F5` `F6`이 공부 폴더 명령 그대로인 것
  - `c\`, `cpp\`의 `.c`, `.cpp` 파일 7개(예제 5개 포함)를 gvim과 Emacs로 열어 글자마다 글자색을 비교: 모두 같음
  - 편집 키 73개 항목(괄호, 따옴표, `TAB`, 코드 조각, 주석, 줄 편집 등)을 키 입력을 흉내 내어 확인, 새 `.c` 파일의 `main` 틀 안에서 `printf("%d` `TAB` `, 1` `TAB` `;` `RET` `if` `M-e` … 입력, `F7`로 공부 폴더 전체 찾기, `M-m` 빌드 성공
  - `emacs.bat`로 연 Emacs 창에 글자 입력 메시지를 보내 새 `.cpp`의 `main` 안에 `foo(bar` `TAB` `;` … 가 gvim과 같은 결과가 되는 것
- **Turboc.h(2026-11-17):** 임시 복사본에서 `c\04_turboc.c`를 `M-m`으로 빌드해 경고 없이 `finished`, `Turboc.h`가 `utf-8-dos`로 열리고 한글 주석이 바르게 보이는 것
- 확인하지 않은 것: Visual Studio 안에서의 실제 단계 실행과 작업 디렉터리, 실제 키보드로 누르는 조작(Emacs 안에서 키 입력을 흉내 내어 확인), CP949 소스 변환, `S-F5`로 끝낸 뒤 실행 창에 보이는 종료 코드
