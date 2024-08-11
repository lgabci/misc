;; set file assembly syntax for .inc files
(add-to-list 'auto-mode-alist '("\\.inc\\'" . asm-mode))

;; load theme
(load-theme 'manoj-dark)

;; hide toolbar
(tool-bar-mode -1)

;; show current row and column
(setq column-number-mode t)

;; show matching parentheses
(show-paren-mode 1)

;; show characters over 80 columns
(require 'whitespace)
(setq whitespace-line-column 80)
(setq whitespace-style '(face lines-tail tab-mark trailing))
(global-whitespace-mode +1)

;; turn off indent tabs mode
(setq-default indent-tabs-mode nil)

;; set default font and size
;(add-to-list 'default-frame-alist '(font . "Terminus") '(height . 120))

;; goto 1st error in compilation buffer
(setq compilation-scroll-output 'first-error)

;; save desktop
(setq desktop-auto-save-timeout nil)
(setq desktop-restore-forces-onscreen nil)
(add-hook 'desktop-after-read-hook
          (lambda()
            (frameset-restore
              desktop-saved-frameset
              :reuse-frames (eq desktop-restore-reuses-frames t)
              :cleanup-frames (not (eq desktop-restore-reuses-frames 'keep))
              :force-display desktop-restore-in-current-display
              :force-onscreen desktop-restore-forces-onscreen)))
(desktop-save-mode 1)

;; auto refresh modified buffers
(global-auto-revert-mode t)

;; autosaves and backups in /tmp
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; set C style
(setq c-default-style
      '((java-mode . "java")
        (awk-mode . "awk")
        (other . "stroustrup")))
(setq-default c-basic-offset 2
              tab-width 8
              indent-tabs-mode nil)

;; set as comment to #
(setq asm-comment-char ?\#)

;; set shell scripts offset
(setq sh-basic-offset 2)

;; disable lock files
(setq create-lockfiles nil)

;; function to set current window width to 80 columns
(defun set-window-width (n)
  "Set the selected window's width."
  (adjust-window-trailing-edge (selected-window) (- n (window-width)) t))

(defun set-80-columns ()
  "Set the selected window to 80 columns."
  (interactive)
  (set-window-width 80))

(global-set-key "\C-x~" 'set-80-columns)

;; functions to M-x meson ...
(setq meson-src-dir (file-name-as-directory "~/projects/lgos"))
(setq meson-bld-dir (file-name-as-directory "/tmp/lgos"))
(setq meson-arch "i386")

(defun meson(&optional cmd)
  "Doc-string for 'meson'."
  (interactive)
  (setq meson-cmpl "")
  (unless (file-exists-p (concat meson-bld-dir "build.ninja"))
    (setq meson-cmpl (concat "meson setup --cross-file"
                             " " meson-src-dir "src/arch/"
                             meson-arch "/meson-cross.txt"
                             " " meson-src-dir
                             " " meson-bld-dir " && ")))
  (setq meson-cmpl (concat meson-cmpl "meson compile -C " meson-bld-dir
                           (if (not (null cmd))
                               (concat " " cmd))))
  (compile meson-cmpl))

(defun meson-clean()
  "Doc-string for 'meson-clean'."
  (interactive)
  (compile (concat "rm -rf " meson-bld-dir)))

(defun meson-emu()
  "Doc-string for 'meson-emu'."
  (interactive)
  (meson "emu"))
