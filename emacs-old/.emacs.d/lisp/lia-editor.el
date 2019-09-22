;;; lia-editor.el --- Emacs Config -*- lexical-binding: t; -*-

;;; Commentary:

;; Change Emacs to have a decent text editor

;;; Code:

(defun lia/set-indent (N)
  "Set the indentation level to N spaces to new buffers."
  (interactive "nIndentation size:")
  (setq-default tab-width N
                evil-shift-width N
                haskell-indentation-layout-offset N
                haskell-indentation-starter-offset N
                haskell-indentation-left-offset N
                haskell-indentation-ifte-offset N
                haskell-indentation-where-pre-offset (floor (/ N 2))
                haskell-indentation-where-post-offset N
                c-basic-offset N
                sh-basic-offset N
                javascript-indent-level N
                js-indent-level N
                js-switch-indent-offset N
                css-indent-offset N
                web-mode-markup-indent-offset N
                web-mode-css-indent-offset N
                web-mode-code-indent-offset N
                web-mode-script-padding N
                web-mode-style-padding N))

(defun lia/enable-tabs ()
  "Enables indentation with tabs."
  (interactive)
  (setq indent-tabs-mode t))

(defun lia/disable-tabs ()
  "Disable identation with tabs."
  (interactive)
  (setq indent-tabs-mode nil))

(defun lia/global-enable-tabs ()
  "Enables indentation with tabs globally.

Only affects future buffers.  Revert buffer to update indentation."
  (interactive)
  (setq-default indent-tabs-mode t))

(defun lia/global-disable-tabs ()
  "Disable identation with tabs globally.

Only affects future buffers.  Revert buffer to update indentation."
  (interactive)
  (setq-default indent-tabs-mode nil))

(use-package editorconfig
  :ensure t
  :hook (prog-mode . editorconfig-mode))

(use-package format-all
  :ensure t
  :commands (format-all-buffer
             format-all-mode)
  :init
  (eval-after-load 'lia-keybind
    '(lia-bind-leader "F" 'format-all-buffer)))

;; indent `case' in switch/case
(c-set-offset 'case-label '+)

;; backspace simply deletes a character
(setq backward-delete-char-untabify-method nil)

(provide 'lia-editor)

;;; lia-editor.el ends here