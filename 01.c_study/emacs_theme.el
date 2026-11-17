;;; emacs_theme.el --- gvim's font and colors for Casey's .emacs  -*- lexical-binding: t; -*-

;; misc\emacs.bat loads this file after .emacs:
;;   runemacs -q -l misc\.emacs -l misc\emacs_theme.el
;; In the C/C++ study folders and 03.c_project, emacs_c_study.el and
;; emacs_project.el load their own copy of this file at their end.
;; It gives Emacs the font and colors of gvim_handmade.vim (the user's gvim
;; theme) with built-in Emacs features only: faces and cc-mode font-lock, no
;; packages. .emacs is not changed. Without this file emacs.bat starts Emacs
;; with Casey's look again.
;;
;; - Font: JetBrainsMono NFM 12, or Consolas 12 on a PC without it. Korean is
;;   drawn with Windows' Malgun Gothic, as in gvim.
;; - Ctrl+mouse wheel up/down makes the font one point larger/smaller (6 to 40)
;;   in every window. It lasts until Emacs closes; the next start uses 12 again.
;;   The Emacs window keeps its size.
;; - C and C++ get gvim's colors: if/for/return purple, types and storage words
;;   blue, other names khaki, a name before ( orange (plain after . or ->),
;;   numbers light green, preprocessor lines gray, #if 0 blocks and the #else
;;   part of #if 1 in the comment color. As in gvim, a .h file counts as C
;;   unless one of its first 99 lines starts with class, namespace, template
;;   or using, and a .c file is C; then C++ words such as operator or this are
;;   ordinary names.

(require 'cc-mode)


;;; Font

(defvar hh-theme-font-families '("JetBrainsMono NFM" "Consolas")
  "Fonts to use; the first one installed wins (guifont in gvim_handmade.vim).
JetBrainsMono NFM is the Windows family name of JetBrainsMono Nerd Font Mono.")

(defvar hh-theme-font-size 12
  "Font size in points when Emacs starts.")

(defvar hh-theme--size nil
  "Font size in points set by `hh-theme-set-font'.
Kept here because Emacs reports the size of the font it found, e.g. 12.9
for 13.")

(defun hh-theme-font-family ()
  "Return the first installed family of `hh-theme-font-families', or nil."
  (let ((families hh-theme-font-families)
        (found nil))
    (while (and families (not found))
      (when (find-font (font-spec :family (car families)))
        (setq found (car families)))
      (setq families (cdr families)))
    found))

(defun hh-theme-set-font (size)
  "Use the theme font at SIZE points in every frame and in new frames.
Without any of `hh-theme-font-families' the current font gets that size."
  (let ((family (or (hh-theme-font-family)
                    (face-attribute 'default :family))))
    (set-face-attribute 'default nil :family family :height (* size 10)
                        :weight 'normal :slant 'normal :width 'normal)
    ;; .emacs puts Consolas-11.5 into default-frame-alist, and new frames
    ;; (C-x 5 2) take their font from there.
    (setf (alist-get 'font default-frame-alist) (format "%s-%d" family size))
    (setq hh-theme--size size)))

(defun hh-theme-font-size-step (step)
  "Make the font STEP points larger (smaller when negative), from 6 to 40."
  (let* ((size (or hh-theme--size
                   (/ (face-attribute 'default :height nil t) 10.0)))
         ;; From a size like 11.5, up goes to 12 and down to 11, as in gvim.
         (base (if (> step 0) (floor size) (ceiling size)))
         (new (max 6 (min 40 (+ base step)))))
    (hh-theme-set-font new)
    (message "Font size %d" new)))

(defun hh-theme-font-larger ()
  "Ctrl+mouse wheel up: make the font one point larger."
  (interactive)
  (hh-theme-font-size-step 1))

(defun hh-theme-font-smaller ()
  "Ctrl+mouse wheel down: make the font one point smaller."
  (interactive)
  (hh-theme-font-size-step -1))

;; Also over the line between two windows, the mode line and the fringes, so
;; that it works anywhere in the Emacs window, as in gvim.
(dolist (area '(nil mode-line header-line vertical-line left-fringe
                    right-fringe left-margin right-margin))
  (global-set-key (if area (vector area 'C-wheel-up) [C-wheel-up])
                  #'hh-theme-font-larger)
  (global-set-key (if area (vector area 'C-wheel-down) [C-wheel-down])
                  #'hh-theme-font-smaller))

;; A font change keeps the frame's size in pixels and changes the number of
;; lines and columns instead (guioptions+=k in gvim_handmade.vim).
(setq frame-inhibit-implied-resize t)


;;; Colors

(defface hh-theme-statement-face '((t :foreground "#D8A0DF"))
  "if, else, for, while, return and the other statement words (gvim Statement).")

(defconst hh-theme-faces
  '((default :foreground "#DADADA" :background "#1E1E1E")
    (cursor :background "#DADADA")
    (fringe :background "#1E1E1E")
    (hl-line :background "#282828")
    (region :background "#264F78")
    (isearch :foreground unspecified :background "#515C6A")
    (lazy-highlight :foreground unspecified :background "#613315")
    (show-paren-match :foreground "#FFD700" :background "#3A3A3A")
    (mode-line :foreground "#DADADA" :background "#3C3C3C" :box nil)
    (mode-line-inactive :foreground "#858585" :background "#2D2D2D" :box nil)
    (vertical-border :foreground "#2D2D2D")
    (line-number :foreground "#858585" :background "#1E1E1E")
    (line-number-current-line :foreground "#D9D9D9" :background "#282828")
    (minibuffer-prompt :foreground "#569CD6")
    (error :foreground "#F44747")
    (warning :foreground "#D7BA7D")
    (font-lock-comment-face :foreground "#57A64A")
    (font-lock-doc-face :foreground "#57A64A")
    (font-lock-string-face :foreground "#D69D85")
    (font-lock-number-face :foreground "#B5CEA8")
    (font-lock-constant-face :foreground "#B8D7A3")
    (font-lock-keyword-face :foreground "#569CD6")
    (font-lock-type-face :foreground "#BDB76B")
    (font-lock-variable-name-face :foreground "#BDB76B")
    (font-lock-variable-use-face :foreground "#BDB76B")
    (font-lock-function-name-face :foreground "#FF8000")
    (font-lock-function-call-face :foreground "#FF8000")
    (font-lock-property-use-face :foreground "#DADADA")
    (font-lock-preprocessor-face :foreground "#9B9B9B")
    (font-lock-note-face :foreground "#57A64A"))
  "Faces and their gvim colors (the highlight lines of gvim_handmade.vim).
TODO, STUDY and IMPORTANT keep the red and yellow of .emacs, as in gvim.")

(defun hh-theme-set-colors ()
  "Give every frame the gvim colors."
  ;; .emacs's post-load-stuff sets the frame colors with set-foreground-color,
  ;; set-background-color and set-cursor-color. Set the frames first, because
  ;; a new background color can make Emacs recompute the faces.
  (dolist (frame (frame-list))
    (modify-frame-parameters frame '((foreground-color . "#DADADA")
                                     (background-color . "#1E1E1E")
                                     (cursor-color . "#DADADA"))))
  (dolist (spec hh-theme-faces)
    (when (facep (car spec))
      (apply #'set-face-attribute (car spec) nil (cdr spec)))))

(hh-theme-set-font hh-theme-font-size)
(hh-theme-set-colors)
;; post-load-stuff runs from window-setup-hook after the -l files; run again
;; after it.
(add-hook 'window-setup-hook #'hh-theme-set-colors 100)


;;; C and C++ highlighting

;; cc-mode colors keywords, types and declared names itself. The rules below
;; change those colors to gvim's and color what cc-mode leaves alone. The
;; word lists are the keywords of Vim 9.2's c.vim and cpp.vim, which differ a
;; little between C and C++ files.

(defconst hh-theme-statement-words
  '("asm" "break" "case" "continue" "default" "do" "else" "for" "goto" "if"
    "return" "switch" "while")
  "Purple in gvim (Statement, Label, Conditional, Repeat).")

(defconst hh-theme-cpp-statement-words
  '("catch" "co_await" "co_return" "co_yield" "const_cast" "delete"
    "dynamic_cast" "friend" "new" "noexcept" "private" "protected" "public"
    "reinterpret_cast" "requires" "static_cast" "this" "throw" "try" "using")
  "Also purple in C++ files: statements, access words, exceptions, casts.")

(defconst hh-theme-type-words
  '("DIR" "FILE" "_Alignas" "_Alignof" "_Atomic" "_Bool" "_Complex" "_Generic"
    "_Imaginary" "_Noreturn" "_Static_assert" "_Thread_local" "alignas"
    "alignof" "atomic_bool" "atomic_char" "atomic_char16_t" "atomic_char32_t"
    "atomic_int" "atomic_int_fast16_t" "atomic_int_fast32_t"
    "atomic_int_fast64_t" "atomic_int_fast8_t" "atomic_int_least16_t"
    "atomic_int_least32_t" "atomic_int_least64_t" "atomic_int_least8_t"
    "atomic_intmax_t" "atomic_intptr_t" "atomic_llong" "atomic_long"
    "atomic_ptrdiff_t" "atomic_schar" "atomic_short" "atomic_size_t"
    "atomic_uchar" "atomic_uint" "atomic_uint_fast16_t" "atomic_uint_fast32_t"
    "atomic_uint_fast64_t" "atomic_uint_fast8_t" "atomic_uint_least16_t"
    "atomic_uint_least32_t" "atomic_uint_least64_t" "atomic_uint_least8_t"
    "atomic_uintmax_t" "atomic_uintptr_t" "atomic_ullong" "atomic_ulong"
    "atomic_ushort" "atomic_wchar_t" "auto" "bool" "char" "char16_t"
    "char32_t" "char8_t" "clock_t" "complex" "const" "constexpr" "div_t"
    "double" "enum" "extern" "float" "fpos_t" "imaginary" "inline" "int"
    "int16_t" "int32_t" "int64_t" "int8_t" "int_fast16_t" "int_fast32_t"
    "int_fast64_t" "int_fast8_t" "int_least16_t" "int_least32_t"
    "int_least64_t" "int_least8_t" "intmax_t" "intptr_t" "jmp_buf" "ldiv_t"
    "long" "max_align_t" "mbstate_t" "nullptr_t" "off_t" "ptrdiff_t"
    "register" "short" "sig_atomic_t" "signed" "size_t" "sizeof" "ssize_t"
    "static" "static_assert" "struct" "thread_local" "time_t" "typedef"
    "u_int16_t" "u_int32_t" "u_int64_t" "u_int8_t" "uint16_t" "uint32_t"
    "uint64_t" "uint8_t" "uint_fast16_t" "uint_fast32_t" "uint_fast64_t"
    "uint_fast8_t" "uint_least16_t" "uint_least32_t" "uint_least64_t"
    "uint_least8_t" "uintmax_t" "uintptr_t" "union" "unsigned" "va_list"
    "void" "volatile" "wchar_t" "wctrans_t" "wctype_t" "wint_t")
  "Blue in gvim (Type, StorageClass, Structure, Typedef, Operator).")

(defconst hh-theme-c-type-words
  '("_BitInt" "_Decimal128" "_Decimal32" "_Decimal64" "noreturn" "restrict"
    "typeof" "typeof_unqual")
  "Also blue in C files only.")

(defconst hh-theme-cpp-type-words
  '("and" "and_eq" "bitand" "bitor" "class" "compl" "concept" "consteval"
    "constinit" "decltype" "explicit" "export" "false" "final" "mutable"
    "namespace" "not" "not_eq" "operator" "or" "or_eq" "override" "template"
    "true" "typeid" "typename" "virtual" "xor" "xor_eq")
  "Also blue in C++ files only (true and false as Boolean).")

(defconst hh-theme-constant-words
  '("BITINT_MAXWIDTH" "BUFSIZ" "CHAR_BIT" "CHAR_MAX" "CHAR_MIN"
    "CLOCKS_PER_SEC" "DBL_DIG" "DBL_EPSILON" "DBL_MANT_DIG" "DBL_MAX"
    "DBL_MAX_10_EXP" "DBL_MAX_EXP" "DBL_MIN" "DBL_MIN_10_EXP" "DBL_MIN_EXP"
    "E2BIG" "EACCES" "EADDRINUSE" "EADDRNOTAVAIL" "EAFNOSUPPORT" "EAGAIN"
    "EALREADY" "EBADF" "EBADMSG" "EBUSY" "ECANCELED" "ECHILD" "ECONNABORTED"
    "ECONNREFUSED" "ECONNRESET" "EDEADLK" "EDESTADDRREQ" "EDOM" "EDQUOT"
    "EEXIST" "EFAULT" "EFBIG" "EHOSTUNREACH" "EIDRM" "EILSEQ" "EINPROGRESS"
    "EINTR" "EINVAL" "EIO" "EISCONN" "EISDIR" "ELOOP" "EMFILE" "EMLINK"
    "EMSGSIZE" "EMULTIHOP" "ENAMETOOLONG" "ENETDOWN" "ENETRESET" "ENETUNREACH"
    "ENFILE" "ENOBUFS" "ENODATA" "ENODEV" "ENOENT" "ENOEXEC" "ENOLCK"
    "ENOLINK" "ENOMEM" "ENOMSG" "ENOPROTOOPT" "ENOSPC" "ENOSR" "ENOSTR"
    "ENOSYS" "ENOTBLK" "ENOTCONN" "ENOTDIR" "ENOTEMPTY" "ENOTRECOVERABLE"
    "ENOTSOCK" "ENOTSUP" "ENOTTY" "ENXIO" "EOF" "EOPNOTSUPP" "EOVERFLOW"
    "EOWNERDEAD" "EPERM" "EPIPE" "EPROTO" "EPROTONOSUPPORT" "EPROTOTYPE"
    "ERANGE" "EROFS" "ESPIPE" "ESRCH" "ESTALE" "ETIME" "ETIMEDOUT" "ETXTBSY"
    "EWOULDBLOCK" "EXDEV" "EXIT_FAILURE" "EXIT_SUCCESS" "FILENAME_MAX"
    "FLT_DIG" "FLT_EPSILON" "FLT_MANT_DIG" "FLT_MAX" "FLT_MAX_10_EXP"
    "FLT_MAX_EXP" "FLT_MIN" "FLT_MIN_10_EXP" "FLT_MIN_EXP" "FLT_RADIX"
    "FLT_ROUNDS" "FOPEN_MAX" "FP_FAST_FMA" "FP_FAST_FMAF" "FP_FAST_FMAL"
    "FP_ILOGB0" "FP_ILOGBNAN" "FP_INFINITE" "FP_NAN" "FP_NORMAL"
    "FP_SUBNORMAL" "FP_ZERO" "HUGE_VAL" "HUGE_VALF" "HUGE_VALL" "INFINITY"
    "INT16_MAX" "INT16_MIN" "INT32_MAX" "INT32_MIN" "INT64_MAX" "INT64_MIN"
    "INT8_MAX" "INT8_MIN" "INTMAX_MAX" "INTMAX_MIN" "INTPTR_MAX" "INTPTR_MIN"
    "INT_FAST16_MAX" "INT_FAST16_MIN" "INT_FAST32_MAX" "INT_FAST32_MIN"
    "INT_FAST64_MAX" "INT_FAST64_MIN" "INT_FAST8_MAX" "INT_FAST8_MIN"
    "INT_LEAST16_MAX" "INT_LEAST16_MIN" "INT_LEAST32_MAX" "INT_LEAST32_MIN"
    "INT_LEAST64_MAX" "INT_LEAST64_MIN" "INT_LEAST8_MAX" "INT_LEAST8_MIN"
    "INT_MAX" "INT_MIN" "LC_ALL" "LC_COLLATE" "LC_CTYPE" "LC_MONETARY"
    "LC_NUMERIC" "LC_TIME" "LDBL_DIG" "LDBL_EPSILON" "LDBL_MANT_DIG"
    "LDBL_MAX" "LDBL_MAX_10_EXP" "LDBL_MAX_EXP" "LDBL_MIN" "LDBL_MIN_10_EXP"
    "LDBL_MIN_EXP" "LLONG_MAX" "LLONG_MIN" "LONG_MAX" "LONG_MIN" "L_tmpnam"
    "MATH_ERREXCEPT" "MATH_ERRNO" "MB_CUR_MAX" "MB_LEN_MAX" "M_1_PI" "M_2_PI"
    "M_2_SQRTPI" "M_E" "M_LN10" "M_LN2" "M_LOG10E" "M_LOG2E" "M_PI" "M_PI_2"
    "M_PI_4" "M_SQRT1_2" "M_SQRT2" "NAN" "NDEBUG" "NULL" "PTRDIFF_MAX"
    "PTRDIFF_MIN" "RAND_MAX" "SCHAR_MAX" "SCHAR_MIN" "SEEK_CUR" "SEEK_END"
    "SEEK_SET" "SHRT_MAX" "SHRT_MIN" "SIGABRT" "SIGALRM" "SIGBUS" "SIGCHLD"
    "SIGCONT" "SIGFPE" "SIGHUP" "SIGILL" "SIGINFO" "SIGINT" "SIGIO" "SIGKILL"
    "SIGPIPE" "SIGPOLL" "SIGPROF" "SIGQUIT" "SIGSEGV" "SIGSTOP" "SIGSYS"
    "SIGTERM" "SIGTRAP" "SIGTSTP" "SIGTTIN" "SIGTTOU" "SIGURG" "SIGUSR1"
    "SIGUSR2" "SIGVTALRM" "SIGWINCH" "SIGXCPU" "SIGXFSZ" "SIG_ATOMIC_MAX"
    "SIG_ATOMIC_MIN" "SIG_DFL" "SIG_ERR" "SIG_IGN" "SINT_MAX" "SINT_MIN"
    "SIZE_MAX" "SLONG_MAX" "SLONG_MIN" "SSHRT_MAX" "SSHRT_MIN" "STDERR_FILENO"
    "STDIN_FILENO" "STDOUT_FILENO" "TMP_MAX" "UCHAR_MAX" "UINT16_MAX"
    "UINT32_MAX" "UINT64_MAX" "UINT8_MAX" "UINTMAX_MAX" "UINTPTR_MAX"
    "UINT_FAST16_MAX" "UINT_FAST32_MAX" "UINT_FAST64_MAX" "UINT_FAST8_MAX"
    "UINT_LEAST16_MAX" "UINT_LEAST32_MAX" "UINT_LEAST64_MAX" "UINT_LEAST8_MAX"
    "UINT_MAX" "ULLONG_MAX" "ULONG_MAX" "USHRT_MAX" "WCHAR_MAX" "WCHAR_MIN"
    "WEOF" "WINT_MAX" "WINT_MIN" "_IOFBF" "_IOLBF" "_IONBF" "__DATE__"
    "__FILE__" "__LINE__" "__STDC_ANALYZABLE__" "__STDC_EMBED_EMPTY__"
    "__STDC_EMBED_FOUND__" "__STDC_EMBED_NOT_FOUND__" "__STDC_HOSTED__"
    "__STDC_IEC_559_COMPLEX__" "__STDC_IEC_60559_BFP__"
    "__STDC_IEC_60559_COMPLEX__" "__STDC_IEC_60559_DFP__"
    "__STDC_IEC_60559_TYPES__" "__STDC_ISO_10646__" "__STDC_LIB_EXT1__"
    "__STDC_MB_MIGHT_NEQ_WC__" "__STDC_NO_ATOMICS__" "__STDC_NO_COMPLEX__"
    "__STDC_NO_THREADS__" "__STDC_NO_VLA__" "__STDC_UTF_16__"
    "__STDC_UTF_32__" "__STDC_VERSION__" "__STDC__" "__TIME__" "__VA_ARGS__"
    "__VA_OPT__" "__func__" "math_errhandling" "nullptr" "stderr" "stdin"
    "stdout")
  "Light green in gvim (Constant): NULL, EOF, the limits.h and float.h
names and the other constants of c.vim.")

(defconst hh-theme-c-constant-words
  '("false" "true")
  "Also light green in C files only.")

(defconst hh-theme-cpp-constant-words
  '("ATOMIC_BOOL_LOCK_FREE" "ATOMIC_CHAR16_T_LOCK_FREE"
    "ATOMIC_CHAR32_T_LOCK_FREE" "ATOMIC_CHAR_LOCK_FREE" "ATOMIC_FLAG_INIT"
    "ATOMIC_INT_LOCK_FREE" "ATOMIC_LLONG_LOCK_FREE" "ATOMIC_LONG_LOCK_FREE"
    "ATOMIC_POINTER_LOCK_FREE" "ATOMIC_SHORT_LOCK_FREE" "ATOMIC_VAR_INIT"
    "ATOMIC_WCHAR_T_LOCK_FREE" "__cplusplus")
  "Also light green in C++ files only.")

(defun hh-theme--word-table (&rest lists)
  (let ((table (make-hash-table :test #'equal)))
    (dolist (words lists)
      (dolist (word words)
        (puthash word t table)))
    table))

(defun hh-theme--language (statements types constants)
  (list :statement (regexp-opt statements 'symbols)
        :type (regexp-opt types 'symbols)
        :constant (regexp-opt constants 'symbols)
        :words (hh-theme--word-table statements types constants)))

(defconst hh-theme--c
  (hh-theme--language hh-theme-statement-words
                      (append hh-theme-type-words hh-theme-c-type-words)
                      (append hh-theme-constant-words hh-theme-c-constant-words))
  "Regexps and keyword table of C files.")

(defconst hh-theme--cpp
  (hh-theme--language (append hh-theme-statement-words hh-theme-cpp-statement-words)
                      (append hh-theme-type-words hh-theme-cpp-type-words)
                      (append hh-theme-constant-words hh-theme-cpp-constant-words))
  "Regexps and keyword table of C++ files.")

(defvar-local hh-theme--lang hh-theme--cpp
  "`hh-theme--c' or `hh-theme--cpp', chosen as gvim chooses c or cpp.")

(defun hh-theme--cpp-file-p ()
  "Non-nil when gvim would show this buffer as C++ rather than C."
  (let ((ext (and buffer-file-name
                  (downcase (or (file-name-extension buffer-file-name) "")))))
    (cond
     ((derived-mode-p 'c-mode) nil)
     ((equal ext "c") nil)
     ((equal ext "h")
      ;; Vim's dist/ft.vim: C++ when one of the first 99 lines starts with
      ;; class, namespace, template or using; otherwise C.
      (save-excursion
        (save-restriction
          (widen)
          (goto-char (point-min))
          (re-search-forward "^[ \t]*\\(?:class\\|namespace\\|template\\|using\\)\\_>"
                             (line-end-position 99) t))))
     (t t))))

(defconst hh-theme--name-re "\\_<[[:alpha:]_][[:alnum:]_]*\\_>")
(defconst hh-theme--number-re
  (concat "\\_<\\(?:0[xX][[:xdigit:]']+\\|0[bB][01']+"
          "\\|[0-9][0-9']*\\(?:\\.[0-9']*\\)?\\(?:[eE][-+]?[0-9]+\\)?\\)"
          "[uUlLfFzZ]*\\_>"))
(defconst hh-theme--dot-number-re
  "\\(?:^\\|[^[:alnum:]_.]\\)\\(\\.[0-9]+\\(?:[eE][-+]?[0-9]+\\)?[fFlL]?\\)\\_>")
;; A name before ( , with template arguments allowed in between (gvim
;; HHFunction), and the same right after . or -> (gvim HHMember).
(defconst hh-theme--call-re
  "\\(\\_<[[:alpha:]_][[:alnum:]_]*\\_>\\)\\(?:<[^<>()\n]*>\\)?[ \t]*(")
(defconst hh-theme--member-call-re
  "\\(?:\\.\\|->\\)\\(\\_<[[:alpha:]_][[:alnum:]_]*\\_>\\)\\(?:<[^<>()\n]*>\\)?[ \t]*(")
(defconst hh-theme--conditional-re
  "^[ \t]*#[ \t]*\\(if\\|ifdef\\|ifndef\\|elif\\|else\\|endif\\)\\_>")

(defun hh-theme--face-at (pos)
  "The first face of the text at POS, or nil."
  (let ((face (get-text-property pos 'face)))
    (if (consp face) (car face) face)))

(defun hh-theme--search (regexp group faces limit)
  "Search REGEXP before LIMIT for a match whose GROUP has one of FACES.
nil in FACES stands for text that has no face yet."
  (let ((found nil))
    (while (and (not found) (re-search-forward regexp limit t))
      (when (memq (hh-theme--face-at (match-beginning group)) faces)
        (setq found t)))
    found))

(defun hh-theme--not-keywords (limit)
  "Words cc-mode shows as keywords that gvim does not, e.g. this in C."
  (let ((found nil)
        (words (plist-get hh-theme--lang :words)))
    (while (and (not found) (re-search-forward hh-theme--name-re limit t))
      (when (and (eq (hh-theme--face-at (match-beginning 0)) 'font-lock-keyword-face)
                 (not (gethash (match-string-no-properties 0) words)))
        (setq found t)))
    found))

(defun hh-theme--not-constants (limit)
  "Names cc-mode shows as constants that gvim does not: std in std::cout,
Scores in Scores::Add and the like."
  (let ((found nil)
        (words (plist-get hh-theme--lang :words)))
    (while (and (not found) (re-search-forward hh-theme--name-re limit t))
      (when (and (eq (hh-theme--face-at (match-beginning 0)) 'font-lock-constant-face)
                 (not (gethash (match-string-no-properties 0) words)))
        (setq found t)))
    found))

(defun hh-theme--statements (limit)
  (hh-theme--search (plist-get hh-theme--lang :statement) 0
                    '(nil font-lock-keyword-face) limit))

(defun hh-theme--types (limit)
  (hh-theme--search (plist-get hh-theme--lang :type) 0
                    '(nil font-lock-keyword-face font-lock-type-face
                          font-lock-constant-face)
                    limit))

(defun hh-theme--constants (limit)
  (hh-theme--search (plist-get hh-theme--lang :constant) 0
                    '(nil font-lock-constant-face font-lock-variable-name-face
                          font-lock-keyword-face)
                    limit))

(defun hh-theme--member-calls (limit)
  (hh-theme--search hh-theme--member-call-re 1
                    '(nil font-lock-type-face font-lock-variable-name-face
                          font-lock-function-name-face)
                    limit))

(defun hh-theme--calls (limit)
  (hh-theme--search hh-theme--call-re 1
                    '(nil font-lock-type-face font-lock-variable-name-face)
                    limit))

(defun hh-theme--operator-symbols (limit)
  "The * of operator*: cc-mode colors it as a function name, gvim does not."
  (hh-theme--search "\\_<operator[ \t]*\\([^[:alnum:]_ \t\n(]+\\)" 1
                    '(font-lock-function-name-face) limit))

(defun hh-theme--paren-depth (pos)
  "Number of ( before POS on its line that are not closed yet."
  (let ((depth 0))
    (save-excursion
      (goto-char (line-beginning-position))
      (while (< (point) pos)
        (pcase (char-after)
          (?\( (setq depth (1+ depth)))
          (?\) (setq depth (max 0 (1- depth)))))
        (forward-char 1)))
    depth))

(defun hh-theme--conditional-names (limit)
  "Names of an #if, #ifdef, #ifndef or #elif line outside parentheses.
gvim shows them gray, and the names inside parentheses khaki."
  (let ((found nil))
    (while (and (not found) (re-search-forward hh-theme--name-re limit t))
      (when (and (memq (hh-theme--face-at (match-beginning 0))
                       '(nil font-lock-variable-name-face))
                 (= 0 (hh-theme--paren-depth (match-beginning 0))))
        (setq found t)))
    found))

(defun hh-theme--names (limit)
  "Names cc-mode left without a color, except a string prefix as in L\"\"."
  (let ((found nil))
    (while (and (not found) (re-search-forward hh-theme--name-re limit t))
      (when (and (null (hh-theme--face-at (match-beginning 0)))
                 (not (memq (char-after) '(?\" ?\'))))
        (setq found t)))
    found))

(defun hh-theme--commented-names (limit)
  "A word after \"concept\" in a comment: cc-mode colors it as a C++20 name."
  (let ((found nil))
    (while (and (not found)
                (re-search-forward "\\_<concept[ \t\n]+\\(\\_<[[:alpha:]_][[:alnum:]_]*\\_>\\)"
                                   limit t))
      (when (and (memq (hh-theme--face-at (match-beginning 0))
                       '(font-lock-comment-face font-lock-doc-face))
                 (not (memq (hh-theme--face-at (match-beginning 1))
                            '(font-lock-comment-face font-lock-doc-face))))
        (setq found t)))
    found))

;; #if 0 blocks and the #else part of #if 1 blocks, as Vim's c.vim shows them.
(defvar-local hh-theme--dead-cache nil
  "(TICK . REGIONS) of the last scan of this buffer.")

(defun hh-theme--scan-dead-code ()
  "Return the lines after #if 0 and after the #else of #if 1 as (BEG . END)."
  (save-excursion
    (save-restriction
      (widen)
      (save-match-data
        (goto-char (point-min))
        (let ((stack nil) (start nil) (depth 0) (regions nil))
          (while (re-search-forward hh-theme--conditional-re nil t)
            (let ((word (match-string-no-properties 1))
                  (bol (match-beginning 0)))
              (cond
               (start
                ;; Inside a dead part: skip nested conditionals.
                (cond
                 ((member word '("if" "ifdef" "ifndef")) (setq depth (1+ depth)))
                 ((> depth 0) (when (equal word "endif") (setq depth (1- depth))))
                 (t
                  (when (< start bol)
                    (push (cons start bol) regions))
                  (setq start nil)
                  (if (equal word "endif")
                      (pop stack)
                    (when stack (setcar stack 'other))))))
               ((equal word "if")
                (cond
                 ((looking-at "[ \t]+0+[ \t]*\\(?:$\\|//\\|/\\*\\|&\\)")
                  (push 'other stack)
                  (setq start (line-beginning-position 2) depth 0))
                 ((looking-at "[ \t]+0*[1-9][0-9]*[ \t]*\\(?:$\\|//\\|/\\*\\||\\)")
                  (push 'one stack))
                 (t (push 'other stack))))
               ((member word '("ifdef" "ifndef")) (push 'other stack))
               ((member word '("else" "elif"))
                (when (eq (car stack) 'one)
                  (setcar stack 'other)
                  (setq start (line-beginning-position 2) depth 0)))
               (t (pop stack)))))
          (when (and start (< start (point-max)))
            (push (cons start (point-max)) regions))
          (nreverse regions))))))

(defun hh-theme--dead-regions ()
  (let ((tick (buffer-chars-modified-tick)))
    (unless (eql (car hh-theme--dead-cache) tick)
      (setq hh-theme--dead-cache (cons tick (hh-theme--scan-dead-code))))
    (cdr hh-theme--dead-cache)))

(defun hh-theme--dead-code (limit)
  "Match the part of the next dead region between point and LIMIT."
  (let ((regions (hh-theme--dead-regions))
        (pos (point))
        (found nil))
    (while (and regions (not found) (< (caar regions) limit))
      (if (> (cdar regions) pos)
          (setq found (car regions))
        (setq regions (cdr regions))))
    (when found
      (let ((beg (max (car found) pos))
            (end (min (cdr found) limit)))
        (set-match-data (list beg end))
        (goto-char end)
        t))))

;; A changed #if/#else/#endif line changes the colors of the lines after it.
(defvar-local hh-theme--directive-touched nil)

(defun hh-theme--directive-in (beg end)
  (save-excursion
    (save-match-data
      (let ((stop (progn (goto-char end) (line-end-position))))
        (goto-char beg)
        (beginning-of-line)
        (re-search-forward "^[ \t]*#[ \t]*\\(?:if\\|el\\|endif\\)" stop t)))))

(defun hh-theme--before-change (beg end)
  (setq hh-theme--directive-touched (hh-theme--directive-in beg end)))

(defun hh-theme--after-change (beg end _length)
  (when (or hh-theme--directive-touched (hh-theme--directive-in beg end))
    (setq hh-theme--directive-touched nil)
    (font-lock-flush (save-excursion (goto-char beg) (line-beginning-position))
                     (point-max))))

(defun hh-theme--c-setup ()
  (setq hh-theme--lang (if (hh-theme--cpp-file-p) hh-theme--cpp hh-theme--c))
  (add-hook 'before-change-functions #'hh-theme--before-change nil t)
  (add-hook 'after-change-functions #'hh-theme--after-change nil t))

(add-hook 'c-mode-common-hook #'hh-theme--c-setup)

(defconst hh-theme--keywords
  (append
   `((,hh-theme--number-re 0 'font-lock-number-face)
     (,hh-theme--dot-number-re 1 'font-lock-number-face)
     ;; L"", u8"", R"()": gvim colors the prefix as part of the string.
     ("\\_<\\(L\\|u8\\|u\\|U\\|R\\|LR\\|u8R\\|uR\\|UR\\)[\"']" 1 'font-lock-string-face)
     ;; cc-mode shows the text of #error and #warning as a string; gvim colors
     ;; its words as code on a gray line.
     ("^[ \t]*#[ \t]*\\(?:error\\|warning\\)\\_>[ \t]*\\(.+\\)" 1 nil t)
     (hh-theme--commented-names 1 'font-lock-comment-face t)
     (hh-theme--not-keywords 0 nil t)
     (hh-theme--not-constants 0 nil t)
     ("^[ \t]*#[ \t]*\\(?:if\\|ifdef\\|ifndef\\|elif\\)\\_>"
      (hh-theme--conditional-names (line-end-position) nil
                                   (0 'font-lock-preprocessor-face t)))
     (hh-theme--statements 0 'hh-theme-statement-face t)
     (hh-theme--types 0 'font-lock-keyword-face t)
     (hh-theme--constants 0 'font-lock-constant-face t)
     (hh-theme--member-calls 1 'font-lock-property-use-face t)
     (hh-theme--calls 1 'font-lock-function-call-face t)
     (hh-theme--operator-symbols 1 'default t)
     (hh-theme--names 0 'font-lock-variable-use-face)
     ;; gvim shows the word define of #define as a name, and likewise undef,
     ;; pragma, line, warning and error.
     ("^[ \t]*#[ \t]*\\(define\\|undef\\|pragma\\|line\\|warning\\|warn\\|error\\)\\_>"
      1 'font-lock-variable-use-face t)
     ;; The number of #if 0 and #if 1 is gray, as the rest of that line.
     ("^[ \t]*#[ \t]*if[ \t]+\\([0-9]+\\)[ \t]*\\(?:$\\|//\\|/\\*\\)"
      1 'font-lock-preprocessor-face t)
     ;; The rest of a preprocessor line (including \ continuation lines) is
     ;; gray, under the colors given above.
     (,(concat "^[ \t]*#[ \t]*\\(?:if\\|ifdef\\|ifndef\\|elif\\|define\\|undef"
               "\\|pragma\\|line\\|warning\\|warn\\|error\\)\\_>"
               ".*\\(?:\\\\\n.*\\)*")
      0 'font-lock-preprocessor-face append)
     (hh-theme--dead-code 0 'font-lock-comment-face t))
   ;; .emacs's TODO, NOTE, STUDY and IMPORTANT marks, again over #if 0 blocks
   ;; (only those the day's .emacs has; STUDY and IMPORTANT come with day 015).
   (delq nil
         (mapcar (lambda (mark)
                   (when (facep (cdr mark))
                     (list (concat "\\<\\(" (car mark) "\\)") 1
                           (list 'quote (cdr mark)) t)))
                 '(("TODO" . font-lock-fixme-face)
                   ("STUDY" . font-lock-study-face)
                   ("IMPORTANT" . font-lock-important-face)
                   ("NOTE" . font-lock-note-face)))))
  "Font-lock rules added after cc-mode's own, in this order.")

(dolist (mode '(c-mode c++-mode))
  (font-lock-add-keywords mode hh-theme--keywords 'append))

;; C and C++ buffers opened before this file was loaded.
(dolist (buffer (buffer-list))
  (with-current-buffer buffer
    (when (derived-mode-p 'c-mode 'c++-mode)
      (hh-theme--c-setup)
      (font-lock-add-keywords nil hh-theme--keywords 'append)
      (font-lock-flush))))

;;; emacs_theme.el ends here
