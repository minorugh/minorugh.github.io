---
layout: default
title: Emacs Configuration
---

# Emacs Configuration

## 1. はじめに

```note
* ここは [@minoruGH](https://twitter.com/minorugh) の Emacs設定ファイルの一部を解説しているページです。
* [init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el) 本体は、[GitHub](https://github.com/minorugh/dotfiles/tree/main/.emacs.d) に公開しています。
* 本ドキュメントは、[@takaxp](https://twitter.com/takaxp)さんの了解を得て [takaxp.github.io/](https://takaxp.github.io/init.html) の記事を下敷きにした模倣版です。
```

![emacs](https://minorugh.github.io/img/emacs29.4.png)

### 1.1. 動作確認環境

以下の環境で使用しています。動作を保証するものではありません。

* ThinkPad P1 Gen1 i7/32GB/1TB
* Debian 12.x x86_64 GNU/Linux
* 自分でビルドした GNU Emacs 29.4

### 1.2. ディレクトリ構成

設定ファイルの構成は下記のとおりです。

```
~/.emacs.d
│
├── elisp/                        ← ローカルパッケージ置き場
│   ├── bin/
│   ├── css/
│   ├── img/
│   ├── git-peek.el
│   ├── my-deepl-translate.el
│   ├── my-evil-cheat-sheet.el
│   ├── my-gcal-diary.el
│   ├── my-markdown.el
│   ├── my-sen-cleanup.el
│   ├── my-template.el
│   ├── my-tig-bridge.el
│   ├── seiho-haiku.el
│   └── tempbuf.el
├── elpa/
├── inits/
│   ├── 00-base.el
│   ├── 01-dashboard.el
│   ├── 02-evil.el
│   ├── 03-ivy.el
│   ├── 04-counsel.el
│   ├── 05-company.el
│   ├── 06-mozc.el
│   ├── 07-functions.el
│   ├── 08-edit.el
│   ├── 09-makefile.el
│   ├── 10-flymake.el
│   ├── 20-selected.el
│   ├── 30-ui.el
│   ├── 30-utils.el
│   ├── 40-dired.el
│   ├── 40-remote.el
│   ├── 50-howm.el
│   ├── 60-markdown.el
│   ├── 70-easy-hugo.el
│   ├── 70-neomutt.el
│   ├── 70-neotree.el
│   ├── 70-translate.el
│   ├── 70-yatex.el
│   ├── 80-hydra-browse.el
│   ├── 80-hydra-dired.el
│   ├── 90-calendar.el
│   └── 90-darkroom.el
├── snippets/
├── tmp/                          ← 各種履歴・キャッシュ
├── early-init.el
├── init.el
└── init-mini.el
```

ファイル番号の意味は下記のとおりです（数字はカテゴリの目安であり、厳密な連番ではありません）。

| 番号 | カテゴリ |
|------|---------|
| 00-09 | コア・基本設定 |
| 10-19 | 構文チェック |
| 20-29 | リージョン操作 |
| 30-39 | UI・外観・ユーティリティ |
| 40-49 | ファイラー・リモート連携 |
| 50-59 | メモ環境 |
| 60-69 | 文書編集 |
| 70-79 | 外部ツール・専用メジャーモード連携 |
| 80-89 | Hydra メニュー |
| 90-99 | カレンダー・執筆モード |


## 2. 起動設定

ブートシーケンスは以下のとおりです。

1. `early-init.el` の読み込み
2. `init.el` の読み込み
3. `inits/` のファイル群を読み込み（init-loader 使用）

### 2.1. [early-init.el] 早期初期化

`early-init.el` は Emacs 27 から導入されました。`init.el` でパッケージや GUI の初期化が実行される前にロードされます。

[https://github.com/minorugh/dotfiles/blob/main/.emacs.d/early-init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/early-init.el)

#### 2.1.1. 起動高速化

```elisp
;; GCを起動完了まで実質停止
(setq gc-cons-threshold most-positive-fixnum)

;; native-comp の JIT コンパイルを無効化
(setq native-comp-jit-compilation nil)

;; パッケージ初期化を init.el に委譲
(setq package-enable-at-startup nil)

;; 新しいソースファイルを優先
(setq load-prefer-newer t)

;; フレームリサイズを抑制
(setq frame-inhibit-implied-resize t)
```

#### 2.1.2. 言語・エンコーディングとフォント

言語環境を明示的に `"Japanese"` に設定した上で、`utf-8` を優先させます。マシン名が `P1` かどうかでフォントサイズを切り替えます。

```elisp
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;; "P1" is the hostname of the main machine.
(let ((font-size (if (string= (system-name) "P1") 18 16)))
  (push `(font . ,(format "Cica-%d" font-size)) default-frame-alist))

