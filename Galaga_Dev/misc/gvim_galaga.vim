" Space Galaga settings for gvim. gvim.bat in the solution folder loads this
" file with -u.
"
" It first sources gvim_handmade.vim, the user's gvim settings shared with the
" Handmade Hero folders: editing keys, font (JetBrainsMono Nerd Font Mono 12,
" Ctrl+mouse wheel to zoom), dark theme, error keys. gvim.bat passes its path
" in GALAGA_HH_VIM. Then it points building, running, testing and debugging
" at Space_Galaga.sln:
"   Alt+m      build the solution in the current configuration (build.bat)
"   F5         run bin\<x64 or Win32>\<Debug or Release>\Space_Galaga.exe
"   Ctrl+F5    build, then run if the build succeeded
"   Shift+F5   stop Space_Galaga.exe
"   F6         open that exe in the Visual Studio debugger
"   F7         build and run the tests (test.bat)
"   :Config Release x86   change the configuration (Debug x64 at start)
"   :DebugTests           open the test program in the Visual Studio debugger
"   :Solution             open Space_Galaga.sln in Visual Studio
" The configuration and the last build and test results are shown in the
" status line. Build and test output goes to the quickfix list (F9, F10, F11).

let s:misc = expand('<sfile>:p:h')
let s:root = fnamemodify(s:misc, ':h')
if empty($GALAGA_HH_VIM) || !filereadable($GALAGA_HH_VIM)
    echoerr 'gvim_handmade.vim was not found. Start gvim with gvim.bat in ' . s:root . '.'
    finish
endif
execute 'source ' . fnameescape($GALAGA_HH_VIM)

" gvim on Windows changes to the folder of a file given with a full path, so
" the working folder is set to the solution folder after startup.
function! s:EnterRoot() abort
    execute 'cd ' . fnameescape(s:root)
endfunction

autocmd VimEnter * call s:EnterRoot()

function! s:Error(message) abort
    echohl ErrorMsg
    echo a:message
    echohl None
endfunction

function! s:Warning(message) abort
    echohl WarningMsg
    echo a:message
    echohl None
endfunction

" cmd's start is used because a job's first window would otherwise open hidden.
function! s:Detached(command) abort
    call job_start('cmd.exe /c ' . a:command, {
                \ 'in_io': 'null', 'out_io': 'null', 'err_io': 'null',
                \ 'stoponexit': '',
                \ })
endfunction

" ---------------------------------------------------------------------------
" Configuration. build.bat reads GALAGA_CONFIG and GALAGA_PLATFORM.
" ---------------------------------------------------------------------------

let $GALAGA_CONFIG = 'Debug'
let $GALAGA_PLATFORM = 'x64'
let s:build_state = ''
let s:test_state = ''

