;; ============================================================
;;  init.el — Emacs 30 · Java · C++ · TypeScript
;;  LSP: eglot (built-in) + eglot-java (descarga jdtls auto)
;; ============================================================

;; ── UI básica ───────────────────────────────────────────────
(setq inhibit-startup-screen t)
(column-number-mode)
(global-display-line-numbers-mode 1)
(set-face-attribute 'default nil :font "Cascadia Code" :height 109)

;; Recargar archivos modificados externamente
(global-auto-revert-mode 1)
(setq auto-revert-verbose nil)
(setq global-auto-revert-non-file-buffers t)

;; ── Indentación ─────────────────────────────────────────────
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; ── Encoding ────────────────────────────────────────────────
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; ── Repositorio de paquetes ─────────────────────────────────
(require 'package)
(setq package-archives
      '(("melpa"  . "https://melpa.org/packages/")
        ("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; ── Backups / autosave ──────────────────────────────────────

(setq backup-directory-alist
      '(("." . "~/.emacs_saves/backups")))

(setq auto-save-file-name-transforms
      `((".*" "~/.emacs_saves/autosaves/" t)))

(setq create-lockfiles nil)

;; Crear carpetas automáticamente
(make-directory "~/.emacs_saves/backups/" t)
(make-directory "~/.emacs_saves/autosaves/" t)

;; ── use-package viene integrado en Emacs 30 ─────────────────
(require 'use-package)
(setq use-package-always-ensure t)

;; ============================================================
;; EXPLORADOR DE ARCHIVOS — Treemacs
;; ============================================================

(use-package treemacs
  :defer t
  :bind
  (("C-x t t" . treemacs)
   ("<f8>"    . treemacs))
  :config
  (setq treemacs-width              35
        treemacs-follow-after-init  t
        treemacs-is-never-other-window t))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package projectile
  :config
  (projectile-mode 1))

;; ============================================================
;; GIT EN GUTTER (tipo VSCode)
;; ============================================================

(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  (diff-hl-margin-mode 1)
  :hook
  (magit-post-refresh . diff-hl-magit-post-refresh)
  (prog-mode          . diff-hl-mode)
  (dired-mode         . diff-hl-dired-mode))

;; ============================================================
;; MAGIT
;; ============================================================

(use-package magit
  :pin nongnu
  :bind
  (("C-x g" . magit-status)
   ("C-c g" . magit-dispatch))
  :config
  (setq magit-display-buffer-function
        'magit-display-buffer-same-window))

;; ============================================================
;; THEME — Dracula
;; ============================================================

(use-package dracula-theme
  :config
  (load-theme 'dracula t))

;; ============================================================
;; AUTOCOMPLETADO — company
;; ============================================================

(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length    1
        company-idle-delay               0.2
        company-tooltip-align-annotations t
        company-selection-wrap-around    t))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; ============================================================
;; ERRORES EN LÍNEA — flycheck
;; ============================================================

(use-package flycheck
  :init (global-flycheck-mode))

;; ============================================================
;; PERFORMANCE (antes de LSP para que tome efecto)
;; ============================================================

(setq gc-cons-threshold        (* 100 1024 1024)
      read-process-output-max  (* 1024 1024)
      inhibit-compacting-font-caches t)

;; ============================================================
;; JAVA — JAVA_HOME (Windows · OpenLogic JDK 17)
;; ============================================================

(setenv "JAVA_HOME"
        "C:/Program Files/OpenLogic/openjdk-21.0.10")

(add-to-list 'exec-path
             "C:/Program Files/OpenLogic/openjdk-21.0.10/bin")

;; ============================================================
;; EGLOT — cliente LSP integrado en Emacs 30
;;
;; Corrección importante: existe un bug conocido entre eglot y
;; jdtls donde un workspace/didChangeConfiguration vacío borra
;; las opciones de inicialización del servidor. Se resuelve
;; deshabilitando ese hook SOLO para los modos Java.
;; Ver: https://debbugs.gnu.org/66726
;; ============================================================

(use-package eglot
  :ensure nil   ;; built-in en Emacs 30, no instalar desde MELPA
  :config
  (setq eglot-autoshutdown         t
        eglot-events-buffer-size   0    ;; 0 = sin límite de log
        eglot-connect-timeout      60)  ;; jdtls tarda en arrancar

  ;; Fix bug eglot+jdtls: deshabilitar didChangeConfiguration en Java
  (defun my/eglot-java-disable-did-change-config ()
    (remove-hook 'eglot-connect-hook
                 'eglot-signal-didChangeConfiguration
                 t))  ;; t = local al buffer

  (add-hook 'java-mode-hook    #'my/eglot-java-disable-did-change-config)
  (add-hook 'java-ts-mode-hook #'my/eglot-java-disable-did-change-config)

  ;; Atajos eglot
  (define-key eglot-mode-map (kbd "M-.")   #'xref-find-definitions)
  (define-key eglot-mode-map (kbd "M-?")   #'xref-find-references)
  (define-key eglot-mode-map (kbd "C-c r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c f") #'eglot-format-buffer))

;; ============================================================
;; JAVA — eglot-java
;;
;; Descarga y gestiona el servidor Eclipse JDT LS (jdtls)
;; automáticamente. NO necesitas instalar jdtls manualmente.
;;
;; Instalación única: M-x eglot-java-upgrade-lsp-server
;;   (o se instala solo al abrir el primer .java)
;;
;; Directorio de instalación del servidor:
;;   ~/.emacs.d/eglot-java/  (configurable)
;; ============================================================

(use-package eglot-java
  :after eglot
  :hook
  ((java-mode    . eglot-java-mode)
   (java-ts-mode . eglot-java-mode))
  :custom
  ;; Argumentos JVM pasados al servidor jdtls
  (eglot-java-eclipse-jdt-args
   '("-Xmx2G"
     "--add-modules=ALL-SYSTEM"
     "--add-opens" "java.base/java.util=ALL-UNNAMED"
     "--add-opens" "java.base/java.lang=ALL-UNNAMED"))
  :config
  ;; Workspace por proyecto (evita colisiones entre proyectos)
  (setq eglot-java-workspace-folder
        (expand-file-name "~/.emacs.d/eglot-java/workspace/")))

;; ============================================================
;; C / C++ — clangd vía eglot (integrado)
;; ============================================================

(use-package cc-mode
  :ensure nil
  :hook ((c-mode   . eglot-ensure)
         (c++-mode . eglot-ensure))
  :config
  (setq c-basic-offset 2))

;; ============================================================
;; TYPESCRIPT / JAVASCRIPT — ts-ls vía eglot
;;
;; Requiere: npm install -g typescript typescript-language-server
;; ============================================================

(use-package typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))

(add-hook 'typescript-mode-hook    #'eglot-ensure)
(add-hook 'typescript-ts-mode-hook #'eglot-ensure)
(add-hook 'tsx-ts-mode-hook        #'eglot-ensure)
(add-hook 'js-ts-mode-hook         #'eglot-ensure)

(setq js-indent-level 2)

;; ============================================================
;; TREESITTER — resaltado mejorado
;; ============================================================

(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

;; ============================================================
;; UTILIDADES
;; ============================================================

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :config (which-key-mode))

;; ── Navegar errores flycheck ─────────────────────────────────
(global-set-key (kbd "M-g n") #'flycheck-next-error)
(global-set-key (kbd "M-g p") #'flycheck-previous-error)

;; ============================================================
;; custom-set (gestionado por Emacs, no editar a mano)
;; ============================================================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
