;;; emacs_edit.el --- gvim's C/C++ editing helpers for Casey's .emacs  -*- lexical-binding: t; -*-

;; misc\emacs.bat loads this file after .emacs and emacs_theme.el:
;;   runemacs -q -l misc\.emacs -l misc\emacs_theme.el -l misc\emacs_edit.el
;; In the C/C++ study folders and 03.c_project, emacs_c_study.el and
;; emacs_project.el load their own copies of both files at their end.
;; It adds the C/C++ editing helpers of gvim_handmade.vim with
;; built-in Emacs features only, no packages. .emacs is not changed, and keys
;; that .emacs or the Emacs guides use keep their meaning: where a key below
;; has nothing to do, it runs what it did before.
;;
;; In C and C++ buffers (hh-edit-mode):
;;   ( [ { " '   insert the closing character too, unless the next character
;;               is text (not space or ) ] } , ;), or inside a comment or
;;               string; a quote is not paired after a letter, digit, _ or \.
;;   ) ] } " '   step over the same character right after the cursor.
;;   DEL         between an empty pair, delete both.
;;   RET         between { and }, put } two lines down and the cursor indented
;;               in the middle line.
;;   TAB         step over a ) ] } or closing quote right after the cursor
;;               (Tabout); else complete the word before the cursor as .emacs
;;               does (dabbrev-expand); else insert spaces to the next
;;               multiple of 4.
;;   M-e         after if, else, for, while, switch, case, struct or inc,
;;               insert that block in the project's style; else end of
;;               statement as before.
;;   C-;         comment or uncomment the line with // (C-u C-;: the lines
;;               between point and mark).
;;   F7          find the word under the cursor in the code folder (.cpp,
;;               .c, .h; the project folder in 03.c_project); M-n / M-N go
;;               through the results.
;;   C-c @ ...   fold blocks (hideshow): C-c @ C-c toggles one block,
;;               C-c @ C-M-h folds all, C-c @ C-M-s unfolds all.
;; In all buffers:
;;   M-?         complete the word before the cursor (also inside brackets,
;;               where TAB steps out).
;;   M-D         duplicate the line below and move to it.
;;   M-S-<up> / M-S-<down>  move the line up/down (reindented in C/C++).
;;   M-RET       open a new indented line below, wherever the cursor is.
;;   Line numbers in program and text files (M-x display-line-numbers-mode
;;   turns them off for a buffer).
;; Running the game, as gvim's F5 and S-F5 (only keys that are still free
;; when this file is loaded: .emacs has no run key, while emacs_c_study.el and
;; emacs_project.el bind their own F5, C-F5 and S-F5 before loading it):
;;   F5          run the day's build\win32_handmade.exe, in the day folder
;;               from day 460 (the game looks for data\*.hha), else in data\
;;               when data\test exists, else in build\. Not again while a
;;               win32_handmade.exe is running.
;;   C-F5        build with M-m's command, then run the game if the build
;;               succeeded. A game that is already running is not started
;;               again; from day 021 it reloads the new handmade.dll.
;;   S-F5        stop every win32_handmade.exe.

