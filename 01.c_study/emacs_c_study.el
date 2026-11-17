;; -*- lexical-binding: t; -*-
;; C/C++ study settings for GNU Emacs. emacs.bat in this folder starts Emacs with
;;   runemacs.exe -q -l emacs_c_study.el [file]
;;
;; It first loads handmade.emacs, a copy of the Handmade Hero .emacs (Casey's
;; settings, the same file as misc\.emacs in day_062 and later), so keys, colors
;; and behavior are those of the Handmade Hero day folders. Then it points
;; building, running and debugging at single study programs, with the same keys
;; as gvim_c_study.vim:
;;   M-m        build the current program (build.bat in this folder)
;;   F5         run it in a new console window, in the source file's folder
;;   C-F5       build, then run if the build succeeded
;;   S-F5       stop it
;;   F6         open it in the Visual Studio 2022 debugger
;; The current program is the .c or .cpp file shown last. The mode line shows it
;; in brackets, e.g. [01_hello.c]. Editing a .h file keeps the program.
;; New .c and .cpp files start with main, and .c, .cpp and .h files are read
;; and saved as UTF-8, which build.bat expects (-source-charset:utf-8).
;; At the end it loads emacs_theme.el and emacs_edit.el from this folder: the
;; gvim font and colors and the gvim C/C++ editing keys.

(defvar cs-study-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "The C/C++ study folder, where this file, build.bat and run.bat are.")

(let ((base (expand-file-name "handmade.emacs" cs-study-directory)))
  (unless (file-readable-p base)
    (error "handmade.emacs was not found in %s" cs-study-directory))
  (load base nil t t))

;; Casey's file takes its folders from the Handmade Hero day folder layout
;; (misc\..\code). Here they are the study folder (M-t opens todo.txt here).
(setq casey-code-directory cs-study-directory
      casey-todo-file (expand-file-name "todo.txt" cs-study-directory)
      casey-log-file (expand-file-name "log.txt" cs-study-directory))

;; ---------------------------------------------------------------------------
;; UTF-8 for C and C++ files
;; ---------------------------------------------------------------------------

