(defconst extn-haskell-packages
  '(
    dante
    flycheck
    haskell-mode
    (company-ghc :excluded t)
    (company-ghci :excluded t)
    (flycheck-haskell :excluded t)
    (ghc :excluded t)
    (intero :excluded t)))

(defun extn-haskell/init-dante ()
  (use-package dante
    :commands dante-mode
    :init
    (when (configuration-layer/package-usedp 'haskell-mode)
      (if (configuration-layer/package-usedp 'direnv)
          (spacemacs/add-to-hooks
           (extn-haskell//hook-if-not-regex
            (lambda () (direnv-update-environment) (dante-mode)))
           '(haskell-mode-hook literate-haskell-mode-hook))
        (spacemacs/add-to-hooks
         (extn-haskell//hook-if-not-regex 'dante-mode)
         '(haskell-mode-hook literate-haskell-mode-hook))))
    :config
    (spacemacs|diminish dante-mode "Ⓓ" "D")
    (dolist (mode haskell-modes)
      (spacemacs/declare-prefix-for-mode mode
        "m," "haskell/dante")
      (spacemacs/set-leader-keys-for-major-mode mode
        ",\"" 'dante-eval-block
        ",."  'dante-info
        ",,"  'dante-type-at
        ",r"  'extn-haskell/dante-restart
        ",d"  'dante-diagnose)
      (when (configuration-layer/package-usedp 'attrap)
        (spacemacs/set-leader-keys-for-major-mode mode
          "r/"  'attrap-attrap)))
    (when (not extn-haskell/dante-xref-enable)
      (remove-hook 'xref-backend-functions 'dante--xref-backend))
    (extn-haskell//setq-default-dante-repl extn-haskell/dante-repl-types)
    (dolist (flag extn-haskell/dante-load-flags-extra)
      (add-to-list 'dante-load-flags flag))))

(defun extn-haskell/pre-init-flycheck ()
  (spacemacs|use-package-add-hook flycheck
    :post-init
    (when (configuration-layer/package-usedp 'haskell-mode)
      (dolist (mode haskell-modes) (spacemacs/add-flycheck-hook mode))
      (spacemacs/add-to-hooks
       (lambda ()
         (dolist (checker '(haskell-ghc haskell-stack-ghc))
           (add-to-list 'flycheck-disabled-checkers checker)))
       '(haskell-mode-hook literate-haskell-mode-hook))
      (when extn-haskell/dante-hlint
        (add-hook 'dante-mode-hook
                  (lambda ()
                    (flycheck-add-next-checker
                     'haskell-dante
                     '(warning . haskell-hlint))))))))

(defun extn-haskell/pre-init-haskell-mode ()
  (spacemacs|use-package-add-hook haskell-mode
    :post-init
    (add-hook 'literate-haskell-mode-hook
              (lambda ()
                (remove-hook
                 'before-save-hook
                 'haskell-mode-before-save-handler
                 t))
              t)
    (remove-hook 'haskell-mode-local-vars-hook
                 #'spacemacs-haskell//setup-completion-backend)))
