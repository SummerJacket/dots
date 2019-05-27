;;; lia-appearance.el --- Emacs Config -*- lexical-binding: t; -*-

;;; Commentary:

;; Change the appearance of Emacs

;;; Code:

(defun lia/toggle-line-number-type ()
  "Toggle the line number type between absolute and relative."
  (interactive)
  (defvar display-line-numbers-type)
  (setq display-line-numbers-type
        (if (eq display-line-numbers-type 'relative)
            (progn (message "Line number type: absolute") t)
          (progn (message "Line number type: relative") 'relative)))
  ;; update line numbers if it's currently being displayed
  (when (bound-and-true-p display-line-numbers-mode)
    (display-line-numbers--turn-on)))

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init
  (setq doom-modeline-height 35
        doom-modeline-buffer-file-name-style 'relative-to-project)
  :hook (after-init . doom-modeline-mode))

(use-package hide-mode-line
  :ensure t
  :hook (neotree-mode . hide-mode-line-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; remove gui bars
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; highlight current line when programming
(add-hook 'prog-mode-hook 'hl-line-mode)

;; highlight matching paren
(show-paren-mode t)

;; hide cursor except for selected window
(setq-default cursor-in-non-selected-windows nil)

;; display line numbers
(setq-default display-line-numbers-type 'relative
              display-line-numbers-width 3
              display-line-numbers-widen t)
;; (add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; set font size

;; +0.140s to startup time
;; (set-frame-font "Iosevka 11" nil t)

;; can't benchmark since esup crashes prematurely.
;; but I think it shaves about 0.1s compared to `set-frame-font' above
;; depends on the machine you're running on ofc
(add-to-list 'default-frame-alist '(font . "Iosevka 10"))

(provide 'lia-appearance)

;;; lia-appearance.el ends here
