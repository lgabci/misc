;; load theme
(load-theme 'manoj-dark)

;; hide toolbar
(if (display-graphic-p)
  (tool-bar-mode -1))

;; show current row and column
(setq column-number-mode t)

;; show matching parentheses
(show-paren-mode 1)

;; show characters over 80 columns
(require 'whitespace)
(setq whitespace-line-column 80)
(setq whitespace-style '(face lines-tail tab-mark trailing))
(global-whitespace-mode +1)

;; hihglight TODO-s
(add-hook 'prog-mode-hook
          (lambda ()
            (font-lock-add-keywords nil
              '(("\\(\\<\\(FIXME\\|TODO\\|BUG\\)[: \n]\\|#\\#.*\\|/\\/.*\\)" 0
              font-lock-warning-face t)))))

;; turn off indent tabs mode
(setq-default indent-tabs-mode nil)

;; set font size
(set-face-attribute 'default nil :height 90)

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

;; disable lock files
(setq create-lockfiles nil)

;; set C style
(setq c-default-style
      '((java-mode . "java")
        (awk-mode . "awk")
        (other . "stroustrup")))
(setq-default c-basic-offset 2
              tab-width 8
              indent-tabs-mode nil)

;; function to set current window width to 80 columns
(defun set-window-width (n)
  "Set the selected window's width."
  (adjust-window-trailing-edge (selected-window) (- n (window-width)) t))

(defun set-80-columns ()
  "Set the selected window to 80 columns."
  (interactive)
  (set-window-width 80))

(global-set-key "\C-x~" 'set-80-columns)
