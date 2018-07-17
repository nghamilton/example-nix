(defconst extn-spacemacs-packages
  '(projectile))

(defun extn-spacemacs/pre-init-projectile ()
  (spacemacs|use-package-add-hook projectile
    :pre-config
    (spacemacs/set-leader-keys
      "p`" 'extn-spacemacs/regenerate-tags)))