;; Korean Windows would save new or ASCII-only files in code page 949, which
;; build.bat would misread. Files without a BOM stay without one.
(modify-coding-system-alist 'file "\\.\\(c\\|cpp\\|h\\)\\'" 'utf-8)

;; ---------------------------------------------------------------------------
;; The current program
;; ---------------------------------------------------------------------------

(defvar cs-source nil
  "The .c or .cpp file that M-m, F5, S-F5 and F6 use.")

(defun cs--source-file-p (file)
  (and file (string-match-p "\\.\\(c\\|cpp\\)\\'" file)))

(defun cs--note-buffer (buffer)
  (let ((file (and (buffer-live-p buffer) (buffer-file-name buffer))))
    (when (and (cs--source-file-p file) (not (equal file cs-source)))
      (setq cs-source file)
      (force-mode-line-update t))))

(add-hook 'find-file-hook (lambda () (cs--note-buffer (current-buffer))))
(add-hook 'after-save-hook (lambda () (cs--note-buffer (current-buffer))))
(add-hook 'window-buffer-change-functions
          (lambda (_frame) (cs--note-buffer (window-buffer (selected-window)))))
(add-hook 'window-selection-change-functions
          (lambda (_frame) (cs--note-buffer (window-buffer (selected-window)))))

(defun cs--mode-line ()
  (format " [%s]" (if cs-source (file-name-nondirectory cs-source) "no program")))

(add-to-list 'global-mode-string '(:eval (cs--mode-line)) t)

;; ---------------------------------------------------------------------------
;; Build, run, stop, debug
;; ---------------------------------------------------------------------------

(defun cs--win (file)
  "FILE as an absolute Windows path with backslashes."
  (subst-char-in-string ?/ ?\\ (expand-file-name file)))

(defun cs--require-source ()
  (unless cs-source
    (user-error "Open a .c or .cpp file first")))

(defun cs--exe ()
  (cs--require-source)
  (let ((exe (expand-file-name (concat "build/" (file-name-base cs-source) ".exe")
                               (file-name-directory cs-source))))
    (unless (file-exists-p exe)
      (user-error "Nothing to run. Build %s first (M-m)" (file-name-nondirectory cs-source)))
    exe))

;; cmd.exe started through ShellExecute: no window of its own, and Emacs does
;; not wait for it. The COMMAND line is passed to cmd /c unchanged.
(defun cs--detached (command)
  (w32-shell-execute "open" "cmd.exe" (concat "/c " command) 0))

(defvar cs--run-after-build nil)

(defun cs-build ()
  "Build the current program with build.bat in the study folder (M-m)."
  (interactive)
  (cs--require-source)
  (setq cs--run-after-build nil)
  (let ((default-directory cs-study-directory))
    (compile (format "call \"%s\" \"%s\""
                     (cs--win (expand-file-name "build.bat" cs-study-directory))
                     (cs--win cs-source)))))

;; run.bat shows the exit code and waits for a key before the window closes.
(defun cs-run ()
  "Run the current program in a new console window, in its source folder (F5)."
  (interactive)
  (let* ((exe (cs--exe))
         (name (file-name-nondirectory exe))
         (dir (directory-file-name (file-name-directory cs-source))))
    (cs--detached (format "start \"%s\" /d \"%s\" cmd.exe /c \"\"%s\" \"%s\"\""
                          name (cs--win dir)
                          (cs--win (expand-file-name "run.bat" cs-study-directory))
                          (cs--win exe)))
    (if (file-newer-than-file-p cs-source exe)
        (message "Running %s, which is older than the source. M-m rebuilds it." name)
      (message "Running %s in %s" name (cs--win dir)))))

(defun cs-stop ()
  "Stop the current program (S-F5)."
  (interactive)
  (cs--require-source)
  (let ((name (concat (file-name-base cs-source) ".exe")))
    (cs--detached (format "taskkill /IM \"%s\" /F" name))
    (message "Stopping %s" name)))

(defun cs-debug ()
  "Open the current program in the Visual Studio 2022 debugger (F6)."
  (interactive)
  (let ((exe (cs--exe))
        (devenv-dir (getenv "DevEnvDir")))
    (unless devenv-dir
      (user-error "DevEnvDir is not set. Start Emacs with emacs.bat"))
    (cs--detached (format "start \"\" \"%sdevenv.exe\" /DebugExe \"%s\""
                          devenv-dir (cs--win exe)))
    (message "Opening Visual Studio")))

(defun cs--after-compile (buffer status)
  (when (and cs--run-after-build (eq buffer (get-buffer "*compilation*")))
    (setq cs--run-after-build nil)
    (if (string-match-p "\\`finished" status)
        (cs-run)
      (message "The build failed, so the program was not run."))))

(add-hook 'compilation-finish-functions #'cs--after-compile)

(defun cs-build-and-run ()
  "Build the current program, then run it if the build succeeded (C-F5)."
  (interactive)
  (cs-build)
  (setq cs--run-after-build t))

(define-key global-map "\em" 'cs-build)
(define-key global-map [f5] 'cs-run)
(define-key global-map [C-f5] 'cs-build-and-run)
(define-key global-map [S-f5] 'cs-stop)
(define-key global-map [f6] 'cs-debug)

;; ---------------------------------------------------------------------------
;; New files
;; ---------------------------------------------------------------------------

;; A new .c or .cpp file starts with main, with the cursor inside it, as in
;; gvim_c_study.vim. The function name starts the line, as in the Handmade Hero
;; code, so M-j lists it. Casey's header for new files (his name and copyright
;; notice) is not used here, and a new .h file starts empty.
(defvar-local cs--new-file nil)
(put 'cs--new-file 'permanent-local t)

(add-hook 'find-file-not-found-functions
          (lambda () (setq cs--new-file t) nil))

(defun cs--new-file-template ()
  (when cs--new-file
    (setq cs--new-file nil)
    (let ((ext (downcase (or (file-name-extension (or buffer-file-name "")) ""))))
      (cond
       ((member ext '("c" "cpp"))
        (erase-buffer)
        (insert (if (equal ext "c")
                    "#include <stdio.h>\n\nint\nmain(void)\n{\n    \n    return(0);\n}\n"
                  "#include <iostream>\n\nint\nmain()\n{\n    \n    return(0);\n}\n"))
        (goto-char (point-min))
        (forward-line 5)
        (end-of-line))
       ((equal ext "h")
        (erase-buffer))))))

(add-hook 'c-mode-common-hook #'cs--new-file-template t)

(add-hook 'window-setup-hook
          (lambda ()
            (message "C/C++ study: M-m build, F5 run, C-F5 build and run, S-F5 stop, F6 debug"))
          t)

;; ---------------------------------------------------------------------------
;; Font, colors and C/C++ editing keys
;; ---------------------------------------------------------------------------

;; emacs_theme.el (gvim's font and colors, Ctrl+mouse wheel font size) and
;; emacs_edit.el (gvim's C/C++ editing keys: brackets and quotes in pairs, TAB
;; out of them, snippets with M-e, C-; comments, line numbers) are copies of
;; the files in the Handmade Hero day folders' misc. Each is loaded only if it
;; is in this folder. F7 searches this whole folder (c and cpp included).
(dolist (file '("emacs_theme.el" "emacs_edit.el"))
  (let ((path (expand-file-name file cs-study-directory)))
    (when (file-readable-p path)
      (load path nil t t))))
