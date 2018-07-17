(when (configuration-layer/package-usedp 'dante)

  (defun extn-haskell/dante-restart ()
    (interactive)
    (when (configuration-layer/package-usedp 'direnv)
      (direnv-update-environment))
    (dante-restart))

  (defun extn-haskell/dante-repl-if-file-upward (root files f)
    (cl-some
      (lambda (file)
        (let ((found (extn-haskell//file-search-upward root file)))
          (when found (funcall f found))))
     files))


  (defun extn-haskell//setq-default-dante-repl (list)
    (setq-default dante-repl-command-line-methods-alist
                  (extn-haskell//dante-repl-alist list)))

  (defun extn-haskell//dante-repl-alist (list)
    (let*
        ((alist-old dante-repl-command-line-methods-alist)
         (alist-new (append
                     `(,(extn-haskell//dante-repl-cabal-multi)
                       ,(extn-haskell//dante-repl-stack-multi)
                       ,(extn-haskell//dante-repl-nix-multi)
                       ,(extn-haskell//dante-repl-bare-new))
                     alist-old)))
      (seq-map (lambda (elem) (or (assoc elem alist-new) elem)) list)))

  (defun extn-haskell//dante-repl-bare-new ()
    `(bare-new
      . ,(lambda (root)
           '("cabal" "new-repl" dante-target
             "--builddir=dist/dante"
             "--ghc-options=-ignore-dot-ghci"))))

  (defun extn-haskell//dante-repl-cabal-multi ()
    `(cabal-multi
      . ,(lambda (root)
           (extn-haskell/dante-repl-if-file-upward
            root
            '("cabal.project")
            (lambda (cabal-project)
              '("cabal" "new-repl" dante-target
                "--builddir=dist-newstyle/dante"
                "--ghc-options=-ignore-dot-ghci"))))))

  (defun extn-haskell//dante-repl-stack-multi ()
    `(stack-multi
      . ,(lambda (root)
           (extn-haskell/dante-repl-if-file-upward
            root
            '("stack.yaml")
            (lambda (stack-yaml)
              '("stack" "repl" dante-target))))))

  (defun extn-haskell//dante-repl-nix-multi ()
    `(nix-multi
      . ,(lambda (root)
           (extn-haskell/dante-repl-if-file-upward
            root
            '("shell.nix")
            (lambda (shell-nix)
              `("nix-shell" "--pure" "--run"
                ,(concat
                  "cabal new-repl "
                  (or dante-target "")
                  " --builddir=dist-newstyle/dante"
                  " --ghc-options=-ignore-dot-ghci")
                ,shell-nix))))))

  (defun extn-haskell//hook-if-not-regex (hook)
    (extn-haskell//hook-regex-guarded '-none? hook))

  (defun extn-haskell//hook-if-regex (hook)
    (extn-haskell//hook-regex-guarded '-any? hook))

  (defun extn-haskell//hook-regex-guarded (g hook)
    (eval
     (lambda ()
       (when
           (and
            (buffer-file-name)
            (funcall g
                     (lambda (regex) (string-match-p regex buffer-file-name))
                     extn-haskell/dante-exclude-regexes))
         (funcall hook)))
     `((g . ,g) (hook . ,hook))))

  (defun extn-haskell//file-search-upward (directory file)
    (let
        ((parent-dir
          (file-truename (concat (file-name-directory directory) "../")))
         (current-path
          (if (not (string= (substring directory (- (length directory) 1)) "/"))
              (concat directory "/" file)
            (concat directory file))))
      (if (file-exists-p current-path)
          current-path
        (when (and
               (not (string= (file-truename directory) parent-dir))
               (< (length parent-dir) (length (file-truename directory))))
          (extn-haskell//file-search-upward parent-dir file))))))
