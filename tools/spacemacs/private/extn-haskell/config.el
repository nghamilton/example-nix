(defvar extn-haskell/dante-hlint nil)

(defvar extn-haskell/dante-xref-enable t)

(defvar extn-haskell/dante-load-flags-extra
  '("-Wall"
    ;; DESIGN: https://github.com/jyp/dante/issues/54
    ;; "-fdefer-typed-holes"
    ;; "-fdefer-type-errors"
    ))

(defvar extn-haskell/dante-exclude-regexes
  '("/\\.haskdogs/" "/\\.codex/"))

(defvar extn-haskell/dante-repl-types
  '(nix stack styx mafia new-build bare))
