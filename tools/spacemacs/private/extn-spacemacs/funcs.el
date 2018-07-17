(defun extn-spacemacs/setq-default-frame-title-format-enhanced ()
  (setq-default
   frame-title-format (extn-spacemacs//frame-title-format-enhanced-eval)))


(defun extn-spacemacs//frame-title-format-enhanced-eval ()
  '((:eval (extn-spacemacs//frame-title-format-enhanced))))


(defun extn-spacemacs//frame-title-format-enhanced ()
  (if (buffer-file-name)
      (abbreviate-file-name (buffer-file-name))
    "%b"))

(when (configuration-layer/package-usedp 'projectile)
  (defun extn-spacemacs/regenerate-tags ()
    (interactive)
    (let ((ggtags-mode nil)
          (projectile-tags-command
           (if extn-spacemacs/tags-command-local
               extn-spacemacs/tags-command-local
             projectile-tags-command)))
      (makunbound 'ggtags-mode)
      (projectile-regenerate-tags))))

(when (configuration-layer/package-usedp 'fill-column-indicator)
  (define-globalized-minor-mode global-fci-mode fci-mode
    (lambda ()
      (if (and
           (not (string-match "^\*.*\*$" (buffer-name)))
           (not (eq major-mode 'dired-mode)))
          (fci-mode 1)))))