(setq inhibit-compacting-font-caches t)
```

### 2.1.3. UI の早期無効化とフレーム設定

```elisp
(push '(menu-bar-lines     . 0) default-frame-alist)
(push '(tool-bar-lines     . 0) default-frame-alist)
(push '(vertical-scroll-bars  ) default-frame-alist)
(push '(undecorated        . t) default-frame-alist)

;; Launch maximized on the monitor to the right.
;; (A negative "left" value is measured from the right edge.)
(push '(left       .        -1) initial-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
```

外部モニターの絶対座標（`x=1920` 固定）を指定する方式から、`left` を負の値にして「右端のモニターに最大化して起動する」という相対指定に変更しています。マルチモニター環境の変化に強くするための調整です。X11 レベルの設定（XIM 無効化・DPI・初期背景色）は `~/.Xresources` に記述し、`xrdb -merge ~/.Xresources` で反映します。

#### 2.1.4. スプラッシュ画面・Customize

```elisp
(setq inhibit-startup-message t)
(setq inhibit-startup-screen  t)

;; Leave the initial buffer selection to dashboard.
(setq initial-buffer-choice nil)

;; Prevent Customize from writing directly to init.el
(setq custom-file (locate-user-emacs-file "tmp/custom.el"))
```

起動画面は dashboard（後述）に任せるため無効化し、`M-x customize` の書き込み先を `init.el` から `tmp/custom.el` に退避して、設定ファイルの汚染を防いでいます。

### 2.2. [init.el] メイン初期化

[https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el)

#### 2.2.1. バージョンチェックと起動高速化

```elisp
(when (version< emacs-version "29.1")
  (error "This requires Emacs 29.1 and above!"))

(defvar default-handlers file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist default-handlers)
            (setq gc-cons-threshold (* 16 1024 1024))
            (setq inhibit-message nil)
            (message "Emacs ready in %s with %d GCs."
                     (emacs-init-time) gcs-done)))
```

起動後は GC 閾値を 16MB に戻します。

#### 2.2.2. パッケージシステム（leaf.el + key-chord）

`use-package` から [`leaf.el`](https://github.com/conao3/leaf.el) に全面移行しています。`hydra` は `leaf-keywords` の前に初期化します。

```elisp
(eval-and-compile
  (setq package-archives
        '(("gnu"   . "https://elpa.gnu.org/packages/")
          ("melpa" . "https://melpa.org/packages/")))

  (package-initialize)

  (use-package leaf :ensure t)
  (leaf hydra :ensure t)
  (leaf leaf-keywords
    :ensure t
    :config
    (leaf-keywords-init)))
```

`key-chord` も init.el 側で読み込み、IME の ON/OFF 切り替え直後に稀に発生する「スタール（chord が反応しなくなる）」を自動回復させています。

```elisp
(leaf key-chord
  :ensure t
  :hook (after-init-hook . key-chord-mode)
  :config
  (defun my-key-chord-ensure ()
    "Key-chord stall recovery."
    (when key-chord-mode
      (key-chord-mode -1)
      (key-chord-mode 1)))
  (add-hook 'input-method-activate-hook   #'my-key-chord-ensure)
  (add-hook 'input-method-deactivate-hook #'my-key-chord-ensure))
```

#### 2.2.3. init-loader と load-path

```elisp
(leaf init-loader
  :ensure t
  :load-path "~/.emacs.d/elisp"   ; Path to the local packages
  :config
  (setq init-loader-show-log-after-init 'error-only)
  (setq init-loader-byte-compile t)
  (key-chord-define-global "l;" 'init-loader-show-log)
  (init-loader-load))
```

`load-path` は `init-loader` の `:load-path` で一括指定しています。`inits/` 配下のファイルはバイトコンパイルしながら順次読み込みます。`l;`（key-chord）でロードエラーのログを表示できます。

さらに `kill-emacs-hook` で `elisp/` 配下の更新されたファイルだけを終了時にバイトコンパイルし、次回起動を軽くしています。

```elisp
(leaf *my-byte-compile-elisp
  :hook (kill-emacs-hook . my-byte-compile-elisp-dir)
  :preface
  (defun my-byte-compile-elisp-dir ()
    "Byte-compile newer Elisp files in ~/.emacs.d/elisp."
    (let ((elisp-dir (expand-file-name "elisp" user-emacs-directory)))
      (dolist (el (directory-files elisp-dir t "\\.el\\'"))
        (when (file-newer-than-file-p el (concat el "c"))
          (ignore-errors (byte-compile-file el)))))))
```

#### 2.2.4. サーバー

```elisp
(leaf server
  :commands server-running-p
  :hook (emacs-startup-hook
         . (lambda ()
             (unless (server-running-p)
               (server-start)))))
```

`emacsclient` から NeoMutt や tig 連携（後述）を呼び出せるよう、起動時に Emacs server を自動起動します。`exec-path-from-shell` は現在の運用では使用しておらず、`SSH_AUTH_SOCK` の引き継ぎは `hydra-dired` の `my-reload-xenv`（後述）で必要な時に手動リロードする方式に切り替えています。

### 2.3. [init-mini.el] ミニマル起動

新しいパッケージのテストや Emacs が起動しない場合のデバッグ用です。

```bash
alias eq="emacs -q -l ~/.emacs.d/init-mini.el"
```

`fido-mode` / `fido-vertical-mode` を使った軽量な補完環境のみを設定しています。外部パッケージは一切使用しません。


## 3. コア設定（00-base.el）

基本的な Emacs の挙動と共通のキーバインドを設定します。

### 3.1. パフォーマンス

```elisp
(setq-default bidi-display-reordering nil)
(setq-default bidi-paragraph-direction 'left-to-right)
```

右→左言語の双方向テキスト処理を省略し、描画を高速化します。

### 3.2. ファイル・バックアップ・ロック

```elisp
(setq make-backup-files        nil)   ; no *.~ backup files
(setq auto-save-default        nil)   ; no auto-save
(setq create-lockfiles         nil)   ; no .#lockfiles
(setq vc-follow-symlinks       t)     ; follow symlinks without asking
(setq require-final-newline    t)     ; always end file with newline
```

### 3.3. 履歴・データファイルの一元管理

各種履歴やキャッシュファイルをすべて `~/.emacs.d/tmp/` 配下に集約しています。

```elisp
(setq auto-save-list-file-prefix  (locate-user-emacs-file "tmp/auto-save-list/.saves-"))
(setq tramp-persistency-file-name (locate-user-emacs-file "tmp/tramp"))
(setq request-storage-directory   (locate-user-emacs-file "tmp/request"))
(setq url-configuration-directory (locate-user-emacs-file "tmp/url"))
(setq bookmark-default-file       (locate-user-emacs-file "tmp/bookmarks"))
(setq save-place-file             (locate-user-emacs-file "tmp/places"))
(setq project-list-file           (locate-user-emacs-file "tmp/projects"))
```

`savehist` は `tmp/savehist` に保存し、`extended-command-history` と `my-describe-history` も追加で永続化します（履歴は 200 件・重複削除あり）。`recentf` は `elpa`・`tmp`・`Dropbox/backup`・`neomutt-` バッファなどを除外し、最大 100 件を `tmp/recentf` に保存します。いずれも `after-init-hook` で有効化します。

### 3.4. 編集全般のデフォルト

```elisp
(setq completion-ignore-case              t)   ; case-insensitive completion
(setq read-file-name-completion-ignore-case t)
(setq scroll-preserve-screen-position    t)    ; point stays on scroll
(setq ring-bell-function                'ignore) ; no bell
(setq visible-bell                       nil)
(setq mouse-drag-copy-region             t)    ; mouse selection copies
(setq select-enable-clipboard            t)    ; use X11 clipboard
(setq uniquify-buffer-name-style        'post-forward-angle-brackets)
(setq-default cursor-in-non-selected-windows nil)
(set-fringe-mode 1)

(defalias 'yes-or-no-p 'y-or-n-p)
(defalias 'exit-emacs  'save-buffers-kill-emacs)
```

### 3.5. ゴミ箱

```elisp
(setq delete-by-moving-to-trash t)
(setq trash-directory (locate-user-emacs-file "tmp/trash"))
(advice-add 'move-file-to-trash :before
            (lambda (&rest _)
              (unless (file-exists-p trash-directory)
                (make-directory trash-directory t))))
```

`tmp/trash` が存在しなければ自動で作成してから移動するよう `advice-add` しています。

### 3.6. モード関連付けとグローバルマイナーモード

```elisp
(leaf *auto-mode
  :config
  (dolist (pair '(("\\.\\(?:tmux\\.conf\\|muttrc\\|xprofile\\|Xmodmap\\)\\'" . conf-mode)
                  ("\\.\\(?:gitattributes\\|gitignore\\|vimrc\\)\\'"         . conf-mode)
                  ("/crontab\\(\\..*\\)?\\'" . conf-mode)
                  ("\\.cgi\\'"               . perl-mode)
                  ("/passwd/.*\\.cgi\\'"     . text-mode)))
    (add-to-list 'auto-mode-alist pair)))

(add-hook 'after-init-hook #'global-auto-revert-mode)
(add-hook 'after-init-hook #'save-place-mode)
(add-hook 'after-init-hook #'savehist-mode)
(add-hook 'after-init-hook #'recentf-mode)
```

### 3.7. キーバインドとユーザー関数

```elisp
(leaf *user-commands
  :hook ((find-file-hook . my-view-mode-maybe)
         (find-file-hook . my-read-only-maybe))
  :bind (("C-x b"      . ibuffer)
         ("C-x m"      . counsel-imenu)
         ("M-,"        . xref-find-definitions)
         ("M-w"        . clipboard-kill-ring-save)
         ("C-w"        . my-clipboard-kill-region)
         ("M-/"        . kill-current-buffer)
         ("s-c"        . clipboard-kill-ring-save)
         ("s-v"        . clipboard-yank)
         ("C-q"        . other-window-or-split)
         ("C-<tab>"    . quoted-insert)
         ("S-<return>" . (lambda () (interactive) (end-of-line) (newline)))))
```

`*.log` を開くと自動で `view-mode`（＋ evil-emacs-state）に、`*.dat` を開くと自動で read-only にする `find-file-hook` を追加しています。`C-w` はリージョンがあれば `clipboard-kill-region`、なければ `backward-kill-word` として働く `my-clipboard-kill-region` にバインドしています。最後のフレームを閉じようとしたとき、削除せず最小化する `handle-delete-frame` の上書きも設定しています。


## 4. ダッシュボード（01-dashboard.el）

起動画面として `dashboard` を使用しています。

```elisp
(leaf dashboard
  :ensure t
  :if (display-graphic-p)
  :hook ((emacs-startup-hook  . open-dashboard)
         (dashboard-mode-hook
          . (lambda () (set-window-margins (selected-window) 2 2))))
  :bind ([home] . dashboard-toggle)
  :init
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons    t)
  (setq dashboard-icon-type        'nerd-icons))
```

`[home]` キーで dashboard と直前のバッファをトグル表示できます。

### 4.1. セパレーター

`page-break-lines` に依存せず、ウィンドウ幅に追従する水平線を自前で描画する `my-dashboard-separator` を `dashboard-page-separator` に設定しています。`dashboard-refresh-buffer` の前に `advice-add` で毎回幅を再計算します。

### 4.2. 今日の一句（seiho-haiku）

`seiho-haiku.el`（`elisp/` 配下のローカルパッケージ）に阿波野青畝の俳句データ 366 句が収録されています。`dashboard-item-generators` に `haiku` ウィジェットを追加し、マシンごとに表示内容を切り替えます。

```elisp
;; P1: 一句 + 最近使ったファイル 5件 / それ以外: 一句のみ
(if (string-match "P1" (system-name))
    (setq dashboard-items '((haiku . 1) (recents . 5)))
  (setq dashboard-items '((haiku . 1))))
```

### 4.3. バナータイトルの動的生成

```elisp
(setq dashboard-startup-banner  "~/.emacs.d/emacs.png")
(setq dashboard-banner-logo-title
      (let* ((uname  (split-string (shell-command-to-string "uname -rn")))
             (debian (string-trim (shell-command-to-string "cat /etc/debian_version"))))
        (format "GNU Emacs %s kernel %s Debian %s x86_64 GNU/Linux"
                emacs-version (cadr uname) debian)))
```

フッターには自作のメッセージと `nerd-icons` のホームアイコンを表示します。`emacs-init-time` にも `advice-add` して、起動時間を「%.3f seconds」形式に整形して表示しています。


## 5. Evil Mode（02-evil.el）

vi/vim スタイルの操作体系を導入しています。

### 5.1. 基本方針

insert state は自動的に emacs state に変換します。これにより、insert 状態では通常の Emacs キーバインドがそのまま使えます。

```elisp
(defalias 'evil-insert-state 'evil-emacs-state)
```

誤操作を防ぐため、`i` 以外の編集トリガーキーをすべて無効化しています。

```elisp
(dolist (key '("I" "a" "A" "o" "O" "s" "S" "c" "C" "R"))
  (keymap-set evil-normal-state-map key #'ignore))
```

`:q` / `:wq` は `kill-current-buffer` にマップし、Emacs 終了を防いでいます。howm サマリー・easy-hugo・YaTeX・neotree・fundamental-mode は強制的に emacs-state で開きます。また、ファイルが未存在（新規作成）の場合も自動的に emacs-state になります（`my-evil-emacs-state-for-new-file`）。

### 5.2. normal state のキーバインド

| キー | コマンド |
|------|---------|
| `C-a` | my-seq-home（行頭→バッファ先頭、08-edit.el 参照） |
| `C-e` | my-seq-end（行末→バッファ末尾、08-edit.el 参照） |
| `SPC` | evil-scroll-page-down |
| `b` | evil-scroll-page-up |
| `i` | my-emacs-state-mozc（emacs-state に切替えて mozc ON） |
| `@` | evil-visual-char |
| `_` | evil-visual-line |
| `?` | my-evil-cheat-sheet |
| `[home]` | dashboard-toggle |
| `[muhenkan]` | my-quit-dwim |
| `[escape]` | my-evil-toggle-state |

visual state では `PgUp`/`PgDn` で選択範囲を拡大・縮小（`expand-region`）、`;` でコメント、`c` でコピー、`s` で swiper、`g` で Google 検索、`d` で DeepL 翻訳、`[insert]` で iedit のトグルが使えます。emacs state でも `C-a`/`C-e` と `[insert]`（iedit）、`[escape]`（トグル）は共通です。

### 5.3. [muhenkan] 万能脱出キー（my-quit-dwim）

`my-quit-dwim` は文脈に応じて動作します。

| 状況 | 動作 |
|------|------|
| iedit-mode 中 | iedit を終了して normal-state へ |
| `*Help*` バッファ表示中 | バッファを閉じる |
| ミニバッファ使用中 | `abort-minibuffers` |
| 別ウィンドウのミニバッファ | フォーカスして `abort-recursive-edit` |
| リージョン選択中 | 選択解除 |
| ウィンドウが複数 | 1枚に統合（`delete-other-windows`） |
| evil normal state | emacs state へ切替 |
| それ以外 | IME を無効化して evil normal state へ |

mozc 起動中は mozc-mode-map が無変換キーを奪うため、`with-eval-after-load 'mozc` で `my-quit-dwim` を上書きしています。

### 5.4. ESC キー：state トグル

`[escape]` は `my-evil-toggle-state` にバインドされ、normal ⇄ emacs state を単純にトグルします（muhenkan とは別の独立したコマンドです）。

### 5.5. iedit 連携

```elisp
(leaf iedit
  :ensure t
  :after evil)
```

`my-iedit-toggle`（visual/emacs state の `[insert]` キー）で、選択リージョンがあればそれを対象に emacs-state + iedit を起動します。もう一度呼ぶと iedit を終了して normal-state に戻ります。

### 5.6. 手動 emacs-state からの自動復帰

`i` などで手動的に normal → emacs state に切り替えたバッファは、そこから離れて別のバッファに移動したタイミングで自動的に normal-state へ戻します（`*` で始まる特殊バッファや `evil-emacs-state-modes` に属するメジャーモードは対象外）。`evil-normal-state-exit-hook` と `post-command-hook` の組み合わせで実現しています。

### 5.7. j/k・p/P の入れ替え

折り返し行を自然に移動できるよう `j`/`k` と `gj`/`gk` を入れ替えています。また `p`/`P` も入れ替え、Emacs 標準の「p でポイントに貼り付け、P でポイントの後に貼り付け」に近い挙動にしています。

### 5.8. normal state リーダーキー「;」

normal state を抜けずに軽微な編集を完結させるための仕組みです。

| キー | コマンド |
|------|---------|
| `;f` | counsel-find-file |
| `;/` | kill-current-buffer |
| `;;` | comment-line |
| `;o` | 上に空行挿入（my-newline-above） |
| `;c` | my-sen-cleanup |
| `;r` | my-sen-restore |
| `;@` | 行頭に ◎ 挿入（俳句選者用、my-insert-maru） |

### 5.9. [evil-cheat-sheet] チートシート

`my-evil-cheat-sheet.el`（`elisp/` 配下）で、`?` キーから右サイドバーに evil の主要キーバインド一覧（移動・編集・operator+motion・visual-state・normal-state に留まるコツ）を静的テキストで表示します。`q` で閉じます。


## 6. 補完・検索

### 6.1. [ivy] 補完フレームワーク（03-ivy.el）

`ivy` を使用しています。

```elisp
(leaf ivy
  :ensure t
  :hook (after-init-hook . ivy-mode)
  :bind (:ivy-minibuffer-map
         ("<down>" . ivy-next-line)
         ("<up>"   . ivy-previous-line))
  :config
  (key-chord-define-global "df" 'my-describe-command)
  (key-chord-define-global "fg" 'my-describe-variable)
  (setq ivy-use-virtual-buffers      t)
  (setq ivy-use-selectable-prompt    t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-extra-directories        nil))
```

`df` の同時押しで `my-describe-command`（コマンドをキーバインド付きで ivy 検索）、`fg` で `my-describe-variable`（変数を ivy 検索）を起動します。

#### 6.1.1. [ivy-rich] リッチ表示

```elisp
(leaf ivy-rich :ensure t
  :hook (after-init-hook . ivy-rich-mode))
```

### 6.2. [counsel] 各種補完（04-counsel.el）

```elisp
(leaf counsel
  :ensure t
  :bind (("C-:"     . counsel-switch-buffer)
         ("C-x C-f" . counsel-find-file)
         ("C-x f"   . counsel-find-file)
         ("C-x g"   . counsel-git)
         ("s-a"     . counsel-git-grep)
         ("M-x"     . counsel-M-x)
         ("M-y"     . counsel-yank-pop)
         ("C-,"     . counsel-mark-ring)))
```

`C-x g` でプロジェクト内のファイル検索、`s-a` でプロジェクト内の全文検索（`counsel-git-grep`）を行います。選択行には nerd-icons のシェブロンアイコンを使ったカスタム表示（`my-ivy-format-function-arrow`）を適用しています。

#### 6.2.1. [amx] M-x 履歴強化

```elisp
(leaf amx :ensure t
  :config
  (setq amx-save-file (locate-user-emacs-file "tmp/amx-items"))
  (setq amx-history-length 20))
```

#### 6.2.2. [swiper] インクリメンタル検索

```elisp
(leaf swiper :ensure t
  :bind (("C-s" . swiper-region)
         ("s-s" . swiper-thing-at-point)))
```

`C-s` にバインドした `swiper-region` は、リージョン選択中は `swiper-thing-at-point`、非選択時は通常の `swiper` として機能します。

#### 6.2.3. [migemo] 日本語インクリメンタル検索

```elisp
(leaf migemo :ensure t
  :hook (after-init-hook . migemo-init)
  :config
  (setq migemo-command    "/usr/bin/cmigemo")
  (setq migemo-options    '("-q" "--emacs"))
  (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict"))
```

`swiper` のみ `my-ivy-migemo-re-builder` を使い、ローマ字入力で日本語を検索できます。スペースは `.*?` に変換され、複数キーワードの柔軟な検索が可能です。

### 6.3. [company] 自動補完（05-company.el）

```elisp
(leaf company :ensure t
  :hook (after-init-hook . global-company-mode)
  :bind (("<backtab>" . company-complete)
         (:company-active-map
          ("<tab>"      . company-complete-common-or-cycle)
          ("<backtab>"  . company-select-previous)
          ("<muhenkan>" . company-abort))))
```

全バックエンドに yasnippet を自動付加する設定（`company-mode/backend-with-yas`）を入れています。アイコン表示は `company-dot-icons-margin` を使用します。

### 6.4. [yasnippet] スニペット

```elisp
(leaf yasnippet :ensure t
  :hook ((after-init-hook . yas-global-mode)
         (prog-mode-hook  . yas-minor-mode))
  :config
  (setq yas-indent-line 'fixed)
  (setq yas-snippet-dirs '("~/.emacs.d/snippets")))
```


## 7. 日本語入力（06-mozc.el）

### 7.1. 基本設定

```elisp
(leaf mozc :ensure t
  :hook (after-init-hook . mozc-mode)
  :bind* (("<hiragana-katakana>" . my-toggle-input-method)
          ("<f13>"               . my-toggle-input-method))
  :bind (("s-m" . my-mozc-config)
         ("s-d" . my-mozc-word-regist)
         (:mozc-mode-map
          ("," . (lambda () (interactive) (mozc-insert-str "、")))
          ("." . (lambda () (interactive) (mozc-insert-str "。")))))
  :config
  (setq default-input-method "japanese-mozc")
  (setq mozc-leim-title       "あ"))
```

`my-toggle-input-method` は evil-emacs-state のときのみ IME を切り替えます。句読点は mozc を介さず即時挿入します（`mozc-insert-str`）。`<f13>` でも同様の操作ができます。

### 7.2. mozc ツール起動

| キー | 機能 |
|------|------|
| `s-m` | 設定ダイアログ（my-mozc-config） |
| `s-d` | 単語登録ダイアログ（my-mozc-word-regist） |

### 7.3. mozc-cand-posframe

変換候補を `posframe` でポップアップ表示します。doom-dracula テーマに合わせた配色を設定しています。

### 7.4. カーソル色による状態表示

evil state と mozc の入力モードをカーソル色で視覚的に示します。0.1 秒のアイドルタイマーで更新します。

| 状態 | カーソル色 |
|------|---------|
| normal state（visual より優先度は低いが実質最初に評価） | `#50fa7b`（緑） |
| direct（emacs-state かつ mozc OFF） | `#ffb86c`（オレンジ） |
| hiragana（emacs-state かつ mozc ON） | `#B33A3A`（赤） |
| read-only | `#6272A4`（グレー青） |
| visual state | `#F1FA8C`（黄） |


## 8. 外部ツール・SSH（07-functions.el）

F1〜F12 キーのバインドをここで一元管理しています。

| キー | コマンド |
|------|---------|
| `<f1>` | help-command（built-in） |
| `<f2>` | my-neotree-toggle（70-neotree.el） |
| `<f3>` | terminal-open-this（gnome-terminal） |
| `<f4>` | xsrv-open-this（SSH でサーバーに接続） |
| `<f5>` | my-quickrun（30-utils.el） |
| `<f6>` | thunar-open-this |
| `<f7>` | calendar（90-calendar.el） |
| `<f8>` | my-darkroom-toggle（90-darkroom.el） |
| `<f9>` | display-line-numbers-mode（built-in） |
| `<f10>` | toggle-scratch-buffer |
| `<f11>` | toggle-frame-fullscreen（built-in） |
| `<f12>` | toggle-emacs（最小化/復元スクリプト） |

### 8.1. 外部モニター対応の gnome-terminal 起動

`my-external-monitor-geometry` で `xrandr` の出力を解析し、内蔵ディスプレイ（`eDP*`）以外の外部モニターが接続されていればその座標を取得します。`my-launch-gnome-terminal` はこの結果を使って、外部モニター接続時は gnome-terminal をそちらに配置します。`terminal-open-this`・`xsrv-open-this`・dired の vim/nano 起動（40-dired.el）・quickrun（30-utils.el）など、複数の機能がこのヘルパーを共有しています。

### 8.2. xsrv-open-this

`<f4>` は dired バッファでのみ動作し、カレントディレクトリが `xsrv-mirror-map`（`~/Dropbox/GH/` / `~/Dropbox/minorugh.com/`）配下であれば、対応する xsrv 上のパスに変換して SSH ターミナルを開きます。対象外のディレクトリでは `user-error` を出します。

### 8.3. scratch バッファの永続化

`after-init-hook` で `tmp/scratch` から復元し、`kill-emacs-hook` で書き出します。`<f10>`（`toggle-scratch-buffer`）で `*scratch*` と直前のバッファをトグルします。


## 9. 編集サポート（08-edit.el）

### 9.1. [expand-region]

```elisp
(leaf expand-region :ensure t
  :bind (("C-@"   . er/expand-region)
         ("C-M-@" . er/contract-region)))
```

### 9.2. [super-save] スマート自動保存

```elisp
(leaf super-save :ensure t
  :hook (after-init-hook . super-save-mode)
  :config
  (setq super-save-auto-save-when-idle t)
  (setq super-save-idle-duration       1)
  (setq super-save-remote-files        nil)
  (setq super-save-exclude             '(".gpg")))
```

アイドル 1 秒で自動保存します。リモートファイルと `.gpg` は除外します。

### 9.3. [undo-fu] / [undo-fu-session]

```elisp
(leaf undo-fu :ensure t
  :bind (("C-_" . undo-fu-only-undo)
         ("C-/" . undo-fu-only-redo)))

(leaf undo-fu-session :ensure t
  :hook (after-init-hook . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-directory (locate-user-emacs-file "tmp/undo-session")))
```

evil の undo システムも `undo-fu` に統一しています（`evil-undo-system 'undo-fu`、02-evil.el）。undo 履歴はセッションをまたいで `tmp/undo-session/` に永続化します（以前使用していた `undohist` から乗り換えました）。

### 9.4. Diff / Ediff・Electric モード

```elisp
(leaf ediff :tag "builtin"
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-diff-options          "-twB"))

(leaf elec-pair :tag "builtin"
  :hook ((after-init-hook . electric-pair-mode)
         (text-mode-hook  . (lambda () (electric-pair-local-mode -1)))))
```

`electric-pair-mode` は `text-mode` 系では無効化しています（yasnippet 側で括弧補完するため）。`C-c i`（`my-indent-buffer`）でバッファ全体の untabify + インデントを行えます。

### 9.5. 連続 C-a / C-e

以前は外部パッケージ（sequential-command のフォーク）を利用していましたが、現在は `my-define-seq-command` マクロを自前で定義し、`08-edit.el` 内に直書きしています。

```elisp
(my-define-seq-command my-seq-home
                       beginning-of-line beginning-of-buffer my-seq-return)
(my-define-seq-command my-seq-end
                       end-of-line end-of-buffer my-seq-return)
```

* `C-a` を連続で押すと 行頭 → バッファ先頭 → 元の位置
* `C-e` を連続で押すと 行末 → バッファ末尾 → 元の位置

ポイントが動かない（no-op な）コマンドは自動でスキップします。これらは 02-evil.el の normal/emacs state で `C-a`/`C-e` にバインドされています。

### 9.6. Revert Buffer

`jk`（key-chord）で、未保存の変更がなければ確認なしにバッファを revert する `my-revert-buffer` を実行します。


## 10. Makefile 連携（09-makefile.el）

`makefile-mode` / dired から `@` キーでターゲットを ivy 選択して実行できる仕組みで、実体は外部スクリプト `make-run.sh` への一本化された呼び出し口として設計されています。

### 10.1. 全体構成

```
*compile ....... 出力の「見せ方」（##> マーカー規約の共通ヘルパー、
                  ライブ compile 用ハンドラ、静的ログビューア）
   ↓ 使う
*make-run ...... make-run.sh を実行する2種類の関数
                   - my-make-run-compile（compile 経由、ivy 用）
                   - my-make-run-async（撃ちっぱなし、hydra 用）
   ↓ 使う
*makefile-mode . makefile-mode / dired での UX（@ キー、read-only 自動管理）
   ↓ 使う
*make-target ... @ で起動する ivy ターゲットピッカー本体
```

実行経路は最終的に3系統あります。

1. `@` → ivy → `C-c C-c` → `my-make-run-compile` → `compile`
2. hydra `]`（`my-make-git`） → `my-make-run-async` → `start-process`
3. ターミナルから `make-run.sh` を直接叩く（Emacs 非経由）

いずれも `make-run.sh` 側で `##!` 判定・gnome-terminal への委譲を行います。

### 10.2. `##>` マーカー規約とコンパイル出力

ターゲット側のレシピで `echo '##> メッセージ'` すると、成功時にそのメッセージがエコーエリアに表示されます（`##>` 単体行はバッファ上で不可視化されます）。`compile-autoclose` はコンパイル成功時にウィンドウを自動で閉じ、`##>` のみだった場合はバッファを全画面表示します。失敗時はメッセージのみ表示します。

`my-make-show-log` は `make-run.sh` の gnome-terminal 実行結果（静的ログ）を `emacsclient -e` 経由で受け取り、`*make-run-log*` バッファに compilation-mode で表示する関数で、`make-run.sh` 自身から呼ばれます。

### 10.3. Ivy 統合 Makefile ターゲット選択

`@` キー（makefile-mode・dired-mode）で `my-make-ivy-integrated` を起動します。Makefile 中の `target: ## コメント` 形式のコメント付きターゲットのみを一覧表示し、矢印キーでターゲット定義箇所へリアルタイムプレビュー、`C-c C-c` で実行します。`##!` 付きターゲット（対話的実行が必要なもの）は候補に ⚠ マークを表示します。

### 10.4. read-only 管理

`makefile-mode` のバッファは既定で read-only になっており、`C-c C-e` または `qq`（key-chord）でトグルできます。フォーカスが外れた Makefile バッファは自動的に read-only へ戻ります。


## 11. 構文チェック（10-flymake.el）

`flycheck` ではなく `flymake`（built-in）を使用しています。`prog-mode` と `markdown-mode` で有効化し、`lisp-interaction-mode` では無効化します。

```elisp
(leaf flymake :tag "builtin"
  :hook ((prog-mode-hook     . flymake-mode)
         (markdown-mode-hook . flymake-mode)
         (lisp-interaction-mode-hook . (lambda () (flymake-mode 0)))))
```

`elisp-flymake-byte-compile` が信頼できないコンテンツに対して出す "Disabling elisp-flymake-byte-compile" というメッセージ通知と `user-error` を、それぞれ `advice-add` でフィルタ・握りつぶすことで、バッファ編集中に flymake が余計な通知や停止を起こさないようにしています。


## 12. リージョン操作（20-selected.el）

`selected.el` の代わりに `my-selected-mode`（自作マイナーモード）でリージョン選択時のワンキーアクションを実装しています。

```elisp
(keymap-set my-selected-mode-map ";" #'comment-dwim)
(keymap-set my-selected-mode-map "c" #'kill-ring-save)
(keymap-set my-selected-mode-map "s" #'swiper-region)
(keymap-set my-selected-mode-map "g" #'my-google-search)
(keymap-set my-selected-mode-map "w" #'my-weblio-search)
(keymap-set my-selected-mode-map "d" #'deepl-translate)
```

リージョン選択開始時（`activate-mark-hook`）に IME を自動 OFF、解除時（`deactivate-mark-hook`）に元の状態に戻します。`post-command-hook` でリージョンの有無を監視し、`my-selected-mode` を自動でトグルします。


## 13. UI・外観（30-ui.el）

### 13.1. テーマ

`doom-themes` の `doom-dracula` を使用しています。

```elisp
(leaf doom-themes :ensure t
  :hook (after-init-hook . (lambda () (load-theme 'doom-dracula t)))
  :config (setq doom-themes-enable-italic nil))
```

### 13.2. カーソルとハイライト

`hl-line`（built-in）でカーソル行をハイライトします。region の背景色と hl-line をテーマに合わせてカスタムしています。dashboard と calendar のバッファでは `my-disable-hl-line` で無効化します。`blink-cursor` は無限点滅（`blink-cursor-blinks 0`）・0.3 秒間隔に設定しています。

### 13.3. 行番号・fill-column インジケーター・対応括弧

`display-line-numbers`（built-in）を `prog-mode` / `text-mode` で有効化します（`lisp-interaction-mode` は除外）。`<f9>` でトグルできます。`display-fill-column-indicator`（built-in）を gfm-mode / text-mode で有効化し、79 列目にガイドラインを表示します。`show-paren-mode` と `rainbow-delimiters` で括弧の対応関係を可視化しています。

### 13.4. [whitespace] 行末スペースの表示と削除

`whitespace-style` を `'(face trailing)` に絞り、`prog-mode` / `markdown-mode` で行末スペースのみを赤くハイライトします（`text-mode` では無効化）。`C-c s`（`my-cleanup-for-spaces-safe`）で行末空白の削除と UTF-8 エンコーディングの保証を行います。

### 13.5. アイコン

`all-the-icons` から `nerd-icons` に移行しています。`nerd-icons-dired-mode` で dired バッファにアイコンを表示します（`nerd-icons-scale-factor 0.8`）。初回は `M-x nerd-icons-install-fonts` でフォントをインストールしてください。

### 13.6. [doom-modeline] / [nyan-mode] モードライン

```elisp
(leaf doom-modeline :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :config
  (setq doom-modeline-icon             t)
  (setq doom-modeline-major-mode-icon  nil)
  (setq doom-modeline-minor-modes      nil)
  (setq doom-modeline-percent-position nil)
  (line-number-mode   0)
  (column-number-mode 0))

(leaf nyan-mode :ensure t
  :hook (doom-modeline-mode-hook . (lambda () (nyan-mode 2)))
  :config
  (setq nyan-animate-nyancat t)
  (setq nyan-bar-length 26))
```

`nyan-mode` を新たに導入し、バッファ内の位置をモードライン上に猫のアニメーションで表示しています。

### 13.7. アクティブウィンドウのモードライン強調

dimmer-mode の代わりに、実ウィンドウが 2 つ以上表示されているときアクティブなモードラインを紫のボーダー（`#bd93f9`）で強調する自作の仕組みです。minibuffer・hydra・Flymake・changelog・Calendar・Compilation・which-key・evil-cheat・YaTeX 関連・Permission Help などのポップアップウィンドウはカウントから除外します（`my-modeline-popup-window-p`）。ウィンドウ／バッファ構成変更のたびに 0.2 秒のアイドルタイマーで再計算します。


## 14. ユーティリティ（30-utils.el）

### 14.1. [which-key]

Emacs 29 built-in になりました。`which-key-idle-delay 0.0` で即時表示します。

### 14.2. [quickrun]

```elisp
(leaf quickrun :ensure t
  :config
  (defun my-quickrun ()
    "Dired なら外部ターミナルで実行ファイルを実行、それ以外は quickrun。"
    ...))
```

`<f5>` にバインドされた `my-quickrun` は、dired バッファではカーソル位置の実行ファイルを外部ターミナルで（実行後も閉じずに）起動し、それ以外のバッファでは通常の `quickrun` を実行します。

### 14.3. [browse-at-remote]

GitHub 上の対応ページをブラウザで開きます（hydra-dired の `@` キー）。

### 14.4. [tempbuf] 未使用バッファの自動削除

```elisp
(leaf tempbuf :tag "local"
  :hook ((find-file-hook  . turn-on-tempbuf-mode)
         (dired-mode-hook . turn-on-tempbuf-mode)))
```

以前は GitHub からの `:vc` インストールでしたが、EmacsWiki 限定配布のためメンテナンス性を考慮し、フォーク版を `elisp/tempbuf.el` に直接配置する方式に変更しています。使われていないバッファをバックグラウンドで自動 kill します。xsrv の rsync lock 機能（40-remote.el）と連携しています。

### 14.5. パッケージ管理 hydra

`p@`（key-chord）で起動します。

```
Package: _l_og  _i_nstall  _d_elete  _u_pgrade  up-_a_ll  _v_c-up-all
```

### 14.6. Gist / Lepton 連携

`gist-region-or-buffer`（`C-x l` は `my-open-lepton`）でリージョンまたはバッファ全体を Gist に投稿し、`my-open-lepton` で Lepton（GitHub Gist クライアント）を起動します。

### 14.7. Changelog 全文検索（my-changelog-search）

`~/Dropbox/CHANGELOG/` 配下の `changelog-*.md` を Perl スクリプト（`search.pl`、migemo 対応）経由で全文検索し、結果を `grep-mode` バッファに表示します。プレフィクス引数（`C-u`）で大文字小文字を区別する検索になります。hydra-dired の `l` キーから呼び出せます（後述）。

### 14.8. PostScript 印刷

`lpr` コマンドが存在する場合のみ、日本語対応の PostScript 印刷設定（A4・行番号あり・Courier 10pt）を行います。


## 15. ファイラー（Dired・40-dired.el）

### 15.1. 基本設定

```elisp
(setq dired-listing-switches "-AlhF --group-directories-first --no-group")
(setq dired-omit-files       "^\\.$\\|^\\.[^\\.].*$\\|\\.elc$")
(setq dired-dwim-target t)
(setq dired-recursive-copies  'always)
(setq dired-recursive-deletes 'always)
```

Emacs 30 の file-name 補完を dired のコピー時に上書きしないよう、`ivy-completing-read-handlers-alist` に `dired-do-copy` の除外設定を追加しています。

### 15.2. キーバインド

| キー | 機能 |
|------|------|
| `<left>` | 親ディレクトリへ（同バッファ、my-dired-up） |
| `<right>` / `RET` | ファイルは新バッファ、ディレクトリは同バッファ（my-dired-open） |
| `w` | wdired モード |
| `s` | sudo で削除（my-dired-sudo-rm） |
| `o` | xdg-open で関連アプリで開く |
| `v` | 外部ターミナルで Vim を起動 |
| `n` | 外部ターミナルで GNU nano を起動 |
| `a` | dired-omit-mode トグル |
| `[` | hide-details-mode |
| `t` | my-open-tig（my-tig-bridge.el） |
| `]` | gitk（my-dired-gitk） |
| `p` | パーミッション早見表 |
| `.` | xsrv deploy（40-remote.el） |
| `,` | xsrv download（40-remote.el） |
| `i` | sxiv で画像一覧表示（my-sxiv） |

### 15.3. omit モードの制御

`~/`・`~/.env_source/`・xsrv-GH/minorugh.com/dotfiles のミラー・`dotfiles/env/` など特定ディレクトリでは omit を無効化し、隠しファイルを表示します。

### 15.4. 秘密情報ディレクトリの視覚的警告

`~/.env_source/` や `dotfiles/env/`（bindfs でマウントされた秘密情報リポジトリの窓）配下の dired バッファは、背景色（`#3a1a1a`）で通常の作業ディレクトリと区別できるようにしています。

### 15.5. パーミッション早見表

`p` キーで `*Permission Help*` バッファを右サイドバーに固定表示します。


## 16. リモート・xsrv 連携（40-remote.el）

xsrv（Xserver）との連携設定をすべてここに集約しています。

### 16.1. 2段階構成のコンセプト

FileZilla のようにサーバーへ直接繋いで転送するのではなく、「サーバー → ミラー（xsrv-GH／xsrv-minorugh） → ローカル（Dropbox）」という2段階構成にしています。ミラーはサーバー側の変更を一旦受け止めて目視できる検疫スペースとして機能し、予期しない変更が確認なしに作業コピーへ流れ込むことを防ぎます。

* サーバー → ミラー：`xsrv-backup-smart.sh`（elisp/bin/）による自動 rsync
* ミラー → ローカル：2ペインの dired で目視しながら、必要なファイルだけを選んで取り込む

deploy（`xsrv-deploy-dired`）と download（`xsrv-download-dired`）が非対称な設計なのもこのためです。deploy はローカルで確定した内容を能動的にサーバーへ送るだけですが、download は宛先を `my-xsrv-roots` の対応表で固定し、確認ダイアログを必須にして誤上書きを防いでいます。

### 16.2. xsrv ルート判定

```elisp
(defconst my-xsrv-roots
  `((,(expand-file-name "~/src/github.com/minorugh/xsrv-GH/")
     . ,(expand-file-name "~/Dropbox/GH/"))
    (,(expand-file-name "~/src/github.com/minorugh/xsrv-minorugh/")
     . ,(expand-file-name "~/Dropbox/minorugh.com/"))))
```

### 16.3. Deploy / Download（dired キーバインド、40-dired.el で定義）

* `.` キー（`xsrv-deploy-dired`）：dired カーソル位置のファイルをサーバーに deploy（Makefile・README・`.mk`・`.bak` は対象外）
* `,` キー（`xsrv-download-dired`）：xsrv-GH/xsrv-minorugh からローカル Dropbox にダウンロード。既存ファイルへの上書きは確認あり

### 16.4. xsrv-2pane 表示

`my-open-xsrv-2pane` で xsrv 側とローカル Dropbox 側を左右分割で表示します。各ペインの上 2 行を `header-line-format` に固定表示し（`[REMOTE]`/`[LOCAL]` ラベル付き、背景 `#1A2640`）、本体側の該当行は不可視化します。ウィンドウ分割線（divider）は水色（`#61bfff`）で強調します。`q`（`my-dired-quit`）で 2 ペインを閉じて元のバッファに戻ります。

### 16.5. [git-peek] コミット差分プレビュー

Claude と共同開発した自作パッケージで、`elisp/git-peek.el` に直接配置し `autoload` しています（以前の GitHub 経由 `package-vc-install` から移行）。git 管理下のファイルの過去バージョンを ivy で選択し、左右分割のサイドバー UI でプレビューしながら保存できます。

主な機能：

* 左サイドバーにコミット一覧、右にリアルタイムプレビュー
* `s` で保存、`q` で元のウィンドウ配置に復元
* `C-d` で全文表示 ↔ diff 表示をトグル
* `git-peek-deleted` で削除済みファイルの過去バージョンも取り出せる
* `my-git-peek-smart`（hydra-dired の `[` キー）は xsrv 配下では保存先を対応するミラー側パスへ自動調整し、実行後に xsrv-2pane を自動復元します

詳しくは「[Emacs から git の過去ファイルを手軽に取り出す](https://qiita.com/minoruGH/items/c36c5f31ea3d3c725d8f)」（Qiita）を参照してください。

### 16.6. 動的フォルダー保護 & rsync lock

gospel-haiku の動的フォルダー（kukai/data・voice など、`my-xsrv-dynamic-dirs`）を自動 read-only 化します。read-only を解除すると `~/xsrv-rsync.lock` を発行して rsync を停止し、対象の編集中バッファがゼロになったら自動で lock を解除します。`tempbuf` との連携で unlock し忘れを防ぎます。

### 16.7. xsrv 配下バッファの背景色

xsrv-GH / xsrv-minorugh 配下のファイルバッファは背景色（`#233B6C`）で識別できます。

### 16.8. my-tig-bridge

`my-tig-bridge.el` で tig と git-peek を連携させています。dired の `t` キーで tig を gnome-terminal で起動し、ファイルパスを `/tmp/tig-peek-context` に書き出します。tig 側で `E` キー（`~/.tigrc` に `bind generic E` の設定が必要）を押すと `emacsclient` 経由で `git-peek-from-hash` が呼ばれ、選択したコミットを git-peek で開きます。


## 17. メモ環境（50-howm.el）

### 17.1. [howm] Wiki 型メモ

```elisp
(leaf howm :ensure t
  :commands (howm-list-all my-howm-create-with-category)
  :hook (emacs-startup-hook . howm-mode)
  :init
  (setq howm-directory        "~/Dropbox/howm")
  (setq howm-file-name-format "%Y/%m/%Y%m%d%H%M.md")
  (setq howm-view-title-header "="))
```

メモは `~/Dropbox/howm/` に Markdown 形式（`.md`）で保存します。ファイル名は `%Y/%m/%Y%m%d%H%M.md` の形式です。タイトルヘッダーは `=`（howm デフォルトの `*` から変更）。migemo にも対応しています。howm サマリーバッファでは `,,`（key-chord）で `my-howm-create-with-category`、`@@` で `howm-list-all` を起動します。

### 17.2. カテゴリ定義

通常カテゴリと特殊エントリの 2 種類を定義しています。

| キー | カテゴリ | 挿入文字列 |
|------|---------|---------|
| `m` | memo | `memo: ` |
| `i` | idea | `idea: ` |
| `t` | tech | `tech: ` |
| `d` | 日記 | `日記: ` |
| `g` | 園芸 | `園芸: ` |

特殊エントリ（`c`=code/Perlスクラッチ、`p`=創作/俳句ノート新規、`n`=推敲/俳句ノート）は外部関数に委譲します。

### 17.3. カテゴリ色分け

カテゴリごとにフェイスを定義し、記事バッファとサマリーバッファの両方に適用します。ライト/ダークテーマ対応の配色を設定しています。

### 17.4. メモ作成（my-howm-create-with-category）

`,,` または howm サマリーの `,` で起動します。縦リストでカテゴリを表示し、1 キーで選択して新規メモを作成します。特殊エントリは対応する関数を呼び出します。

### 17.5. カテゴリ検索（my-howm-search-by-category）

howm サマリーの `/` または howm-mode の `C-c /` で起動します。ivy でカテゴリを選択し、そのカテゴリのメモ一覧を表示します。

### 17.6. ゴミ箱への移動（my-howm-move-to-trash）

howm サマリーの `d` でカーソル行のメモを `tmp/trash/` に移動します（タイムスタンプ付きでリネーム）。

### 17.7. Junk（Perl スクラッチ）

`my-junk-new` でタイムスタンプ付き Perl スクラッチファイル（`~/Dropbox/howm/junk/YYYYMMDDHHMM.pl`）を作成します。


## 18. Markdown 編集（60-markdown.el）

### 18.1. 基本設定

```elisp
(leaf markdown-mode :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode))
  :bind (:markdown-mode-map
         ("C-c RET" . markdown-follow-link-at-point)
         ("C-c C-c" . markdown-do-command)
         ("M-RET"   . markdown-insert-list-item)))
```

### 18.2. プレビュー

`pandoc` + Chrome でプレビューします。カスタム CSS（`markdown-cream.css`）と `highlight.js` を使ったシンタックスハイライト付きです。コードブロックへのシンタックスハイライトと見出しの段階的サイズ表示を有効化しています。

### 18.3. howm コードコメント修正

`my-howm-fix-code-comments`（`C-c #`、`my-markdown.el`）で howm ファイルのコードブロック内の `# ` を `## ` に置換します。リージョン選択時はバッファ内処理、非選択時は Perl スクリプト経由で処理します。`C-c t`（`gen-toc-term`）で目次を生成します。

`super-save` 後に自動実行する `my-howm-fix-after-super-save` も設定しています。

### 18.4. PDF・docx 変換

| 関数 | 変換先 |
|------|-------|
| `md2pdf` | pandoc + lualatex で PDF 生成 → `xdg-open` で表示 |
| `md2docx` | pandoc で docx 生成 → `xdg-open` で表示 |

### 18.5. 一時ファイル自動削除

markdown バッファを閉じると `/tmp/burl*.html` を自動削除します。


## 19. 外部ツール・専用メジャーモード連携（70番台）

70番台には、特定の外部ツールや専用メジャーモードごとの設定ファイルをまとめています。

### 19.1. 翻訳（70-translate.el）

#### DeepL API 翻訳

実体は `~/.emacs.d/elisp/my-deepl-translate.el` に分離し、`70-translate.el` 側は autoload とキーバインドのみを行います。2026-03-10 の DeepL API 仕様変更（認証方式を `auth_key` POST ボディから `Authorization` ヘッダー方式に変更）に対応済みです。

```elisp
(leaf *deepl-translate
  :preface
  (autoload 'deepl-translate "my-deepl-translate" nil t)
  :bind ("C-c d" . deepl-translate)
  :init
  (load "~/.env_source/tokens/deepl-api.el"))
```

API キーは `~/.env_source/tokens/deepl-api.el` から読み込みます。日本語↔英語を自動判定して翻訳します。結果はエコーエリアに表示し、クリップボードにも追加します。3000 文字を超える場合は確認プロンプトを表示します。

#### Google Web 翻訳

```elisp
(leaf *my-google-translate
  :bind ("C-c w" . my-google-translate))
```

リージョンまたはカーソル位置の文を取得し、Google Translate の Web サイトをブラウザで開きます。日本語↔英語を自動判定します。

### 19.2. Neotree（70-neotree.el）

```elisp
(leaf neotree :ensure t
  :bind (("<f2>" . my-neotree-toggle)))
```

`doom-themes-neotree-config` でテーマと統合しています。`my-neotree-toggle` は現在のファイルまたはディレクトリを基準にツリーを表示します。ファイルを開いたら Neotree を自動で閉じます（`neotree-enter-hide`）。起動時にテキストを 1 段階縮小します（`neotree-text-scale`）。モードラインは非表示です。新規ファイル作成時は自動でそのファイルを開きます（`neo-create-file-auto-open`）。

`j`/`k` で移動、`a` で隠しファイルトグル、`<left>` で親ディレクトリへ、`<right>` でルート変更（`neotree-change-root`）します。

### 19.3. ブログ管理（70-easy-hugo.el）

[`easy-hugo`](https://github.com/masasam/emacs-easy-hugo) で Hugo 製のブログを管理しています。メインブログ（snap）を blog1 として、`easy-hugo-bloglist` で blog2〜8 まで計 8 サイトを管理しています。

| ブログ | URL |
|-------|-----|
| blog1（main） | snap.minorugh.com |
| blog2 | minorugh.github.io |
| blog3〜8 | minorugh.com サブサイト群 |

`e` キーで設定ファイル（`70-easy-hugo.el`）を直接開けます（`my-edit-easy-hugo`）。`SPC` キー（`my-easy-hugo-view`）で記事を view-mode + evil-emacs-state で開きます。新規ポスト作成後は `advice-add` で `my-easy-hugo-newpost-after` を実行し、`evil-emacs-state` に切り替えてカーソルを末尾に移動・保存します。

### 19.4. NeoMutt 連携（70-neomutt.el）

`emacsclient` を外部エディタとして呼び出す NeoMutt との連携です。`/neomutt-` を含むファイルパスは専用の `neomutt-mail-mode`（`text-mode` 派生）で開きます。`C-x C-c`（`server-edit`）で編集を終えると `server-done-hook` 経由で `my-neomutt-server-done` が呼ばれ、darkroom を抜けてからバッファを kill し、フレームを最小化します。

### 19.5. YaTeX（LaTeX 編集、70-yatex.el）

```elisp
(leaf yatex :ensure t
  :mode ("\\.tex\\'" "\\.sty\\'" "\\.cls\\'")
  :config
  (setq tex-command             "platex")
  (setq dviprint-command-format "dvpd.sh %s"))
```

`dvpd.sh` は `dvipdfmx` で PDF を生成して `evince` で表示するシェルスクリプトです。`M-c`（`YaTeX-typeset-buffer`）でコンパイル、`M-v`（`YaTeX-lpr`）で PDF 表示します。


## 20. Hydra メニュー（80番台）

### 20.1. [hydra-dired] ファイルナビゲーター（80-hydra-dired.el）

`<henkan>` で起動します。ディレクトリへのクイックアクセスと各種操作をまとめています。

主な機能：

* `d`：Dropbox、`e`：.emacs.d、`i`：inits、`s`：src、`h`：Dropbox/GH、`j`：Dropbox/minorugh.com
* `;` / `:`：xsrv 2ペイン表示（minorugh / GH）
* `c`/`k`/`b`/`m`/`u`：make ターゲット実行（clean/-k/bk/mv/up）
* `[`：my-git-peek-smart、`-`：git-peek-deleted、`]`：my-make-git
* `t`：my-open-tig、`v`：markdown-preview、`o`：howm-list-all、`,`：howm 新規メモ
* `@`：browse-at-remote、`f`：flymake-show-buffer-diagnostics、`l`：my-changelog-search
* `8`/`9`/`0`：FileZilla（サイトマネージャー／gospel-haiku／minorugh）、`a`：keepassxc
* `r`：my-restart-emacs、`x`：my-reload-xenv、`<home>`：ホームディレクトリを開く

`<henkan>` で hydra-work と相互トグルできます。

#### 補助コマンド

* `my-open`：パスを dired/find-file で開く。`:pos 'top`/`'bottom`/整数 でカーソル位置を指定、`:omit` で omit-mode 無効化、`:emacs` で emacs-state に遷移
* `my-make`：make ターゲットを指定ディレクトリで実行
* `my-make-git`：P1 なら `compile` で軽量実行、それ以外（サブ機）は `my-make-run-async`（09-makefile.el）経由で gnome-terminal 実行に委譲
* `my-2pane-quit`：2ペインを閉じて元のバッファに戻る（divider 解除フック `my-2pane-quit-hook` 付き）
* `my-restart-emacs`：バッファ保存 → server 停止 → Emacs 終了 → `emacs-start.sh` を起動
* `my-reload-xenv`：`~/.Xmodmap` と keychain の SSH_AUTH_SOCK を再読み込み
* `keepassxc`：KeePassXC を起動
* `filezilla`：FileZilla を特定サイトで起動（`g`=gospel-haiku、`m`=minorugh、`s`=サイトマネージャー）

### 20.2. [hydra-work] 俳句作業メニュー（80-hydra-dired.el）

`<henkan>`（hydra-dired から遷移）または `<f14>` で起動します。俳句・文芸関係のワークスペースへのショートカットが中心です。

主な機能：

* 各種文芸ファイルへのクイックアクセス（`d`：日記、`t`：定例、`s`：吟行、`k`：近詠、`m`/`w`：選句 など）
* `n`/`v`/`i`：yasnippet 操作
* `p`/`P`：ps-print
* `g`/`l`：gist / Lepton
* `e`：easy-hugo
* `c`/`u`/`o`：大文字化・小文字化
* `j`/`h`：howm junk / howm ディレクトリ
* `+`：text-scale-adjust

### 20.3. [hydra-browse] ブラウザランチャー（80-hydra-browse.el）

`..`（key-chord。mozc 有効時は自動で IME を OFF にしてから開きます）で起動します。お気に入りサイトへのワンキーアクセスです。ショップ・SNS・リポジトリ・ブログ・ライフ・ソーシャル・GitHub・Google・お気に入りの各カテゴリにまとめたグリッド状のメニューになっています。

#### GitHub Deploy（`d` キー）

`my-github-deploy` で `~/Dropbox/Changelog/` の `changelog-YYYYMMDD.md` を選択し、`~/Dropbox/Changelog/github-deploy.pl` で `CHANGELOG.md` の先頭に追記して `make git` で push します。


## 21. カレンダー（90-calendar.el）

Emacs 標準の `calendar`/`diary` に、Google Calendar からの一方向同期機能を追加しています。

```elisp
(leaf calendar :tag "builtin"
  :hook ((kill-emacs-hook . my-gcal-sync-on-exit)
         (calendar-mode-hook . my-calendar-cursor-type))
  :bind (("<f7>" . calendar)
         (:calendar-mode-map
          ("<f7>" . calendar-exit))))
```

### 21.1. Google Calendar 同期（my-gcal-diary.el）

同期ロジック本体は `elisp/my-gcal-diary.el` に分離してあり、`90-calendar.el` からは autoload で呼び出すだけです。

* `~/.emacs.d/tmp/diary`：手書き用。直接編集するファイル
* `~/.emacs.d/tmp/diary-gcal`：Google Calendar 由来。同期のたびに全体を洗い替えるため、手で編集しない

対象カレンダーは `my-gcal-calendars`（名前・URLファイルパスの alist）に登録し、各 URL ファイルには Google Calendar の非公開 URL（secret address in iCal format）を `~/.env_source` 配下に保存します。同期処理は「ダウンロード → `icalendar-import-file` で diary 形式に変換 → 直近数ヶ月分だけに絞り込み → 書き込み」を各カレンダーごとに繰り返します。`M-x my-gcal-sync-to-diary` で手動実行できるほか、`kill-emacs-hook`（`my-gcal-sync-on-exit`）で Emacs 終了時に自動同期されます（タイムアウトやエラーは無視して起動をブロックしません）。

### 21.2. 日本の祝日・表示

`japanese-holidays` パッケージで祝日を calendar に反映します。予定がある日は `diary` フェイス（`#d33682`）、当日は `calendar-today` フェイス（`#f2fa8c`・太字）で色分けします。`calendar-mode` ではカーソルを輪郭のみ（hollow）にして、下の日付の色を隠さないようにしています。`<f7>` で calendar の起動／終了をトグルします。


## 22. 執筆モード（90-darkroom.el）

以前は独自実装の `my-darkroom-mode` でしたが、現在は [`darkroom`](https://github.com/joaotavora/darkroom) パッケージをベースに、状態の保存・復元やフレーム全体の余白調整をラップする形に変更しています。mutt/markdown/howm など text-mode 系の日本語文章作成バッファ専用で、prog-mode 系バッファでの使用は想定していません。

`<f8>`（`my-darkroom-toggle`）でトグルします。

### 22.1. IN/OUT の動作

**IN 時（`my-darkroom-in`）：**
* 現在の行番号・whitespace-mode・`line-spacing` の状態を保存
* 行番号・whitespace-mode を無効化
* `line-spacing` を 0.2 に、`darkroom-margins` を自動計算に設定
* `darkroom-text-scale-increase` を 2 に設定して `darkroom-mode` を有効化
* evil-normal-state へ

**OUT 時（`my-darkroom-out`）：**
* `darkroom-mode` を無効化し、テキストズームをリセット
* 保存しておいた行番号・whitespace-mode・`line-spacing` の状態を復元
* IME を OFF にして evil-normal-state へ

### 22.2. NeoMutt 連携

NeoMutt が外部エディタとして `neomutt-XXXX` バッファを開いたときの darkroom 終了処理は、`70-neomutt.el` の `my-neomutt-server-done`（`server-done-hook`）側で行っています。`C-x #`（`server-edit`）で抜けるときに darkroom が有効なら `my-darkroom-out` を呼んでから確実に終了します。


## 23. ローカルパッケージ（elisp/）

### 23.1. seiho-haiku.el

阿波野青畝の俳句データ 366 日分を収録したローカルパッケージです。`dashboard` の「今日の一句」ウィジェットから呼ばれます。フォント・ウェイト・ボックスカラーなどの表示設定は変数（`seiho-haiku-ku-height` など）でカスタマイズできます。

### 23.2. my-template.el

俳句・文芸活動用のファイルテンプレート関数を定義しています。`hydra-work` から呼び出します。

* `my-diary-new-post` / `my-tpdia-new-post`：日記ファイルに当日エントリを挿入
* `my-haiku-note-post` / `my-haiku-note`：俳句ノートに当日エントリを挿入（重複防止）
* `my-teirei-new-post` / `my-swan-new-post` / `my-m_kukai-new-post` / `my-ap-new-post` / `my-apvoice-new-post` / `my-tselext-new-post` / `my-dselext-new-post` / `my-year-new-post` など：各句会テキストのテンプレート挿入

### 23.3. my-sen-cleanup.el

俳句選者作業（`minoru_sen.txt`）用の Perl スクリプト連携パッケージです。normal state リーダーキー `;c` / `;r`（02-evil.el）から呼び出します。

* `my-sen-cleanup`：`sen_cleanup.pl` を非同期実行し、`*sen-cleanup*` バッファにストリーミング表示。成功で元のバッファへ `revert-buffer`
* `my-sen-restore`：`.tmp` ファイルから復元

### 23.4. my-markdown.el

`my-howm-fix-code-comments`・`gen-toc-term` を定義しています。

### 23.5. my-tig-bridge.el

`my-open-tig`（dired の `t` キー）で tig を gnome-terminal で起動し、コンテキスト（ファイルパス）を `/tmp/tig-peek-context` に書き出します。tig 側の `E` キーで `emacsclient` 経由で `git-peek-from-hash` を呼び、選択コミットを git-peek で開きます。

### 23.6. my-evil-cheat-sheet.el

`?` キーで呼び出せる evil キーバインドチートシートです。右サイドバーに静的なリファレンステキストを表示し、`q` で閉じます。

### 23.7. my-gcal-diary.el

Google Calendar から Emacs diary への一方向同期ロジック本体です（詳細は「21. カレンダー」を参照）。

### 23.8. my-deepl-translate.el

DeepL API を使った翻訳の実体です（詳細は「19.1. 翻訳」を参照）。以前は `deepl-translate` パッケージを `:vc` インストールしていましたが、規模が小さいためこのファイルへ直書きに移行しました。

### 23.9. tempbuf.el

未使用バッファをバックグラウンドで自動 kill するマイナーモードです。EmacsWiki 限定配布で `package-vc-install` できないため、自分の GitHub にフォークした上でこのディレクトリに直接配置しています（原作: Michele Bini）。


## 24. おわりに

私の Emacs は、Web ページのメンテナンスや俳句・文芸活動がメインで、「賢くて多機能なワープロ」という存在です。

本設定の特徴をまとめると以下のとおりです。

* **evil-mode** を中心とした vi/vim スタイルの操作体系（`i` のみ編集トリガー、手動 emacs-state からの自動復帰つき）
* **leaf.el** による宣言的なパッケージ管理と **key-chord** のスタール自動回復
* **howm** + **markdown** によるメモ・文書管理、**Google Calendar** との一方向同期
* **hydra** による階層的なコマンドランチャー（hydra-dired / hydra-work / hydra-browse）
* **nerd-icons** / **doom-themes** / **doom-modeline** / **nyan-mode** による現代的な UI
* **make-run.sh** + Ivy 統合ターゲットピッカーによる Makefile 連携
* `tmp/` 配下への履歴・キャッシュの一元管理
* `elisp/` 配下へのローカルパッケージの集約
* **xsrv** との rsync lock・2ペイン連携による安全なサーバーファイル管理
* **git-peek** + **my-tig-bridge** による Git 差分プレビュー
* **darkroom** パッケージをベースにした執筆モードと NeoMutt 連携

<div style="float:left">
&ensp;<a href="https://twitter.com/share" class="twitter-share-button" data-via="minorugh" data-lang="jp" data-count="horizontal">Tweet</a>
</div>
