(defconst direnv-packages
  '(direnv))

(defun direnv/init-direnv ()
  (use-package direnv
    :commands direnv-mode
    :init
    (direnv-mode)))
