" Handmade Hero settings for gvim. gvim.bat loads this with -u, so the personal
" _vimrc is skipped, the same way emacs.bat loads misc\.emacs with -q.

set runtimepath=$VIMRUNTIME
set encoding=utf-8
scriptencoding utf-8
set fileencodings=ucs-bom,utf-8,cp949,latin1

" M keeps menu.vim from loading; no menu bar, toolbar, or scrollbars, as in .emacs.
set guioptions=M
syntax on
filetype plugin indent on
let c_no_comment_fold = 1
set foldlevelstart=99
autocmd BufNewFile,BufRead *.hin,*.cin,*.inl,*.rdc,*.c8 setfiletype cpp

" Editing
set hidden
set backspace=indent,eol,start
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 autoindent
set cinoptions=>4,n0,t0,(0,W4,:4,=0,l1,g0,{0,+4
set complete=.,w,b completeopt=menu
set clipboard=unnamed
set mouse=a
set timeoutlen=500

" No backup, swap, or undo files. .emacs turns these off too.
set nobackup nowritebackup noswapfile noundofile undolevels=10000

" Display
set number numberwidth=4
set nowrap cursorline scrolljump=3 belloff=all
set incsearch ignorecase smartcase
set wildmenu wildmode=longest:full,full wildignorecase
set splitright switchbuf=useopen
set laststatus=2
set statusline=\ %f\ %m%r%=%{HHStatus()}\ \ %l:%c\ \ %{strftime('%H:%M')}
set title titlestring=gvim\ -\ %{fnamemodify($HH_PROJECT,':t')}\ -\ %t

" Alt keys must reach the mappings below instead of the Windows menu.
set winaltkeys=no

" ---------------------------------------------------------------------------
" Font and colors (the user's gvim theme; .emacs is not changed)
" ---------------------------------------------------------------------------

" JetBrainsMono Nerd Font Mono 12, as in the user's gvim screenshot (gvim-1.png).
" Windows knows it by the family name JetBrainsMono NFM; the long name fails
" with E596. Consolas 12 is used on a PC without it.
set guifont=JetBrainsMono_NFM:h12,Consolas:h12
" Empty, as in the screenshot: Windows then draws Korean with its fallback font
" (Malgun Gothic). Malgun Gothic cannot be named here, because gvim accepts
" only fixed-width wide fonts (E534); GulimChe:h12 would be such a font.
set guifontwide=

" Ctrl+mouse wheel up/down makes the font one point larger/smaller (6 to 40).
" It lasts until gvim closes; the next start uses the size set above.
function! s:FontSize(step) abort
    let l:size = str2float(matchstr(&guifont, ':h\zs\d\+\%(\.\d\+\)\='))
    if l:size == 0
        return
    endif
    " From a size like 11.5, up goes to 12 and down to 11.
    let l:base = a:step > 0 ? floor(l:size) : ceil(l:size)
    let l:new = max([6, min([40, float2nr(l:base) + a:step])])
    let &guifont = substitute(&guifont, ':h\d\+\%(\.\d\+\)\=', ':h' . l:new, 'g')
    redraw
    echo 'Font size ' . l:new
endfunction

for s:mode in ['n', 'i', 'x']
    execute s:mode . 'noremap <silent> <C-ScrollWheelUp> <Cmd>call <SID>FontSize(1)<CR>'
    execute s:mode . 'noremap <silent> <C-ScrollWheelDown> <Cmd>call <SID>FontSize(-1)<CR>'
endfor

" k: a font change keeps the window size and changes the number of lines and
" columns instead. Without it, a window that is not maximized grows and shrinks.
set guioptions+=k

" Dark theme. Sampled from the screenshot: Normal, CursorLine, CursorLineNr,
" LineNr, Comment, String, Type, Statement, PreProc, MatchParen, HHIdentifier,
" HHFunction, HHMember. The others do not appear in it and follow its style.
set background=dark
highlight clear
highlight Normal       guifg=#DADADA guibg=#1E1E1E
highlight Cursor       guifg=#1E1E1E guibg=#DADADA
highlight CursorLine   guibg=#282828 gui=NONE
highlight CursorLineNr guifg=#D9D9D9 guibg=#282828 gui=NONE
highlight LineNr       guifg=#858585 guibg=#1E1E1E
highlight Comment      guifg=#57A64A gui=NONE
highlight String       guifg=#D69D85 gui=NONE
highlight Character    guifg=#D69D85 gui=NONE
highlight Special      guifg=#D69D85 gui=NONE
highlight Number       guifg=#B5CEA8 gui=NONE
highlight Float        guifg=#B5CEA8 gui=NONE
highlight Constant     guifg=#B8D7A3 gui=NONE
highlight Boolean      guifg=#569CD6 gui=NONE
highlight Identifier   guifg=#BDB76B gui=NONE
highlight Function     guifg=#FF8000 gui=NONE
highlight Statement    guifg=#D8A0DF gui=NONE
highlight Operator     guifg=#569CD6 gui=NONE
highlight Type         guifg=#569CD6 gui=NONE
highlight StorageClass guifg=#569CD6 gui=NONE
highlight Structure    guifg=#569CD6 gui=NONE
highlight Typedef      guifg=#569CD6 gui=NONE
highlight PreProc      guifg=#9B9B9B gui=NONE
highlight Delimiter    guifg=#DADADA gui=NONE
highlight Error        guifg=#F44747 guibg=NONE gui=NONE
" Vim's C syntax marks TODO, FIXME and XXX in comments as Todo, and a syntax
" keyword wins over the HHTodo match below, so Todo gets the same red marker.
highlight Todo         guifg=Red guibg=NONE gui=bold,underline
highlight MatchParen   guifg=#FFD700 guibg=#3A3A3A gui=NONE
highlight Visual       guibg=#264F78
highlight Search       guifg=NONE guibg=#613315
highlight IncSearch    guifg=NONE guibg=#515C6A gui=NONE
highlight Pmenu        guifg=#DADADA guibg=#2D2D30
highlight PmenuSel     guifg=#FFFFFF guibg=#094771
highlight WildMenu     guifg=#FFFFFF guibg=#094771
highlight StatusLine   guifg=#DADADA guibg=#3C3C3C gui=NONE
highlight StatusLineNC guifg=#858585 guibg=#2D2D2D gui=NONE
highlight VertSplit    guifg=#2D2D2D guibg=#2D2D2D gui=NONE
highlight Folded       guifg=#858585 guibg=#2D2D2D
highlight NonText      guifg=#3C3C3C
highlight Directory    guifg=#569CD6
highlight Title        guifg=#569CD6 gui=NONE
highlight ErrorMsg     guifg=#F44747 guibg=NONE
highlight WarningMsg   guifg=#D7BA7D
highlight HHTodo       guifg=Red gui=bold,underline
highlight HHNote       guifg=#57A64A gui=bold,underline
" The day 015 .emacs adds STUDY and IMPORTANT. handmade.h uses IMPORTANT from day 015.
highlight HHStudy      guifg=Yellow gui=bold,underline
highlight HHImportant  guifg=Yellow gui=bold,underline
highlight HHIdentifier guifg=#BDB76B
highlight HHFunction   guifg=#FF8000
highlight HHMember     guifg=#DADADA
autocmd Syntax c,cpp syntax match HHTodo /\<TODO/ containedin=ALL
autocmd Syntax c,cpp syntax match HHNote /\<NOTE/ containedin=ALL
autocmd Syntax c,cpp syntax match HHStudy /\<STUDY/ containedin=ALL
autocmd Syntax c,cpp syntax match HHImportant /\<IMPORTANT/ containedin=ALL

" Vim's C and C++ syntax leaves names uncolored. As in the screenshot:
" - names are khaki (game_state, GameState, Buffer),
" - a name followed by ( is orange (Win32ResizeDIBSection, ArrayCount, main),
" - but after . or -> it stays plain (push_back, GetButtons).
" Keywords such as void and while keep their own colors, because Vim gives
" keywords priority over these matches. internal, local_persist and
" global_variable are macros, so they are names. A name right before a quote
" is a string prefix (L"", u8"", R"()") and is left alone.
autocmd Syntax c,cpp syntax match HHIdentifier /\<\h\w*\>["']\@!/
autocmd Syntax c,cpp syntax match HHFunction /\<\h\w*\ze\%(<[^<>()]*>\)\=\s*(/
autocmd Syntax c,cpp syntax match HHMember /\%(\.\|->\)\@2<=\h\w*\ze\%(<[^<>()]*>\)\=\s*(/

" Start maximized with two side-by-side windows, as .emacs does.
autocmd GUIEnter * simalt ~x
autocmd VimEnter * vsplit | wincmd h

" ---------------------------------------------------------------------------
" Build, run, debug
" ---------------------------------------------------------------------------

let s:efm = '%f(%l): %t%*\D%n: %m,%f(%l\,%c): %t%*\D%n: %m,%f(%l) : %t%*\D%n: %m'
let s:locked_script = ''
let s:build_job = v:null
let s:build_running = 0
let s:build_closed = 0
let s:build_status = v:null
let s:build_id = 0
let s:build_state = ''
let s:build_suffix = ''

function! s:Error(message) abort
    echohl ErrorMsg
    echo a:message
    echohl None
endfunction

function! HHStatus() abort
    let l:day = matchstr(fnamemodify($HH_PROJECT, ':t'), 'day_\zs\d\+')
    return (empty(l:day) ? '' : 'day ' . l:day) . (empty(s:build_state) ? '' : '  ' . s:build_state)
endfunction

" Same lookup as find-project-directory in .emacs: the locked script, then the
" nearest build.bat above the current file, then the project's code folder.
function! s:BuildScript() abort
    if !empty(s:locked_script)
        return s:locked_script
    endif
    let l:dir = expand('%:p:h')
    if empty(l:dir) || !isdirectory(l:dir)
        let l:dir = getcwd()
    endif
    let l:found = findfile('build.bat', escape(l:dir, ' ,') . ';')
    if !empty(l:found)
        return fnamemodify(l:found, ':p')
    endif
    let l:fallback = $HH_PROJECT . '\code\build.bat'
    return filereadable(l:fallback) ? l:fallback : ''
endfunction

function! s:OnBuildLine(channel, line) abort
    let l:text = iconv(a:line, 'cp949', 'utf-8')
    let l:text = substitute(empty(l:text) ? a:line : l:text, '\r$', '', '')
    call setqflist([], 'a', {'id': s:build_id, 'lines': [l:text], 'efm': s:efm})
    silent! cbottom
endfunction

function! s:FinishBuild() abort
    if s:build_status is v:null || !s:build_closed
        return
    endif
    let s:build_running = 0
    let l:items = getqflist({'id': s:build_id, 'items': 0}).items
    let l:errors = len(filter(copy(l:items), 'v:val.valid'))
    if s:build_status == 0
        let s:build_state = 'build ok' . s:build_suffix
        let l:result = 'Build succeeded' . s:build_suffix . '.'
    else
        let s:build_state = 'build FAILED' . s:build_suffix
        let l:result = printf('Build FAILED%s (exit %d, %d locations).', s:build_suffix, s:build_status, l:errors)
    endif
    call setqflist([], 'a', {'id': s:build_id, 'lines': ['-- ' . l:result], 'efm': s:efm})
    silent! cbottom
    redrawstatus!
    echo l:result
endfunction

function! s:OnBuildExit(job, status) abort
    let s:build_status = a:status
    call s:FinishBuild()
endfunction

function! s:OnBuildClose(channel) abort
    let s:build_closed = 1
    call s:FinishBuild()
endfunction

" Runs in the background, like compile in .emacs. Output goes to the quickfix list.
" s:Build('od') (Alt+Shift+m) runs "build.bat od": a Handmade Hero day whose
" 2014 flags use -O2 then builds with -Od, which is easier to step through in
" the debugger. Other build.bat files (C/C++ study, Galaga) would take "od" as
" a file name or target, so it is refused there.
function! s:Build(...) abort
    let l:od = a:0 && a:1 ==# 'od'
    if s:build_running
        echo 'A build is already running.'
        return
    endif
    let l:script = s:BuildScript()
    if empty(l:script)
        call s:Error('Could not find build.bat')
        return
    endif
    if l:od && l:script !~? '[\\/]handmade_hero_day_\d\+_source[\\/]code[\\/]build\.bat$'
        call s:Error('Alt+Shift+m (-Od build) works only in Handmade Hero day folders.')
        return
    endif
    let s:build_suffix = l:od ? ' (-Od)' : ''
    silent! wall
    call setqflist([], ' ', {'title': 'build: ' . l:script . (l:od ? ' od' : '')})
    let s:build_id = getqflist({'id': 0}).id
    let s:build_running = 1
    let s:build_closed = 0
    let s:build_status = v:null
    let s:build_state = 'building' . s:build_suffix . '...'
    let l:window = win_getid()
    botright copen 12
    call win_gotoid(l:window)
    redrawstatus!
    let l:command = l:od ? 'cmd.exe /c ""' . l:script . '" od"' : 'cmd.exe /c "' . l:script . '"'
    let s:build_job = job_start(l:command, {
                \ 'cwd': fnamemodify(l:script, ':h'),
                \ 'in_io': 'null',
                \ 'err_io': 'out',
                \ 'out_cb': function('s:OnBuildLine'),
                \ 'close_cb': function('s:OnBuildClose'),
                \ 'exit_cb': function('s:OnBuildExit'),
                \ })
endfunction

function! HHBuildRunning() abort
    return s:build_running
endfunction

" cmd's start is used because a job's first window would otherwise open hidden.
function! s:Detached(command) abort
    call job_start('cmd.exe /c ' . a:command, {
                \ 'in_io': 'null', 'out_io': 'null', 'err_io': 'null',
                \ 'stoponexit': '',
                \ })
endfunction

function! s:ExePath() abort
    let l:script = s:BuildScript()
    let l:exe = fnamemodify(l:script, ':p:h:h') . '\build\win32_handmade.exe'
    if empty(l:script) || !filereadable(l:exe)
        call s:Error('Nothing to run. Build first (Alt+m).')
        return ''
    endif
    return l:exe
endfunction

" Casey runs the game in data\, and from day 036 it loads test\*.bmp from the
" current directory. A day whose data folder has test\ runs there. Other days
" run in build\, because day 021 loads handmade.dll from the current directory.
" From day 460 the game looks for data\*.hha (and art\, sound\) below the
" current directory, so a day whose win32_handmade.cpp names data\\*.hha runs
" in the day folder itself.
function! s:RunDir(exe) abort
    let l:day = fnamemodify(a:exe, ':h:h')
    let l:src = l:day . '\code\win32_handmade.cpp'
    if filereadable(l:src) && match(readfile(l:src), '\Vdata\\\\*.hha') >= 0
        return l:day
    endif
    let l:data = l:day . '\data'
    return isdirectory(l:data . '\test') ? l:data : fnamemodify(a:exe, ':h')
endfunction

function! s:Run() abort
    let l:exe = s:ExePath()
    if !empty(l:exe)
        let l:dir = s:RunDir(l:exe)
        call s:Detached('start "" /d "' . l:dir . '" "' . l:exe . '"')
        echo 'Running ' . l:exe . ' in ' . fnamemodify(l:dir, ':t')
    endif
endfunction

function! s:Stop() abort
    call s:Detached('taskkill /IM win32_handmade.exe /F')
    echo 'Stopping win32_handmade.exe'
endfunction

" Visual Studio's /DebugExe takes devenv's start folder as the debugger's
" working directory, so devenv starts in the folder F5 runs the game in.
function! s:Debug() abort
    let l:exe = s:ExePath()
    if empty(l:exe)
        return
    endif
    if empty($DevEnvDir)
        call s:Error('DevEnvDir is not set. Start gvim with gvim.bat.')
        return
    endif
    let l:dir = s:RunDir(l:exe)
    call s:Detached('start "" /d "' . l:dir . '" "' . $DevEnvDir . 'devenv.exe" /DebugExe "' . l:exe . '"')
    echo 'Opening Visual Studio in ' . fnamemodify(l:dir, ':t')
endfunction

function! s:Lock(locked) abort
    let s:locked_script = a:locked ? s:BuildScript() : ''
    echo a:locked ? 'Build script locked: ' . s:locked_script : 'Build script is roaming.'
endfunction

" :cfirst would stop on the compiler's file name line, which is not an error.
function! s:FirstError() abort
    let l:index = indexof(getqflist(), 'v:val.valid')
    if l:index < 0
        echo 'No errors.'
    else
        execute 'cc ' . (l:index + 1)
    endif
endfunction

command! HHBuild call s:Build()
command! HHBuildOd call s:Build('od')
command! HHRun call s:Run()
command! HHStop call s:Stop()
command! HHDebug call s:Debug()
command! HHLock call s:Lock(1)
command! HHUnlock call s:Lock(0)

" ---------------------------------------------------------------------------
" Editing helpers
" ---------------------------------------------------------------------------

" Tabs become spaces on save in C++ and text files, as casey-save-buffer does.
function! s:Save() abort
    if &expandtab && &filetype =~# '^\%(c\|cpp\|text\)$'
        silent! %retab
    endif
    write
endfunction

function! s:KillBuffer() abort
    if &buftype ==# 'quickfix'
        close
        return
    endif
    let l:buffer = bufnr('%')
    if len(getbufinfo({'buflisted': 1})) > 1
        bprevious
    else
        enew
    endif
    execute 'confirm bdelete ' . l:buffer
endfunction

" Lists function definitions, which start at column 0 in this code style.
function! s:SymbolList() abort
    try
        lvimgrep /^\h\w*\s*(/j %
        lopen
    catch /E480/
        echo 'No functions found.'
    endtry
endfunction

" In C and C++, Tab first leaves a closing bracket or quote. Otherwise it
" completes the word before the cursor (dabbrev-expand in .emacs).
function! s:TabKey() abort
    if pumvisible()
        return "\<C-p>"
    endif
    if &filetype =~# '^c\%(pp\)\=$' && s:AtClosingKey()
        return "\<C-g>U\<Right>"
    endif
    return s:Before() =~# '\k$' ? "\<C-p>" : "\<Tab>"
endfunction

" ---------------------------------------------------------------------------
" Keys, following the Emacs key list in the day folder guide
" ---------------------------------------------------------------------------

function! s:MapCommand(key, command) abort
    for l:mode in ['n', 'i', 'x']
        execute l:mode . 'noremap <silent> ' . a:key . ' <Cmd>' . a:command . '<CR>'
    endfor
endfunction

" Leaves the command line open so the rest can be typed.
function! s:MapPrompt(key, text) abort
    execute 'nnoremap ' . a:key . ' :' . a:text
    execute 'inoremap ' . a:key . ' <C-o>:' . a:text
    execute 'xnoremap ' . a:key . ' <Esc>:' . a:text
endfunction

" Build and errors
call s:MapCommand('<M-m>', 'HHBuild')
call s:MapCommand('<M-M>', 'HHBuildOd')
call s:MapCommand('<F9>', 'call <SID>FirstError()')
call s:MapCommand('<F10>', 'cprevious')
call s:MapCommand('<F11>', 'cnext')
call s:MapCommand('<M-n>', 'cnext')
call s:MapCommand('<M-N>', 'cprevious')

" Run and debug
call s:MapCommand('<F5>', 'HHRun')
call s:MapCommand('<S-F5>', 'HHStop')
call s:MapCommand('<F6>', 'HHDebug')

" Files and buffers
call s:MapPrompt('<M-f>', 'edit<Space>')
call s:MapPrompt('<M-F>', 'vsplit<Space>')
call s:MapPrompt('<M-b>', 'buffer<Space>')
call s:MapPrompt('<M-B>', 'vertical<Space>sbuffer<Space>')
call s:MapCommand('<M-s>', 'call <SID>Save()')
call s:MapCommand('<M-k>', 'call <SID>KillBuffer()')
call s:MapCommand('<M-r>', 'confirm edit')
call s:MapCommand('<C-x><C-c>', 'confirm qall')
call s:MapCommand('<M-w>', 'wincmd w')
call s:MapCommand('<M-p>', 'simalt ~x')

" Navigation
call s:MapPrompt('<M-g>', '')
call s:MapPrompt('<M-x>', '')
call s:MapCommand('<M-j>', 'call <SID>SymbolList()')
nnoremap <M-Up> {
nnoremap <M-Down> }
nnoremap <C-Up> {
nnoremap <C-Down> }
xnoremap <M-Up> {
xnoremap <M-Down> }
inoremap <M-Up> <C-o>{
inoremap <M-Down> <C-o>}
nnoremap <C-s> /
inoremap <C-s> <C-o>/
inoremap <C-g> <Esc>
xnoremap <C-g> <Esc>
cnoremap <C-g> <C-c>

" Editing
call s:MapCommand('<M-u>', 'undo')
nnoremap <M-Space> v
inoremap <M-Space> <Esc>v
xnoremap <M-q> y
xnoremap <M-z> d
nnoremap <M-a> P
inoremap <M-a> <C-r><C-o>+
xnoremap <M-a> P
nnoremap <M-o> :.,$s///gc<Left><Left><Left><Left>
inoremap <M-o> <C-o>:.,$s///gc<Left><Left><Left><Left>
xnoremap <M-o> :s///gc<Left><Left><Left><Left>
nnoremap <F8> :.,$s///g<Left><Left><Left>
nnoremap <M-O> :.,$s///g<Left><Left><Left>
xnoremap <M-l> :s///g<Left><Left><Left>

" Indenting
inoremap <expr> <Tab> <SID>TabKey()
inoremap <S-Tab> <C-o>==
nnoremap <S-Tab> ==
xnoremap <C-Tab> =

" ---------------------------------------------------------------------------
" Insert mode shortcuts and line editing
" ---------------------------------------------------------------------------

inoremap jj <Esc>

" Always completes, even where Tab would leave a bracket.
inoremap <M-/> <C-p>

nnoremap <M-CR> o
inoremap <M-CR> <C-o>o

nnoremap <silent> <M-d> <Cmd>t.<CR>
inoremap <silent> <M-d> <Cmd>t.<CR>
xnoremap <silent> <M-d> :t'><CR>

nnoremap <silent> <M-S-Up> <Cmd>silent! move .-2<Bar>normal! ==<CR>
nnoremap <silent> <M-S-Down> <Cmd>silent! move .+1<Bar>normal! ==<CR>
inoremap <silent> <M-S-Up> <Cmd>silent! move .-2<Bar>normal! ==<CR>
inoremap <silent> <M-S-Down> <Cmd>silent! move .+1<Bar>normal! ==<CR>
xnoremap <silent> <M-S-Up> :<C-u>silent! '<,'>move '<-2<CR>gv=gv
xnoremap <silent> <M-S-Down> :<C-u>silent! '<,'>move '>+1<CR>gv=gv

call s:MapCommand('<F4>', 'call <SID>FindWord()')

" ---------------------------------------------------------------------------
" C and C++ editing
" ---------------------------------------------------------------------------

let s:pairs = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"}

" Bodies follow the code style of this project. @ marks the cursor.
let s:snippets = {
            \ 'if': ['if(@)', '{', '    ', '}'],
            \ 'else': ['else', '{', '    @', '}'],
            \ 'for': ['for(int Index = 0; Index < @; ++Index)', '{', '    ', '}'],
            \ 'while': ['while(@)', '{', '    ', '}'],
            \ 'switch': ['switch(@)', '{', '    case :', '    {', '    } break;', '', '    default:', '    {', '    } break;', '}'],
            \ 'case': ['case @:', '{', '    ', '} break;'],
            \ 'struct': ['struct @', '{', '    ', '};'],
            \ 'inc': ['#include <@>'],
            \ }

function! s:Before() abort
    return strpart(getline('.'), 0, col('.') - 1)
endfunction

function! s:Prev() abort
    return matchstr(s:Before(), '.$')
endfunction

function! s:Next() abort
    return strcharpart(strpart(getline('.'), col('.') - 1), 0, 1)
endfunction

function! s:InsideQuote(quote) abort
    return count(substitute(s:Before(), '\\.', '', 'g'), a:quote) % 2 == 1
endfunction

function! s:AtClosingKey() abort
    let l:next = s:Next()
    return l:next =~# '[)\]}]' || (l:next =~# '["'']' && s:InsideQuote(l:next))
endfunction

function! s:InCommentOrString() abort
    if col('.') <= 1
        return 0
    endif
    let l:name = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
    return l:name =~? 'comment\|string\|character\|format\|special'
endfunction

" A pair is added only where the closing character would not split other text.
function! s:CanPair() abort
    let l:next = s:Next()
    return empty(l:next) || l:next =~# '[[:space:])\]},;]'
endfunction

function! s:OpenKey(open, close) abort
    if s:InCommentOrString() || !s:CanPair()
        return a:open
    endif
    return a:open . a:close . "\<C-g>U\<Left>"
endfunction

function! s:CloseKey(close) abort
    return s:Next() ==# a:close ? "\<C-g>U\<Right>" : a:close
endfunction

function! s:QuoteKey(quote) abort
    if s:Next() ==# a:quote && s:InsideQuote(a:quote)
        return "\<C-g>U\<Right>"
    endif
    if s:Before() =~# '[\\[:alnum:]_]$' || s:InCommentOrString() || !s:CanPair()
        return a:quote
    endif
    return a:quote . a:quote . "\<C-g>U\<Left>"
endfunction

function! s:BackspaceKey() abort
    return get(s:pairs, s:Prev(), "\001") ==# s:Next() ? "\<BS>\<Del>" : "\<BS>"
endfunction

function! s:EnterKey() abort
    if pumvisible()
        return "\<C-y>"
    endif
    return s:Prev() ==# '{' && s:Next() ==# '}' ? "\<CR>\<C-o>O" : "\<CR>"
endfunction

function! s:ToggleComment(first, last) abort
    let l:lines = getline(a:first, a:last)
    let l:code = filter(copy(l:lines), {_, v -> v !~# '^\s*$'})
    if empty(l:code)
        return
    endif
    let l:current = line('.')
    let l:old = getline(l:current)
    if empty(filter(copy(l:code), {_, v -> v !~# '^\s*//'}))
        call map(l:lines, {_, v -> substitute(v, '^\(\s*\)// \=', '\1', '')})
    else
        let l:column = min(map(copy(l:code), {_, v -> len(matchstr(v, '^\s*'))}))
        call map(l:lines, {_, v -> v =~# '^\s*$' ? v : strpart(v, 0, l:column) . '// ' . strpart(v, l:column)})
    endif
    call setline(a:first, l:lines)
    call cursor(l:current, max([1, col('.') + len(getline(l:current)) - len(l:old)]))
endfunction

function! s:ToggleSelection() abort
    call s:ToggleComment(min([line('v'), line('.')]), max([line('v'), line('.')]))
endfunction

function! s:ExpandSnippet() abort
    let l:before = s:Before()
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

" Same pairing as casey-find-corresponding-file in .emacs.
function! s:CorrespondingFile(split) abort
    let l:base = expand('%:p:r')
    let l:extension = expand('%:e')
    if l:extension ==# 'hin'
        let l:target = l:base . '.cin'
    elseif l:extension ==# 'cin'
        let l:target = l:base . '.hin'
    elseif l:extension ==# 'h'
        let l:target = l:base . (filereadable(l:base . '.c') ? '.c' : '.cpp')
    elseif l:extension =~# '^c\%(pp\)\=$'
        let l:target = l:base . '.h'
    else
        call s:Error('No corresponding file for this type.')
        return
    endif
    execute (a:split ? 'vsplit ' : 'edit ') . fnameescape(l:target)
endfunction

" New headers get an include guard, as casey-header-format does in .emacs.
function! s:NewHeader() abort
    let l:guard = toupper(expand('%:t:r')) . '_H'
    call setline(1, ['#if !defined(' . l:guard . ')', '', '#define ' . l:guard, '#endif'])
    call cursor(2, 1)
endfunction

function! s:FindWord() abort
    let l:word = expand('<cword>')
    if empty(l:word)
        return
    endif
    let l:script = s:BuildScript()
    let l:dir = fnameescape(empty(l:script) ? getcwd() : fnamemodify(l:script, ':h'))
    try
        execute 'lvimgrep /\V\<' . escape(l:word, '/\') . '\>/j '
                    \ . l:dir . '/**/*.cpp ' . l:dir . '/**/*.c ' . l:dir . '/**/*.h'
        lopen
    catch /E480\|E479/
        echo 'Not found: ' . l:word
    endtry
endfunction

function! s:MapBuffer(key, command) abort
    for l:mode in ['n', 'i', 'x']
        execute l:mode . 'noremap <buffer> <silent> ' . a:key . ' <Cmd>' . a:command . '<CR>'
    endfor
endfunction

function! s:SetupCpp() abort
    setlocal formatoptions-=o foldmethod=syntax

    inoremap <buffer> <expr> ( <SID>OpenKey('(', ')')
    inoremap <buffer> <expr> [ <SID>OpenKey('[', ']')
    inoremap <buffer> <expr> { <SID>OpenKey('{', '}')
    inoremap <buffer> <expr> ) <SID>CloseKey(')')
    inoremap <buffer> <expr> ] <SID>CloseKey(']')
    inoremap <buffer> <expr> } <SID>CloseKey('}')
    inoremap <buffer> <expr> " <SID>QuoteKey('"')
    inoremap <buffer> <expr> ' <SID>QuoteKey("'")
    inoremap <buffer> <expr> <BS> <SID>BackspaceKey()
    inoremap <buffer> <expr> <CR> <SID>EnterKey()

    call s:MapBuffer('<F12>', 'call <SID>CorrespondingFile(0)')
    call s:MapBuffer('<M-c>', 'call <SID>CorrespondingFile(0)')
    call s:MapBuffer('<M-C>', 'call <SID>CorrespondingFile(1)')
    nnoremap <buffer> <silent> <M-;> <Cmd>call <SID>ToggleComment(line('.'), line('.'))<CR>
    inoremap <buffer> <silent> <M-;> <Cmd>call <SID>ToggleComment(line('.'), line('.'))<CR>
    xnoremap <buffer> <silent> <M-;> <Cmd>call <SID>ToggleSelection()<CR><Esc>
    inoremap <buffer> <silent> <M-e> <Cmd>call <SID>ExpandSnippet()<CR>
endfunction

autocmd FileType c,cpp call s:SetupCpp()
autocmd BufNewFile *.h call s:NewHeader()
