# VisualStudio2022_Gvim_Emacs

Windows 11에서 **Visual Studio 2022의 C/C++ 컴파일러**로 빌드하고, **gvim** 또는 **GNU Emacs**로 편집·빌드·실행·디버그하는 개인 학습 환경이다.
원래 PC의 두 폴더를 그대로 옮겼다.

| 폴더 | 원래 위치 | 내용 |
|---|---|---|
| [`01.c_study`](01.c_study) | `E:\Work\Dev\01.c_study` | C/C++ 파일 하나를 빌드·실행·디버그하는 공부 폴더. gvim, Emacs, 명령줄이 같은 `build.bat`, `run.bat`를 쓴다 |
| [`Galaga_Dev`](Galaga_Dev) | `C:\Users\User\Dev\Galaga_Dev` | Space Galaga(Win32 + C17, GDI로 그리는 슈팅 게임)의 VS 2022 솔루션, 소스, 시험 코드와 gvim 빌드 환경 |

두 폴더 모두 어느 위치에 두어도 동작한다(경로에 공백이 있어도 된다. 한글이 들어간 경로는 시험하지 않았다).
Emacs를 쓰려면 저장소에 없는 `handmade.emacs`를 따로 넣어야 한다([아래](#emacs를-쓰려면-handmadeemacs)).

## 01.c_study의 파일

| 파일 | 역할 |
|---|---|
| `shell.bat` | Visual Studio 2022 x64 컴파일러 환경을 연다(Community, Professional, Enterprise, BuildTools 순서로 찾는다) |
| `build.bat` | `build.bat c\01_hello.c` → `c\build\01_hello.exe`. `.c`는 C17, `.cpp`는 C++20, `-W4`, 최적화 없음, 디버그 정보 포함 |
| `run.bat` | 프로그램을 실행하고 종료 코드를 보여 준 뒤 키를 기다린다 |
| `gvim.bat`, `gvim_c_study.vim` | gvim을 시작하고, 마지막으로 연 `.c`/`.cpp` 파일을 빌드·실행·디버그하는 키와 새 파일 틀을 더한다 |
| `gvim_handmade.vim` | gvim 공통 설정: Alt 키 편집 명령, 어두운 테마, JetBrainsMono 글꼴(없으면 Consolas), Ctrl+마우스 휠 글꼴 크기, 괄호 짝 넣기, 코드 조각, 오류 이동 |
| `emacs.bat`, `emacs_c_study.el` | Emacs를 시작하고 gvim과 같은 빌드·실행·디버그 키를 더한다 |
| `emacs_theme.el`, `emacs_edit.el` | Emacs에 gvim과 같은 글꼴·색과 C/C++ 편집 보조 기능을 넣는다(Emacs 기본 기능만 쓴다) |
| `c\`, `cpp\` | 예제: `c\01_hello.c`, `c\02_input.c`, `c\03_struct_file.c`, `cpp\01_hello.cpp`, `cpp\02_class.cpp` |
| 연습 파일 | `01_hello.c`, `exam-1.c`, `exam-2.c`, `test.c`, `c%`, `c\exam-1.c`, `c\exam-2.c` |
| `C_C++_개발환경_구축가이드.docx` | 설치부터 디버깅까지 정리한 Word 가이드(46쪽, 부록에 설정 파일 전문) |
| `C_C++_빌드가이드.txt` | gvim 사용법과 키 전체 |
| `Emacs_C_C++_가이드.md`, `Emacs_키보드가이드.md` | Emacs 사용법과 키 전체 |

## 새 PC에 설치하기

1. **Visual Studio 2022**를 설치한다. 워크로드는 "C++를 사용한 데스크톱 개발".
2. **Vim 9 (gvim) 64비트**를 기본 위치(`C:\Program Files\Vim`)에 설치한다. www.vim.org의 Windows용 설치 파일(`gvim_9.x_x64.exe`) 또는 다음 명령.
   ```powershell
   winget install --id vim.vim -e
   ```
3. (Emacs를 쓸 때) **GNU Emacs**를 기본 위치(`C:\Program Files\Emacs\emacs-버전`)에 설치한다(31.1에서 확인).
   ```powershell
   winget install --id GNU.Emacs -e
   ```
4. (선택) **글꼴**: www.nerdfonts.com의 Downloads에서 JetBrainsMono를 받아 `JetBrainsMonoNerdFontMono-Regular.ttf`를 마우스 오른쪽 단추로 눌러 "설치"한다. 없으면 Consolas로 표시된다.
5. 이 저장소를 받는다. git이 있으면:
   ```powershell
   git clone https://github.com/sejgseok/VisualStudio2022_Gvim_Emacs.git D:\Work\VisualStudio2022_Gvim_Emacs
   ```
   git이 없으면 GitHub 페이지의 **Code > Download ZIP**으로 받아 풀고, 인터넷에서 받은 파일 표시를 지운다.
   ```powershell
   Expand-Archive -Path "$env:USERPROFILE\Downloads\VisualStudio2022_Gvim_Emacs-main.zip" -DestinationPath 'D:\Work'
   Get-ChildItem -Recurse 'D:\Work\VisualStudio2022_Gvim_Emacs-main' | Unblock-File
   ```
   원래 PC와 같게 두려면 `01.c_study`를 `E:\Work\Dev\01.c_study`로, `Galaga_Dev`를 `C:\Users\<사용자>\Dev\Galaga_Dev`로 옮긴다.
6. 확인한다. 한글이 바르게 나오고 마지막에 `exited with code 0`이 보이면 된다.
   ```powershell
   Set-Location 'D:\Work\VisualStudio2022_Gvim_Emacs\01.c_study'
   .\build.bat c\01_hello.c
   .\run.bat c\build\01_hello.exe
   .\gvim.bat c\01_hello.c
   ```
   gvim에서 Alt+m을 누르면 아래에 `-- Build succeeded.`가, F5를 누르면 새 콘솔 창에 실행 결과가 나온다.

`.gitattributes`가 줄 끝 변환을 끄므로 `git clone`으로 받아도 `.bat` 파일은 CRLF 그대로 받아진다.

## 자주 쓰는 키

대상은 마지막으로 연 `.c` 또는 `.cpp` 파일이다. 나머지 키는 `C_C++_빌드가이드.txt`(gvim)와 `Emacs_키보드가이드.md`(Emacs)에 있다.

| 하는 일 | gvim | Emacs |
|---|---|---|
| 저장하고 빌드 | Alt+m | M-m |
| 실행(새 콘솔 창, 소스 파일이 있는 폴더에서) | F5 | F5 |
| 빌드한 뒤 성공하면 실행 | Ctrl+F5 | C-F5 |
| 실행 중인 프로그램 강제 종료 | Shift+F5 | S-F5 |
| Visual Studio 2022 디버거로 열기 | F6 | F6 |
| 첫 오류 / 다음 오류 / 이전 오류 | F9 / Alt+n / Alt+Shift+n | F9 / M-n / M-N |
| 파일 열기 | Alt+f | M-f |
| 글꼴 크기 | Ctrl+마우스 휠 | Ctrl+마우스 휠 |

## Emacs를 쓰려면: handmade.emacs

`emacs_c_study.el`은 먼저 같은 폴더의 `handmade.emacs`를 읽는다. 이 파일은 Handmade Hero(Casey Muratori, Molly Rocket) 강의의 Emacs 설정(`.emacs`)을 이 환경에 맞춘 사본이라, 저작권 때문에 저장소에 넣지 않았다(`.gitignore`에도 적어 실수로 올라가지 않게 했다). 없으면 Emacs가 `handmade.emacs was not found in ...` 오류를 낸다. gvim과 명령줄에는 필요 없다.

본인의 PC에서 다음 중 하나를 `01.c_study\handmade.emacs`로 복사한다(모두 같은 파일이다).

- 원래 PC의 `E:\Work\Dev\01.c_study\handmade.emacs`
- 이 환경으로 설정한 Handmade Hero 작업 폴더의 day 062 이후 `misc\.emacs`(예: `E:\Work\Dev\02.handmade_dev\01.Dev_work\handmade_hero_day_062_source\misc\.emacs`)
- 개인용 압축 파일 `01.c_study_환경설정.zip` 또는 `Gvim_Emacs_개발환경_V1.zip` 안의 `01.c_study/handmade.emacs`

Handmade Hero 원본 zip에 들어 있는 2014년 `.emacs`는 이 파일과 다르다(그대로 쓰는 것은 시험하지 않았다). 그다음 `emacs.bat` 또는 `emacs.bat c\01_hello.c`로 시작한다.

## Galaga_Dev

- `Space_Galaga.sln`을 Visual Studio 2022로 열어 빌드·실행할 수 있다(`README.md`).
- `gvim.bat`는 `Space_Galaga\main.c`를 gvim으로 연다. Alt+m 솔루션 빌드(MSBuild), Ctrl+F5 빌드 후 실행, F5 실행, Shift+F5 종료, F6 Visual Studio 디버거, F7 시험(`tests\game_tests.c`) 빌드와 실행. 명령줄에서는 `build.bat`, `test.bat`.
- `gvim.bat`는 `gvim_handmade.vim`을 ① `Galaga_Dev\gvim_handmade.vim`, ② `E:\Work\Dev\02.handmade_dev\01.Dev_work\gvim_handmade.vim`, ③ `E:\Work\Dev\01.c_study\gvim_handmade.vim` 순서로 찾는다. 저장소의 `01.c_study`를 `E:\Work\Dev\01.c_study`에 두었다면 ③이 쓰인다. 다른 곳에 두었다면 `01.c_study\gvim_handmade.vim`을 `Galaga_Dev`에 복사하거나, `gvim.bat`의 `set "hh_vim="` 뒤에 그 파일의 전체 경로를 쓴다.
- 자세한 것은 `빌드_가이드.txt`(gvim 환경)와 `Galaga_가이드.txt`(게임 코드 설명)에 있다.

## 문서를 읽을 때

문서는 원래 PC에서 쓴 것이라 그 PC의 경로(`E:\Work\Dev\...`), 그 PC에만 있는 Handmade Hero 작업 폴더와 개인용 압축 파일(`01.c_study_환경설정.zip` 등) 이야기가 나온다. 저장소에서 받았다면 그 경로를 받은 폴더로 바꿔 읽는다.
저장소에 맞게 고친 곳은 두 문단이다: `C_C++_개발환경_구축가이드.docx` 부록 A의 "주의"와 `Galaga_Dev\빌드_가이드.txt` 2장의 `gvim_handmade.vim` 설명. 나머지 파일은 원래 PC의 파일과 같다.

## 저작권

- Handmade Hero(Casey Muratori, Molly Rocket)의 소스, 아트, 에셋 파일, `.emacs`와 그것으로 만든 파일은 개인 학습용 라이선스라 이 저장소에 넣지 않는다.
- `gvim_handmade.vim`, `emacs_theme.el`, `emacs_edit.el`, `emacs_c_study.el`은 Handmade Hero의 Emacs 키 배치와 동작을 흉내 내어 새로 쓴 파일이다. Casey의 코드는 들어 있지 않다.
- Space Galaga, 예제, 연습 파일은 이 저장소 주인의 것이다.
