" C/C++ study settings for gvim. gvim.bat in this folder loads this file with -u.
"
" It first sources gvim_handmade.vim, the Handmade Hero gvim settings, so the
" editing settings, keys, font (JetBrainsMono Nerd Font Mono 12, Ctrl+mouse
" wheel to zoom) and dark theme are exactly those of the Handmade Hero
" folders. A copy in this folder is used first. Without one, the file in the
" parent folder is used (01.Dev_work\01.c_study, where changes to
" 01.Dev_work\gvim_handmade.vim then apply here too).
" Then it points build and run at single study programs:
"   Alt+m      build the current program (build.bat in this folder)
"   F5         run it in a new console window, in the source file's folder
"   Ctrl+F5    build, then run if the build succeeded
"   Shift+F5   stop it
"   F6         open it in the Visual Studio debugger
" The current program is the .c or .cpp file entered last. It is shown in the
" status line. build.bat reads it from the environment variable CS_SOURCE.

let s:study = expand('<sfile>:p:h')
let s:base = s:study . '\gvim_handmade.vim'
if !filereadable(s:base)
    let s:base = fnamemodify(s:study, ':h') . '\gvim_handmade.vim'
endif
if !filereadable(s:base)
    echoerr 'gvim_handmade.vim was not found in ' . s:study . ' or its parent folder.'
    finish
endif
execute 'source ' . fnameescape(s:base)

" gvim on Windows changes to the folder of a file given with a full path, so
" the working folder is set to this folder after startup. :e c\04_test.c and
" Alt+f then always start here.
function! s:EnterStudy() abort
    execute 'cd ' . fnameescape(s:study)
endfunction

autocmd VimEnter * call s:EnterStudy()

" ---------------------------------------------------------------------------
" The current program
" ---------------------------------------------------------------------------

let $CS_SOURCE = ''

function! s:SetProgram() abort
    let l:file = expand('%:p')
    if l:file =~? '\.\%(c\|cpp\)$'
        let $CS_SOURCE = l:file
    endif
endfunction

autocmd BufEnter,BufWritePost,BufFilePost *.c,*.cpp call s:SetProgram()

function! CSProgram() abort
    return empty($CS_SOURCE) ? 'no program' : fnamemodify($CS_SOURCE, ':t')
endfunction

set statusline=\ %f\ %m%r%=[%{CSProgram()}]\ %{HHStatus()}\ \ %l:%c\ \ %{strftime('%H:%M')}

" ---------------------------------------------------------------------------
" Run, stop, debug. HHBuild (Alt+m) from gvim_handmade.vim already builds with
" the nearest build.bat, which is the one in this folder.
" ---------------------------------------------------------------------------

function! s:Error(message) abort
    echohl ErrorMsg
    echo a:message
    echohl None
endfunction

function! s:Detached(command) abort
    call job_start('cmd.exe /c ' . a:command, {
                \ 'in_io': 'null', 'out_io': 'null', 'err_io': 'null',
                \ 'stoponexit': '',
                \ })
endfunction

function! s:ExePath() abort
    if empty($CS_SOURCE)
        call s:Error('Open a .c or .cpp file first.')
        return ''
    endif
    let l:exe = fnamemodify($CS_SOURCE, ':h') . '\build\' . fnamemodify($CS_SOURCE, ':t:r') . '.exe'
    if !filereadable(l:exe)
        call s:Error('Nothing to run. Build ' . fnamemodify($CS_SOURCE, ':t') . ' first (Alt+m).')
        return ''
    endif
    return l:exe
endfunction

" run.bat shows the exit code and waits for a key before the window closes.
function! s:Run() abort
    let l:exe = s:ExePath()
    if empty(l:exe)
        return
    endif
    let l:dir = fnamemodify($CS_SOURCE, ':h')
    let l:name = fnamemodify(l:exe, ':t')
    call s:Detached('start "' . l:name . '" /d "' . l:dir . '" cmd.exe /c ""'
                \ . s:study . '\run.bat" "' . l:exe . '""')
    if getftime($CS_SOURCE) > getftime(l:exe)
        echohl WarningMsg
        echo 'Running ' . l:name . ', which is older than the source. Alt+m rebuilds it.'
        echohl None
    else
        echo 'Running ' . l:name . ' in ' . l:dir
    endif
endfunction

function! s:Stop() abort
    if empty($CS_SOURCE)
        return
    endif
    let l:name = fnamemodify($CS_SOURCE, ':t:r') . '.exe'
    call s:Detached('taskkill /IM "' . l:name . '" /F')
    echo 'Stopping ' . l:name
endfunction

function! s:Debug() abort
    let l:exe = s:ExePath()
    if empty(l:exe)
        return
    endif
    if empty($DevEnvDir)
        call s:Error('DevEnvDir is not set. Start gvim with gvim.bat.')
        return
    endif
    call s:Detached('start "" "' . $DevEnvDir . 'devenv.exe" /DebugExe "' . l:exe . '"')
    echo 'Opening Visual Studio'
endfunction

" Ctrl+F5: HHBuild runs in the background, so a timer waits for it to finish.
let s:run_timer = -1

function! s:RunAfterBuild(timer) abort
    if HHBuildRunning()
        return
    endif
    call timer_stop(a:timer)
    let s:run_timer = -1
    if HHStatus() =~# 'build ok'
        call s:Run()
    endif
endfunction

function! s:BuildAndRun() abort
    if HHBuildRunning()
        echo 'A build is already running.'
        return
    endif
    HHBuild
    if !HHBuildRunning()
        return
    endif
    call timer_stop(s:run_timer)
    let s:run_timer = timer_start(100, function('s:RunAfterBuild'), {'repeat': -1})
endfunction

" The F5, Shift+F5 and F6 keys of gvim_handmade.vim call these commands.
command! HHRun call s:Run()
command! HHStop call s:Stop()
command! HHDebug call s:Debug()
command! CSBuildRun call s:BuildAndRun()

for s:mode in ['n', 'i', 'x']
    execute s:mode . 'noremap <silent> <C-F5> <Cmd>CSBuildRun<CR>'
endfor

" ---------------------------------------------------------------------------
" New files
" ---------------------------------------------------------------------------

" A new .c or .cpp file starts with main, and typing starts inside it. The
" function name starts the line, as in the Handmade Hero code, so Alt+j lists it.
function! s:NewProgram() abort
    if expand('%:e') ==? 'c'
        call setline(1, ['#include <stdio.h>', '', 'int', 'main(void)', '{', '    ', '    return(0);', '}'])
    else
        call setline(1, ['#include <iostream>', '', 'int', 'main()', '{', '    ', '    return(0);', '}'])
    endif
    call cursor(6, 1)
    startinsert!
endfunction

autocmd BufNewFile *.c,*.cpp call s:NewProgram()
