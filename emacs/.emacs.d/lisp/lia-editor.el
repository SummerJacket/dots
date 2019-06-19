;;; lia-editor.el --- Emacs Config -*- lexical-binding: t; -*-

;;; Commentary:

;; Change Emacs to have a decent text editor

;;; Code:

(defun lia/set-indent (N)
  "Set the indentation level to N spaces."
  (interactive "nIndentation size:")
  (setq tab-width N) ; local
  (setq-default tab-width N) ; and global
  (setq-default evil-shift-width N
                haskell-indentation-layout-offset N
                haskell-indentation-starter-offset N
                haskell-indentation-left-offset N
                haskell-indentation-ifte-offset N
                haskell-indentation-where-pre-offset (floor (/ N 2))
                haskell-indentation-where-post-offset N
                c-basic-offset N
                javascript-indent-level N
                js-indent-level N
                js-switch-indent-offset N ; switch-case indentation
                css-indent-offset N
                web-mode-markup-indent-offset N
                web-mode-css-indent-offset N
                web-mode-code-indent-offset N
                web-mode-script-padding N
                web-mode-style-padding N))

(defun lia/enable-tabs (&optional ARG)
  "Enables indentation with tabs.

If ARG is negative, then use spaces.  Otherwise, use tabs.
This means calling with nil will enable tab indentation.

If GLOBAL is non-nil, enable/disable tabs globally."
  (interactive)
  (defvar lia-setq)
  (let ((should-enable (not (and (numberp ARG) (< ARG 0)))))
    (setq indent-tabs-mode should-enable)
    (setq-default indent-tabs-mode should-enable)))

(defun lia/disable-tabs ()
  "Disable identation with tabs.

If GLOBAL is non-nil, disable tabs globally."
  (interactive)
  (lia/enable-tabs -1))

(use-package editorconfig
  :ensure t
  :hook (prog-mode . editorconfig-mode))

(use-package format-all
  :ensure t
  :commands (format-all-buffer
             format-all-mode))

(use-package lsp-mode
  :ensure t
  :commands lsp
  :init
  (setq lsp-auto-guess-root t))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :init
  (setq lsp-ui-doc-enable nil
        lsp-ui-doc-position 'top
        lsp-ui-doc-use-webkit nil
        lsp-ui-sideline-enable t
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-symbol nil))

(use-package company-lsp
  :ensure t
  :commands company-lsp)

(use-package helm-lsp
  :ensure t
  :commands helm-lsp-workspace-symbol)

;; indent `case' in switch/case
(c-set-offset 'case-label '+)

;; backspace simply deletes a character
(setq backward-delete-char-untabify-method nil)

(provide 'lia-editor)

;;; lia-editor.el ends here