(require 'cc-mode)


;;; Helpers

(defconst hh-edit-pairs '((?\( . ?\)) (?\[ . ?\]) (?\{ . ?\}) (?\" . ?\") (?\' . ?\'))
  "Opening characters and their closing characters.")

(defvar hh-edit-mode)

(defun hh-edit--fallback (&optional keys)
  "Run what KEYS would run without `hh-edit-mode'.
KEYS defaults to the character typed for this command."
  (let* ((keys (or keys (vector last-command-event)))
         (command (let ((hh-edit-mode nil))
                    (key-binding keys t))))
    (when (and command (commandp command))
      (setq this-command command)
      (call-interactively command))))

(defun hh-edit--in-comment-or-string ()
  (nth 8 (syntax-ppss)))

(defun hh-edit--word-char-p (char)
  (and char (memq (char-syntax char) '(?w ?_))))

(defun hh-edit--can-pair ()
  "Non-nil when a closing character would not split other text."
  (let ((next (char-after)))
    (or (null next)
        (memq next '(?\s ?\t ?\n ?\r ?\f ?\) ?\] ?\} ?, ?\;)))))

(defun hh-edit--at-closer-p ()
  "Non-nil before ) ] } or before the quote that ends the current string."
  (let ((next (char-after)))
    (and next
         (or (memq next '(?\) ?\] ?\}))
             (and (memq next '(?\" ?\'))
                  (eq (nth 3 (syntax-ppss)) next))))))


;;; Pairs, Tabout, Enter

(defun hh-edit-open ()
  "Insert ( [ or { and, where it fits, the closing character after it."
  (interactive)
  (let ((close (cdr (assq last-command-event hh-edit-pairs))))
    (if (or (hh-edit--in-comment-or-string) (not (hh-edit--can-pair)))
        (hh-edit--fallback)
      (hh-edit--fallback)
      (save-excursion (insert close)))))

(defun hh-edit-close ()
  "Step over ) ] or } when it is the next character, else insert it."
  (interactive)
  (if (eq (char-after) last-command-event)
      (forward-char 1)
    (hh-edit--fallback)))

(defun hh-edit-quote ()
  "Step over a closing quote, or insert a quote pair where it fits."
  (interactive)
  (let ((char last-command-event))
    (cond
     ((and (eq (char-after) char) (eq (nth 3 (syntax-ppss)) char))
      (forward-char 1))
     ((or (hh-edit--word-char-p (char-before))
          (eq (char-before) ?\\)
          (hh-edit--in-comment-or-string)
          (not (hh-edit--can-pair)))
      (hh-edit--fallback))
     (t
      (hh-edit--fallback)
      (save-excursion (insert char))))))

(defun hh-edit-backspace ()
  "Delete both characters of an empty pair, else delete as before."
  (interactive)
  (let ((pair (assq (char-before) hh-edit-pairs)))
    (if (and pair (eq (char-after) (cdr pair)))
        (progn (delete-char -1) (delete-char 1))
      (hh-edit--fallback (kbd "DEL")))))

(defun hh-edit-return ()
  "Between { and }: three lines with the cursor indented in the middle."
  (interactive)
  (if (and (eq (char-before) ?\{) (eq (char-after) ?\}))
      (progn
        (hh-edit--fallback (kbd "RET"))
        (save-excursion (newline-and-indent))
        (indent-according-to-mode))
    (hh-edit--fallback (kbd "RET"))))

(defun hh-edit-tab ()
  "Tabout, else complete the word before the cursor, else spaces."
  (interactive)
  (cond
   ((hh-edit--at-closer-p)
    (forward-char 1))
   ((hh-edit--word-char-p (char-before))
    (hh-edit--fallback (kbd "TAB")))
   (t
    (insert (make-string (- 4 (% (current-column) 4)) ?\s)))))

(defun hh-edit-complete ()
  "Complete the word before the cursor (dabbrev-expand), anywhere."
  (interactive)
  (setq this-command 'dabbrev-expand)
  (call-interactively #'dabbrev-expand))


;;; Snippets

(defconst hh-edit-snippets
  '(("if" "if(@)" "{" "    " "}")
    ("else" "else" "{" "    @" "}")
    ("for" "for(int Index = 0; Index < @; ++Index)" "{" "    " "}")
    ("while" "while(@)" "{" "    " "}")
    ("switch" "switch(@)" "{" "    case :" "    {" "    } break;" ""
     "    default:" "    {" "    } break;" "}")
    ("case" "case @:" "{" "    " "} break;")
    ("struct" "struct @" "{" "    " "};")
    ("inc" "#include <@>"))
  "The snippets of gvim_handmade.vim. @ marks the cursor; lines after the
first get the indentation of the current line.")

(defun hh-edit-snippet ()
  "Expand the snippet named by the word before the cursor, else `M-e' as before."
  (interactive)
  (let* ((end (point))
         (start (save-excursion (skip-syntax-backward "w_" (line-beginning-position))
                                (point)))
         (body (cdr (assoc (buffer-substring-no-properties start end) hh-edit-snippets))))
    (if (not body)
        (hh-edit--fallback (kbd "M-e"))
      (let ((indent (save-excursion
                      (back-to-indentation)
                      (buffer-substring-no-properties (line-beginning-position) (point))))
            (beg start))
        (delete-region start end)
        (goto-char beg)
        (insert (mapconcat #'identity
                           (cons (car body)
                                 (mapcar (lambda (line) (concat indent line)) (cdr body)))
                           "\n"))
        (goto-char beg)
        (search-forward "@")
        (delete-char -1)))))


;;; Comments

(defun hh-edit--toggle-lines (first last)
  "Comment the lines FIRST to LAST with // or, if all are comments, uncomment."
  (save-excursion
    (let ((lines nil) (column nil) (all-comments t))
      (goto-char (point-min))
      (forward-line (1- first))
      (dotimes (_ (1+ (- last first)))
        (unless (looking-at-p "[ \t]*$")
          (let ((indent (save-excursion (skip-chars-forward " \t") (current-column))))
            (setq column (if column (min column indent) indent)))
          (unless (looking-at-p "[ \t]*//")
            (setq all-comments nil)))
        (push (point) lines)
        (forward-line 1))
      (when column
        (dolist (start lines)
          (goto-char start)
          (cond
           ((looking-at-p "[ \t]*$"))
           (all-comments
            (when (looking-at "\\([ \t]*\\)// ?")
              (replace-match "\\1")))
           (t
            (move-to-column column)
            (insert "// "))))))))

(defun hh-edit-toggle-comment (arg)
  "Comment or uncomment this line; with C-u, the lines between point and mark."
  (interactive "P")
  (let* ((line (line-number-at-pos))
         (column (current-column))
         (length (- (line-end-position) (line-beginning-position)))
         (other (if (and arg (mark t)) (line-number-at-pos (mark t)) line)))
    (hh-edit--toggle-lines (min line other) (max line other))
    (goto-char (point-min))
    (forward-line (1- line))
    (move-to-column (max 0 (+ column (- (- (line-end-position) (line-beginning-position))
                                         length))))))


;;; Finding a word

(defvar hh-edit-search-folder-function nil
  "Function that returns the folder F7 searches, or nil for the default: the
nearest folder above the file that has build.bat (a day's code folder, the
study folder), else the file's folder. emacs_project.el sets it to the
current project's folder.")

(defun hh-edit--code-folder ()
  (let ((dir (and buffer-file-name (file-name-directory buffer-file-name))))
    (or (and hh-edit-search-folder-function
             (funcall hh-edit-search-folder-function))
        (and dir (locate-dominating-file dir "build.bat"))
        dir
        default-directory)))

(defun hh-edit-find-word ()
  "Find the word under the cursor in the .cpp, .c and .h files of the code folder."
  (interactive)
  (let ((word (thing-at-point 'symbol t)))
    (if (not word)
        (message "No word under the cursor")
      ;; findstr prints the matching lines as they are in the files: UTF-8 in
      ;; the study and project workspaces (ASCII in the Handmade Hero days).
      ;; Emacs would read the output in the Windows code page (949 on Korean
      ;; Windows) and show Korean text garbled, so it is read as UTF-8 here.
      (let ((default-directory (hh-edit--code-folder))
            (coding-system-for-read 'utf-8-dos))
        (compilation-start
         (format "findstr -s -n -r -c:\"\\<%s\\>\" *.cpp *.c *.h" word)
         'grep-mode)))))


;;; Lines (all buffers)

(defun hh-edit-duplicate-line ()
  "Copy this line below and move to the copy, keeping the column."
  (interactive)
  (let ((column (current-column))
        (text (buffer-substring (line-beginning-position) (line-end-position))))
    (end-of-line)
    (insert "\n" text)
    (move-to-column column)))

(defun hh-edit--reindent-p ()
  (derived-mode-p 'c-mode 'c++-mode))

(defun hh-edit-move-line (direction)
  "Move this line one line up (DIRECTION -1) or down (1)."
  (let ((offset (- (current-column)
                   (save-excursion (back-to-indentation) (current-column)))))
    (cond
     ((and (< direction 0) (= (line-beginning-position) (point-min)))
      (message "Beginning of buffer"))
     ((and (> direction 0) (save-excursion (end-of-line) (>= (point) (point-max))))
      (message "End of buffer"))
     (t
      ;; Swap the two lines' text; the newlines stay where they are.
      (let* ((beg (line-beginning-position))
             (end (line-end-position))
             (line (buffer-substring beg end))
             (other-beg (if (< direction 0) (line-beginning-position 0) (1+ end)))
             (other-end (if (< direction 0)
                            (1- beg)
                          (save-excursion (goto-char other-beg) (line-end-position))))
             (other (buffer-substring other-beg other-end)))
        (if (< direction 0)
            (progn
              (delete-region other-beg end)
              (goto-char other-beg)
              (insert line "\n" other)
              (goto-char other-beg))
          (delete-region beg other-end)
          (goto-char beg)
          (insert other "\n" line)
          (goto-char (+ beg (length other) 1))))
      (when (hh-edit--reindent-p)
        (indent-according-to-mode))
      (back-to-indentation)
      (move-to-column (+ (current-column) (max 0 offset)))))))

(defun hh-edit-move-line-up ()
  "Move this line up."
  (interactive)
  (hh-edit-move-line -1))

(defun hh-edit-move-line-down ()
  "Move this line down."
  (interactive)
  (hh-edit-move-line 1))

(defun hh-edit-open-line-below ()
  "Open an indented line below this one, wherever the cursor is."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(global-set-key (kbd "M-?") #'hh-edit-complete)
(global-set-key (kbd "M-D") #'hh-edit-duplicate-line)
(global-set-key (kbd "M-S-<up>") #'hh-edit-move-line-up)
(global-set-key (kbd "M-S-<down>") #'hh-edit-move-line-down)
(global-set-key (kbd "M-<return>") #'hh-edit-open-line-below)

;; Line numbers, as gvim's set number (faces in emacs_theme.el).
(setq-default display-line-numbers-width 3)
(setq display-line-numbers-grow-only t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)


;;; Running the game (Handmade Hero days)

(defun hh-edit--day-folder (&optional dir)
  "The Handmade Hero day folder at or above DIR (default `default-directory'):
the nearest folder that has code\\build.bat, or nil."
  (locate-dominating-file (or dir default-directory) "code/build.bat"))

(defun hh-edit--win (file)
  "FILE as an absolute Windows path with backslashes."
  (subst-char-in-string ?/ ?\\ (expand-file-name file)))

(defun hh-edit--game-running-p ()
  "Whether a win32_handmade.exe of any day is running."
  (seq-some (lambda (pid)
              (string-equal-ignore-case
               (or (cdr (assq 'comm (process-attributes pid))) "")
               "win32_handmade.exe"))
            (list-system-processes)))

(defun hh-edit--run-folder (day)
  "The folder DAY's game runs in, as gvim's s:RunDir: the day folder itself
when code\\win32_handmade.cpp names data\\\\*.hha (from day 460 the game looks
for data\\, art\\ and sound\\ below the current folder), else data\\ when
data\\test exists (the art is read from the current folder from day 036),
else build\\ (day 021 loads handmade.dll from the current folder)."
  (let ((src (expand-file-name "code/win32_handmade.cpp" day))
        (data (expand-file-name "data/" day)))
    (cond ((and (file-readable-p src)
                (with-temp-buffer
                  (insert-file-contents src)
                  (search-forward "data\\\\*.hha" nil t)))
           (file-name-as-directory (expand-file-name day)))
          ((file-directory-p (expand-file-name "test" data)) data)
          (t (expand-file-name "build/" day)))))

(defun hh-edit--start-game (day after-build)
  "Start DAY's build\\win32_handmade.exe where gvim's F5 starts it (see
`hh-edit--run-folder'). AFTER-BUILD only changes the message. Never signals,
because C-F5 calls it from `compilation-finish-functions'."
  (let* ((exe (expand-file-name "build/win32_handmade.exe" day))
         (dir (hh-edit--run-folder day)))
    (cond ((not (file-exists-p exe))
           (message "Nothing to run: %s does not exist. Build first (M-m)."
                    (hh-edit--win exe)))
          ((hh-edit--game-running-p)
           (message (if after-build
                        "win32_handmade.exe is running, so it was not started again (from day 021 it reloads the new handmade.dll)"
                      "win32_handmade.exe is already running (S-F5 stops it)")))
          (t
           ;; ShellExecute starts the program in the current buffer's
           ;; default-directory, and Emacs does not wait for it.
           (let ((default-directory dir))
             (w32-shell-execute "open" (hh-edit--win exe)))
           (message "Running %s in %s" (hh-edit--win exe)
                    (file-name-nondirectory (directory-file-name dir)))))))

(defun hh-edit-run ()
  "Run this day's game, as gvim's F5: in the day folder from day 460, else in
data\\ when data\\test exists, else in build\\ (F5)."
  (interactive)
  (let ((day (hh-edit--day-folder)))
    (unless day
      (user-error "Not in a Handmade Hero day folder (no code\\build.bat above %s)"
                  (hh-edit--win default-directory)))
    (hh-edit--start-game day nil)))

(defun hh-edit-stop ()
  "Stop every win32_handmade.exe, as gvim's S-F5 (S-F5)."
  (interactive)
  (if (not (hh-edit--game-running-p))
      (message "win32_handmade.exe is not running")
    (w32-shell-execute "open" "taskkill.exe" "/IM win32_handmade.exe /F" 0)
    (message "Stopping win32_handmade.exe")))

(defvar hh-edit--run-after-build nil
  "The compilation process whose success C-F5 is waiting for.")

(defun hh-edit-build-and-run ()
  "Build with the command on M-m (.emacs's make-without-asking), then run
the game of the day that was built if the build succeeded (C-F5)."
  (interactive)
  (let ((build (lookup-key global-map "\em")))
    (unless (commandp build)
      (user-error "M-m runs no build command"))
    (setq hh-edit--run-after-build nil)
    (call-interactively build)
    (let ((buffer (get-buffer "*compilation*")))
      (setq hh-edit--run-after-build (and buffer (get-buffer-process buffer))))))

;; The finish functions get the buffer, not the process, so C-F5's process
;; must be this buffer's and must have ended: when C-F5 interrupts a build
;; that is still running, that build's end does not count as C-F5's.
(defun hh-edit--after-build (buffer status)
  (when (let ((process hh-edit--run-after-build))
          (and (processp process)
               (eq (process-buffer process) buffer)
               (not (process-live-p process))))
    (setq hh-edit--run-after-build nil)
    (if (not (string-prefix-p "finished" status))
        (message "The build failed, so the game was not run.")
      ;; The day that was built: .emacs compiles in the folder with build.bat.
      (let ((day (with-current-buffer buffer (hh-edit--day-folder))))
        (if day
            (hh-edit--start-game day t)
          (message "The build finished outside a Handmade Hero day folder, so nothing was run."))))))

(add-hook 'compilation-finish-functions #'hh-edit--after-build)

(dolist (binding '(([f5] . hh-edit-run)
                   ([C-f5] . hh-edit-build-and-run)
                   ([S-f5] . hh-edit-stop)))
  (unless (lookup-key global-map (car binding))
    (define-key global-map (car binding) (cdr binding))))


;;; The C/C++ minor mode

(defvar hh-edit-mode-map
  (let ((map (make-sparse-keymap)))
    (dolist (key '("(" "[" "{"))
      (define-key map key #'hh-edit-open))
    (dolist (key '(")" "]" "}"))
      (define-key map key #'hh-edit-close))
    (define-key map "\"" #'hh-edit-quote)
    (define-key map "'" #'hh-edit-quote)
    (define-key map (kbd "DEL") #'hh-edit-backspace)
    (define-key map (kbd "RET") #'hh-edit-return)
    (define-key map (kbd "TAB") #'hh-edit-tab)
    (define-key map (kbd "M-e") #'hh-edit-snippet)
    (define-key map (kbd "C-;") #'hh-edit-toggle-comment)
    (define-key map (kbd "<f7>") #'hh-edit-find-word)
    map)
  "Keys of `hh-edit-mode'. A minor mode map wins over c++-mode-map, which
.emacs rebinds every time a C/C++ buffer opens.")

(define-minor-mode hh-edit-mode
  "gvim's C/C++ editing keys (emacs_edit.el)."
  :lighter " gv"
  :keymap hh-edit-mode-map)

(defun hh-edit--c-setup ()
  (hh-edit-mode 1)
  (hs-minor-mode 1))

;; After .emacs's casey-big-fun-c-hook.
(add-hook 'c-mode-common-hook #'hh-edit--c-setup 90)

;; C and C++ buffers opened before this file was loaded.
(dolist (buffer (buffer-list))
  (with-current-buffer buffer
    (when (derived-mode-p 'c-mode 'c++-mode)
      (hh-edit--c-setup)
      (display-line-numbers-mode 1))))

;;; emacs_edit.el ends here