function! s:ExePath() abort
    return printf('%s\bin\%s\%s\Space_Galaga.exe', s:root,
                \ $GALAGA_PLATFORM ==# 'x86' ? 'Win32' : 'x64', $GALAGA_CONFIG)
endfunction

function! s:Relative(path) abort
    return strpart(a:path, len(s:root) + 1)
endfunction

function! s:Config(...) abort
    for l:word in a:000
        if l:word =~? '^debug$'
            let $GALAGA_CONFIG = 'Debug'
        elseif l:word =~? '^release$'
            let $GALAGA_CONFIG = 'Release'
        elseif l:word =~? '^x64$'
            let $GALAGA_PLATFORM = 'x64'
        elseif l:word =~? '^\%(x86\|win32\)$'
            let $GALAGA_PLATFORM = 'x86'
        else
            call s:Error('Unknown "' . l:word . '". Use Debug, Release, x64 or x86.')
            return
        endif
    endfor
    if a:0 > 0
        " The last build result belonged to the previous configuration.
        let s:build_state = ''
        redrawstatus!
    endif
    echo 'Configuration ' . $GALAGA_CONFIG . ' ' . $GALAGA_PLATFORM . ': ' . s:Relative(s:ExePath())
endfunction

function! GalagaConfigNames(lead, line, position) abort
    return filter(['Debug', 'Release', 'x64', 'x86'], 'v:val =~? "^" . a:lead')
endfunction

function! GalagaStatus() abort
    let l:text = '[' . $GALAGA_CONFIG . ' ' . $GALAGA_PLATFORM . ']'
    if !empty(s:build_state)
        let l:text .= '  ' . s:build_state
    endif
    if !empty(s:test_state)
        let l:text .= '  ' . s:test_state
    endif
    return l:text
endfunction

set statusline=\ %f\ %m%r%=%{GalagaStatus()}\ \ %l:%c\ \ %{strftime('%H:%M')}

" ---------------------------------------------------------------------------
" Build and test in the background. The output goes to the quickfix list.
" ---------------------------------------------------------------------------

" MSVC messages from MSBuild and cl, and failed asserts in the tests.
let s:efm = '%f(%l\,%c): %t%*\D%n: %m,%f(%l): %t%*\D%n: %m,%f(%l) : %t%*\D%n: %m,'
            \ . 'Assertion failed: %m\, file %f\, line %l'
let s:job_kind = ''
let s:job_closed = 0
let s:job_status = v:null
let s:job_list = 0
let s:run_after_build = 0

" On Korean Windows MSBuild writes UTF-8, while cmd and cl write code page 949.
" A line that is valid UTF-8 is kept; any other line is converted from 949.
function! s:Decode(line) abort
    let l:line = substitute(a:line, '\r$', '', '')
    if l:line =~# '^[\x01-\x7f]*$' || list2str(str2list(l:line)) ==# l:line
        return l:line
    endif
    let l:text = iconv(l:line, 'cp949', 'utf-8')
    return empty(l:text) ? l:line : l:text
endfunction

function! s:OnJobLine(channel, line) abort
    call setqflist([], 'a', {'id': s:job_list, 'lines': [s:Decode(a:line)], 'efm': s:efm})
    silent! cbottom
endfunction

function! s:FinishJob() abort
    if s:job_status is v:null || !s:job_closed
        return
    endif
    let l:kind = s:job_kind
    let s:job_kind = ''
    let l:items = getqflist({'id': s:job_list, 'items': 0}).items
    let l:count = len(filter(copy(l:items), 'v:val.valid'))
    let l:places = l:count == 1 ? '1 location' : l:count . ' locations'
    if l:kind ==# 'build'
        let s:build_state = s:job_status == 0 ? 'build ok' : 'build FAILED'
        let l:result = s:job_status == 0 ? 'Build succeeded.'
                    \ : printf('Build FAILED (exit %d, %s).', s:job_status, l:places)
    else
        let s:test_state = s:job_status == 0 ? 'tests ok' : 'tests FAILED'
        let l:result = s:job_status == 0 ? 'Tests passed.'
                    \ : printf('Tests FAILED (exit %d, %s).', s:job_status, l:places)
    endif
    call setqflist([], 'a', {'id': s:job_list, 'lines': ['-- ' . l:result], 'efm': s:efm})
    silent! cbottom
    redrawstatus!
    echo l:result
    if l:kind ==# 'build' && s:run_after_build
        let s:run_after_build = 0
        if s:job_status == 0
            call s:Run()
        endif
    endif
endfunction

function! s:OnJobExit(job, status) abort
    let s:job_status = a:status
    call s:FinishJob()
endfunction

function! s:OnJobClose(channel) abort
    let s:job_closed = 1
    call s:FinishJob()
endfunction

" Saves all files, then runs build.bat or test.bat in the solution folder.
function! s:StartJob(kind, script) abort
    if !empty(s:job_kind)
        echo (s:job_kind ==# 'build' ? 'A build' : 'A test run') . ' is already running.'
        return 0
    endif
    silent! wall
    call setqflist([], ' ', {'title': a:kind . ': ' . a:script})
    let s:job_list = getqflist({'id': 0}).id
    let s:job_kind = a:kind
    let s:job_closed = 0
    let s:job_status = v:null
    if a:kind ==# 'build'
        let s:build_state = 'building...'
    else
        let s:test_state = 'testing...'
    endif
    let l:window = win_getid()
    botright copen 12
    call win_gotoid(l:window)
    redrawstatus!
    let l:job = job_start('cmd.exe /c "' . a:script . '"', {
                \ 'cwd': s:root,
                \ 'in_io': 'null',
                \ 'err_io': 'out',
                \ 'out_cb': function('s:OnJobLine'),
                \ 'close_cb': function('s:OnJobClose'),
                \ 'exit_cb': function('s:OnJobExit'),
                \ })
    if job_status(l:job) ==# 'fail'
        let s:job_kind = ''
        call s:Error('Could not start ' . a:script)
        return 0
    endif
    return 1
endfunction

function! s:Build() abort
    call s:StartJob('build', s:root . '\build.bat')
endfunction

function! s:BuildAndRun() abort
    let s:run_after_build = s:StartJob('build', s:root . '\build.bat')
endfunction

function! s:Test() abort
    call s:StartJob('test', s:root . '\test.bat')
endfunction

" ---------------------------------------------------------------------------
" Run, stop, debug
" ---------------------------------------------------------------------------

function! s:Newest() abort
    return max(map(glob(s:root . '\Space_Galaga\*.[ch]', 1, 1), 'getftime(v:val)'))
endfunction

function! s:Built(exe, how) abort
    if filereadable(a:exe)
        return 1
    endif
    call s:Error('Nothing to run: ' . s:Relative(a:exe) . '. ' . a:how)
    return 0
endfunction

" Runs in the project folder, which is also where Visual Studio runs it.
function! s:Run() abort
    let l:exe = s:ExePath()
    if !s:Built(l:exe, 'Build it first (Alt+m).')
        return
    endif
    call s:Detached('start "" /d "' . s:root . '\Space_Galaga" "' . l:exe . '"')
    if s:Newest() > getftime(l:exe)
        call s:Warning('Running ' . s:Relative(l:exe) . ', which is older than the source. Alt+m rebuilds it.')
    else
        echo 'Running ' . s:Relative(l:exe)
    endif
endfunction

function! s:Stop() abort
    call s:Detached('taskkill /IM Space_Galaga.exe /F')
    echo 'Stopping Space_Galaga.exe'
endfunction

function! s:DebugExe(exe, how) abort
    if !s:Built(a:exe, a:how)
        return
    endif
    if empty($DevEnvDir)
        call s:Error('DevEnvDir is not set. Start gvim with gvim.bat.')
        return
    endif
    call s:Detached('start "" "' . $DevEnvDir . 'devenv.exe" /DebugExe "' . a:exe . '"')
    echo 'Opening ' . s:Relative(a:exe) . ' in the Visual Studio debugger'
endfunction

function! s:Debug() abort
    let l:exe = s:ExePath()
    call s:DebugExe(l:exe, 'Build it first (Alt+m).')
    if filereadable(l:exe) && s:Newest() > getftime(l:exe)
        call s:Warning('The exe is older than the source. Build it (Alt+m) before you start debugging.')
    endif
endfunction

function! s:DebugTests() abort
    call s:DebugExe(s:root . '\bin\tests\game_tests.exe', 'Run the tests first (F7).')
endfunction

function! s:Solution() abort
    if empty($DevEnvDir)
        call s:Error('DevEnvDir is not set. Start gvim with gvim.bat.')
        return
    endif
    call s:Detached('start "" "' . $DevEnvDir . 'devenv.exe" "' . s:root . '\Space_Galaga.sln"')
    echo 'Opening Space_Galaga.sln in Visual Studio'
endfunction

" Alt+m, F5, Shift+F5 and F6 of gvim_handmade.vim call these commands.
command! HHBuild call s:Build()
command! HHRun call s:Run()
command! HHStop call s:Stop()
command! HHDebug call s:Debug()
command! Test call s:Test()
command! DebugTests call s:DebugTests()
command! Solution call s:Solution()
command! -nargs=* -complete=customlist,GalagaConfigNames Config call s:Config(<f-args>)

for s:mode in ['n', 'i', 'x']
    execute s:mode . 'noremap <silent> <C-F5> <Cmd>call <SID>BuildAndRun()<CR>'
    execute s:mode . 'noremap <silent> <F7> <Cmd>Test<CR>'
    execute s:mode . 'noremap <silent> <M-j> <Cmd>call <SID>SymbolList()<CR>'
endfor

" ---------------------------------------------------------------------------
" The Space Galaga code style (AGENTS.md), where it differs from Casey's
" ---------------------------------------------------------------------------

" Braces of if, for, while and switch stay on the line; case labels line up
" with their switch, the statements under a case are one level in, and so are
" the continuation lines of a call (not lined up with its parenthesis).
" Reindenting all of Space_Galaga and tests with = changes one line.
function! s:SetupGalaga() abort
    setlocal cinoptions=>4,n0,t0,(4,W4,:0,=4,l1,g0,{0,+4
    inoremap <buffer> <silent> <M-e> <Cmd>call <SID>ExpandSnippet()<CR>
endfunction

autocmd FileType c,cpp call s:SetupGalaga()

" Alt+e after one of these words, as in gvim_handmade.vim. @ marks the cursor.
let s:snippets = {
            \ 'if': ['if (@) {', '    ', '}'],
            \ 'else': ['else {', '    @', '}'],
            \ 'for': ['for (i = 0; i < @; ++i) {', '    ', '}'],
            \ 'while': ['while (@) {', '    ', '}'],
            \ 'switch': ['switch (@) {', 'case :', '    break;', 'default:', '    break;', '}'],
            \ 'case': ['case @:', '    ', '    break;'],
            \ 'struct': ['typedef struct @ {', '    ', '} ;'],
            \ 'inc': ['#include <@>'],
            \ }

function! s:ExpandSnippet() abort
    let l:before = strpart(getline('.'), 0, col('.') - 1)
    let l:word = matchstr(l:before, '\k\+$')
    if !has_key(s:snippets, l:word)
        echo 'No snippet for "' . l:word . '"'
        return
    endif
    let l:indent = matchstr(l:before, '^\s*')
    let l:rest = strpart(getline('.'), col('.') - 1)
    let l:lines = map(copy(s:snippets[l:word]), {_, v -> l:indent . v})
    let l:lines[0] = strpart(l:before, 0, len(l:before) - len(l:word)) . s:snippets[l:word][0]
    let l:lines[-1] .= l:rest
    let l:start = line('.')
    call setline(l:start, l:lines[0])
    call append(l:start, l:lines[1:])
    let l:offset = indexof(l:lines, {_, v -> v =~# '@'})
    let l:column = stridx(l:lines[l:offset], '@')
    call setline(l:start + l:offset, substitute(l:lines[l:offset], '@', '', ''))
    call cursor(l:start + l:offset, l:column + 1)
endfunction

" Alt+j lists the function definitions of the file. Here the return type is
" on the same line, so a definition is a line that starts with a name, has a
" ( after its first words, and does not end with ; (a declaration).
function! s:SymbolList() abort
    try
        lvimgrep /^\h[^;=(]*([^;]*$/j %
        lopen
    catch /E480/
        echo 'No functions found.'
    endtry
endfunction

" New headers get an include guard like game.h's (gvim_handmade.vim writes
" #if !defined first; this replaces it).
function! s:NewHeader() abort
    let l:guard = 'SPACE_GALAGA_' . toupper(substitute(expand('%:t:r'), '\W', '_', 'g')) . '_H'
    silent %delete _
    call setline(1, ['#ifndef ' . l:guard, '#define ' . l:guard, '', '', '', '#endif'])
    call cursor(4, 1)
endfunction

autocmd BufNewFile *.h call s:NewHeader()
