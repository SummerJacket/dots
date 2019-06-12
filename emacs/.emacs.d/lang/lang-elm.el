;;; lang-elm.el --- Language Support -*- lexical-binding: t; -*-

;;; Commentary:

;; Language support for Elm

;;; Code:

(use-package elm-mode
  :ensure t
  :mode "\\.elm\\'"
  :general
  (:keymaps
   'elm-mode-map
   [remap format-all-buffer] 'elm-format-buffer))

(provide 'lang-elm)

;;; lang-elm.el ends here
