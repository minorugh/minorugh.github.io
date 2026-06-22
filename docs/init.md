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
│   ├── my-evil-cheat-sheet.el
│   ├── my-markdown.el
│   ├── my-sen-cleanup.el
│   ├── my-template.el
│   ├── my-tig-bridge.el
│   └── seiho-haiku.el
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
│   ├── 09-make.el
│   ├── 10-ui.el
│   ├── 20-utils.el
│   ├── 30-dired.el
│   ├── 40-remote.el
│   ├── 50-howm.el
│   ├── 60-markdown.el
│   ├── 70-hydra-browse.el
│   ├── 70-hydra-dired.el
│   ├── 80-easy-hugo.el
│   ├── 80-neotree.el
│   ├── 80-translate.el
│   └── 90-darkroom.el
├── snippets/
├── tmp/                          ← 各種履歴・キャッシュ
├── early-init.el
├── init.el
└── init-mini.el
```

ファイル番号の意味は下記のとおりです。

| 番号 | カテゴリ |
|------|---------|
| 00-09 | コア・基本設定 |
| 10-19 | UI・外観 |
| 20-29 | ユーティリティ |
| 30-39 | ファイラー |
| 40-49 | リモート・サーバー連携 |
| 50-59 | メモ環境 |
| 60-69 | 文書編集 |
| 70-79 | Hydra メニュー |
| 80-89 | 外部ツール連携 |
| 90-99 | 執筆モード |


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

#### 2.1.2. エンコーディングとフォント

マシン名が `P1` かどうかでフォントサイズを切り替えます。

```elisp
(prefer-coding-system 'utf-8)
(let ((font-size (if (string= (system-name) "P1") 18 16)))
  (push `(font . ,(format "Cica-%d" font-size)) initial-frame-alist))
(setq inhibit-compacting-font-caches t)
```

#### 2.1.3. UI の早期無効化とフレーム設定

```elisp
;; UI 要素を非表示（フリッカー防止）
(push '(menu-bar-lines    . 0) default-frame-alist)
(push '(tool-bar-lines    . 0) default-frame-alist)
(push '(vertical-scroll-bars ) default-frame-alist)
(push '(undecorated       . t) default-frame-alist)

;; 外部モニター（DP-1-2, x=1920）で最大化起動
(push '(fullscreen . maximized) initial-frame-alist)
(push '(left . 1920)            initial-frame-alist)
(push '(top  . 0)               initial-frame-alist)
```

X11 レベルの設定（XIM 無効化・DPI・初期背景色）は `~/.Xresources` に記述し、`xrdb -merge ~/.Xresources` で反映します。

### 2.2. [init.el] メイン初期化

[https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el)

#### 2.2.1. バージョンチェックと起動高速化

```elisp
(when (version< emacs-version "29.1")
  (error "This requires Emacs 29.1 and above!"))

(defconst default-handlers file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist default-handlers)
            (setq gc-cons-threshold (* 16 1024 1024))
            (setq inhibit-message nil)
            (message "Emacs ready in %s with %d GCs."
                     (emacs-init-time) gcs-done)
            ;; 残存セッションファイルを削除
            (mapc #'delete-file (file-expand-wildcards "~/.emacs.d/session.*"))))
```

起動後は GC 閾値を 16MB に戻します。セッションファイルの残存も自動削除します。

#### 2.2.2. パッケージシステム（leaf.el）

`use-package` から [`leaf.el`](https://github.com/conao3/leaf.el) に全面移行しています。`hydra` は `leaf-keywords` の前に初期化します。

```elisp
(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")))
  (package-initialize)
  (use-package leaf :ensure t)

  (leaf hydra :ensure t)

  (leaf leaf-keywords
    :ensure t
    :config
    (leaf-keywords-init)))
```

#### 2.2.3. init-loader と load-path

```elisp
(leaf init-loader
  :ensure t
  :load-path "~/.emacs.d/elisp"   ;; ローカルパッケージのパス
  :config
  (setq init-loader-show-log-after-init 'error-only)
  (setq init-loader-byte-compile t)
  (init-loader-load))
```

`load-path` は `init-loader` の `:load-path` で一括指定しています。`inits/` 配下のファイルはバイトコンパイルしながら順次読み込みます。

#### 2.2.4. サーバー・シェル環境

```elisp
(leaf server
  :commands server-running-p
  :hook (emacs-startup-hook
         . (lambda ()
             (unless (server-running-p)
               (server-start)))))

(leaf exec-path-from-shell
  :ensure t
  :when (memq window-system '(mac ns x))
  :hook (emacs-startup-hook . exec-path-from-shell-initialize)
  :config
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))
```

`SSH_AUTH_SOCK` を継承することで、git・FileZilla などの SSH 操作で keychain が使えるようになります。

### 2.3. [init-mini.el] ミニマル起動

新しいパッケージのテストや Emacs が起動しない場合のデバッグ用です。

```bash
alias eq="emacs -q -l ~/.emacs.d/init-mini.el"
```

`fido-mode` / `fido-vertical-mode` を使った軽量な補完環境のみを設定しています。外部パッケージは一切使用しません。


## 3. コア設定（00-base.el）

基本的な Emacs の挙動と共通のキーバインドを設定します。

### 3.1. 基本設定

```elisp
(setq-default bidi-display-reordering nil)        ;; 右→左言語の処理を省略（高速化）
(setq-default bidi-paragraph-direction 'left-to-right)
(setq make-backup-files        nil)   ;; バックアップファイルを作らない
(setq auto-save-default        nil)   ;; 自動保存を無効化
(setq create-lockfiles         nil)   ;; ロックファイルを作らない
(setq vc-follow-symlinks       t)     ;; シンボリックリンクを直接開く
(setq completion-ignore-case   t)     ;; 補完で大文字小文字を区別しない
(setq scroll-preserve-screen-position t)
(setq ring-bell-function      'ignore)
(setq mouse-drag-copy-region   t)     ;; マウス選択で自動コピー
(setq select-enable-clipboard  t)     ;; X11 クリップボードを使用
(setq delete-by-moving-to-trash t)
(setq trash-directory (locate-user-emacs-file "tmp/trash"))
(set-fringe-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p)
```

### 3.2. 履歴・データファイルの一元管理

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

`savehist` は `extended-command-history` と `my-describe-history` も追加で永続化します。`recentf` は idleタイマー経由（0.5秒後）で有効化し、elpa・tmp・Dropbox/backup 配下は除外します。

### 3.3. モード関連付けとグローバルマイナーモード

```elisp
(leaf *defer-modes
  :mode (("\\.\\(?:tmux\\.conf\\|muttrc\\|xprofile\\|Xmodmap\\)\\'" . conf-mode)
         ("\\.\\(?:gitattributes\\|gitignore\\|vimrc\\)\\'" . conf-mode)
         ("/crontab\\(\\..*\\)?\\'" . conf-mode)
         ("\\.cgi\\'" . perl-mode))
  :hook
  (after-init-hook . global-auto-revert-mode)
  (after-init-hook . save-place-mode)
  (after-init-hook . savehist-mode))
```

### 3.4. キーバインドとユーザー関数

```elisp
(leaf user-configurations
  :bind (("C-x C-c"    . server-edit)
         ("C-x b"      . ibuffer)
         ("C-x m"      . counsel-imenu)
         ("M-,"        . xref-find-definitions)
         ("M-w"        . clipboard-kill-ring-save)
         ("C-w"        . my-clipboard-kill-region)
         ("M-/"        . kill-current-buffer)
         ("s-c"        . clipboard-kill-ring-save)
         ("s-v"        . clipboard-yank)
         ("C-q"        . other-window-or-split)
         ("C-<tab>"    . quoted-insert)
         ([muhenkan]   . my-muhenkan)
         ("S-<return>" . (lambda () (interactive) (end-of-line) (newline)))))
```

`C-x C-c` は誤操作防止のため `server-edit` に変更。`C-x m` は `counsel-imenu` に割り当て。最後のフレームを閉じようとしたとき、削除せず最小化する `handle-delete-frame` の上書きも設定しています。


## 4. ダッシュボード（01-dashboard.el）

起動画面として `dashboard` を使用しています。

```elisp
(leaf dashboard
  :ensure t
  :if (display-graphic-p)
  :hook ((emacs-startup-hook  . open-dashboard)
         (dashboard-mode-hook . (lambda ()
                                  (set-window-margins (selected-window) 2 2)
                                  (page-break-lines-mode 1))))
  :bind ([home] . dashboard-toggle))
```

`[home]` キーで dashboard と直前のバッファをトグル表示できます。

### 4.1. 今日の一句（seiho-haiku）

`seiho-haiku.el`（`elisp/` 配下のローカルパッケージ）に阿波野青畝の俳句データ 366 句が収録されています。P1 マシンでは dashboard に「今日の一句」を表示します。

```elisp
(if (string-match "P1" (system-name))
    (setq dashboard-items '((haiku . 1) (recents . 5)))
  (setq dashboard-items '((recents . 5))))
```

### 4.2. バナータイトルの動的生成

```elisp
(setq dashboard-banner-logo-title
      (let* ((uname  (split-string (shell-command-to-string "uname -rn")))
             (debian (string-trim (shell-command-to-string "cat /etc/debian_version"))))
        (format "GNU Emacs %s kernel %s Debian %s x86_64 GNU/Linux"
                emacs-version (cadr uname) debian)))
```

バナーには `~/.emacs.d/emacs.png` を使用しています。フッターには自作のメッセージと `nerd-icons` のホームアイコンを表示します。


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
  (define-key evil-normal-state-map key #'ignore))
```

`:q` / `:wq` は `kill-current-buffer` にマップし、Emacs 終了を防いでいます。

### 5.2. [muhenkan] 万能脱出キー

`my-muhenkan` は文脈に応じて動作します。

```elisp
(defun my-muhenkan ()
  (interactive)
  (cond
   ;; *Help* バッファが開いていれば閉じる
   ((get-buffer-window "*Help*")
    (delete-window (get-buffer-window "*Help*"))
    (kill-buffer "*Help*"))
   ;; ミニバッファ操作中なら中断
   ((minibuffer-window-active-p (selected-window))
    (abort-minibuffers))
   ;; 別ウィンドウのミニバッファにフォーカスして中断
   ((active-minibuffer-window)
    (select-window (active-minibuffer-window))
    (abort-recursive-edit))
   ;; リージョンがあれば解除
   ((use-region-p) (deactivate-mark))
   ;; Normal → Emacs、それ以外 → Normal
   ((evil-normal-state-p) (evil-emacs-state))
   (t (deactivate-input-method)
      (evil-normal-state))))
```

| 状況 | 動作 |
|------|------|
| `*Help*` バッファ表示中 | バッファを閉じる |
| ミニバッファ使用中 | `abort-minibuffers` |
| 別ウィンドウのミニバッファ | フォーカスして `abort-recursive-edit` |
| リージョン選択中 | 選択解除 |
| evil normal state | emacs state へ切替 |
| それ以外 | IME を無効化して evil normal state へ |

### 5.3. normal state のキーバインド

| キー | コマンド |
|------|---------|
| `C-a` | seq-home（行頭→バッファ先頭） |
| `C-e` | seq-end（行末→バッファ末尾） |
| `C-w` | evil-delete-backward-word |
| `SPC` | evil-scroll-down |
| `b` | evil-scroll-up |
| `@` | evil-visual-char |
| `_` | evil-visual-line |
| `?` | my-evil-cheat-sheet |
| `[muhenkan]` | my-muhenkan |
| `[home]` | dashboard-toggle |

visual state では `PgUp`/`PgDn` で選択範囲を拡大・縮小、`;` でコメント、`c` でコピー、`s` で swiper、`g` で Google 検索、`d` で DeepL 翻訳が使えます。

### 5.4. j/k の挙動

折り返し行を自然に移動できるよう `j`/`k` と `gj`/`gk` を入れ替えています。

### 5.5. normal state リーダーキー「;」

normal state を抜けずに軽微な編集を完結させるための仕組みです。

| キー | コマンド |
|------|---------|
| `;f` | counsel-find-file |
| `;;` | comment-line |
| `;/` | kill-current-buffer |
| `;:` | counsel-switch-buffer |
| `;o` | 上に空行挿入（my-newline-above） |
| `;c` | my-sen-cleanup |
| `;r` | my-sen-restore |
| `;w` | my-darkroom-toggle |
| `;s` | swiper |
| `;@` | 行頭に ◎ 挿入（俳句選者用） |
| `;i` | Emacs state + mozc ON |

### 5.6. [evil-cheat-sheet] チートシート

`my-evil-cheat-sheet.el`（`elisp/` 配下）に `?` キーで呼び出せる evil キーバインドチートシートを定義しています。`i` で ivy ジャンプ、`m`/`e`/`o`/`v`/`n` でセクションジャンプ、`q` で終了できます。


## 6. 補完・検索

### 6.1. [ivy] 補完フレームワーク（03-ivy.el）

`ivy` を使用しています。

```elisp
(leaf ivy
  :ensure t
  :hook (after-init-hook . ivy-mode)
  :chord (("df" . my-describe-command)
          ("fg" . my-describe-variable)))
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
         ("C-x g"   . counsel-git)
         ("s-a"     . counsel-git-grep)
         ("M-x"     . counsel-M-x)
         ("M-y"     . counsel-yank-pop)
         ("C-,"     . counsel-mark-ring)))
```

`C-x g` でプロジェクト内のファイル検索、`s-a` でプロジェクト内の全文検索（`counsel-git-grep`）を行います。選択行には nerd-icons のシェブロンアイコンを使ったカスタム表示を適用しています。

#### 6.2.1. [amx] M-x 履歴強化

```elisp
(leaf amx :ensure t
  :config
  (setq amx-save-file (locate-user-emacs-file "tmp/amx-items"))
  (setq amx-history-length 20))
```

`counsel-M-x` と連携し、使用頻度の高いコマンドを優先表示します。

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
  (setq migemo-command "/usr/bin/cmigemo")
  (setq migemo-options '("-q" "--emacs"))
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

全バックエンドに yasnippet を自動付加する設定を入れています。

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
  :bind* (("<hiragana-katakana>" . my-toggle-input-method)
          ("<f13>"               . my-toggle-input-method))
  :bind (("s-m" . my-mozc-config)
         ("s-d" . my-mozc-word-regist)
         (:mozc-mode-map
          ("," . (lambda () (interactive) (mozc-insert-str "、")))
          ("." . (lambda () (interactive) (mozc-insert-str "。"))))))
```

`my-toggle-input-method` は evil-emacs-state のときのみ IME を切り替えます。句読点は mozc を介さず即時挿入します。`<f13>` でも同様の操作ができます。

### 7.2. mozc ツール起動

| キー | 機能 |
|------|------|
| `s-m` | 設定ダイアログ |
| `s-d` | 単語登録ダイアログ |

### 7.3. mozc-cand-posframe

変換候補を `posframe` でポップアップ表示します。doom-dracula テーマに合わせた配色を設定しています。

### 7.4. カーソル色による状態表示

evil state と mozc の状態をカーソル色で視覚的に示します。0.1 秒のアイドルタイマーで更新します。

| 状態 | カーソル色 |
|------|---------|
| normal state | `#50fa7b`（緑） |
| emacs state / mozc OFF | `#BD93F9`（紫） |
| emacs state / mozc ON | `#ff9580`（オレンジ） |
| read-only | `#6272A4`（グレー青） |
| visual state | `#F1FA8C`（黄） |


## 8. 外部ツール・SSH（07-functions.el）

F1〜F12 キーのバインドをここで一元管理しています。

| キー | コマンド |
|------|---------|
| `<f1>` | help-command（built-in） |
| `<f2>` | my-remote-select（SSH 接続先選択） |
| `<f3>` | terminal-open-this（gnome-terminal） |
| `<f4>` | xsrv-open-this（SSH でサーバーに接続） |
| `<f5>` | quickrun |
| `<f6>` | thunar-open-this |
| `<f7>` | neotree-toggle |
| `<f8>` | my-darkroom-toggle |
| `<f9>` | display-line-numbers-mode |
| `<f10>` | toggle-scratch-buffer |
| `<f11>` | toggle-frame-fullscreen |
| `<f12>` | toggle-emacs（最小化/復元スクリプト） |

### 8.1. my-remote-select

`<f2>` で SSH 接続先のディレクトリを `completing-read` で選択し、gnome-terminal で接続します。gospel-haiku・minorugh.com のサブディレクトリや Docker コンテナへのアクセスに使います。

### 8.2. xsrv-open-this

`<f4>` で現在のバッファが `~/Dropbox/GH/` または `~/Dropbox/minorugh.com/` 配下なら、対応するサーバーパスに自動的に変換して SSH ターミナルを開きます。

### 8.3. toggle-scratch-buffer

`<f10>` で `*scratch*` バッファと直前のバッファをトグルします。


## 9. 編集サポート（08-edit.el）

### 9.1. [super-save] スマート自動保存

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

### 9.2. scratch バッファの永続化

外部パッケージを使わず、`kill-emacs-hook` と `after-init-hook` で自前で実装しています。シャットダウン時に `tmp/scratch` に書き出し、起動時に読み込みます。

### 9.3. [undo-fu] / [undohist]

```elisp
(leaf undo-fu :ensure t
  :bind (("C-_" . undo-fu-only-undo)
         ("C-/" . undo-fu-only-redo)))

(leaf undohist :ensure t
  :hook (after-init-hook . undohist-initialize)
  :config
  (setq undohist-directory (locate-user-emacs-file "tmp/undohist")))
```

evil の undo システムも `undo-fu` に統一しています（`evil-undo-system 'undo-fu`）。undo 履歴は `tmp/undohist/` に永続化します。

### 9.4. [tempbuf] 未使用バッファの自動削除

```elisp
(leaf tempbuf
  :vc (:url "https://github.com/minorugh/tempbuf")
  :hook ((find-file-hook  . turn-on-tempbuf-mode)
         (dired-mode-hook . turn-on-tempbuf-mode)))
```

使われていないバッファをバックグラウンドで自動 kill します。xsrv rsync lock 機能と連携しています。

### 9.5. リージョン選択サポート

`selected.el` の代わりに `my-selected-mode`（自作マイナーモード）でリージョン選択時のワンキーアクションを実装しています。

```elisp
(define-key my-selected-mode-map (kbd ";") #'comment-dwim)
(define-key my-selected-mode-map (kbd "c") #'kill-ring-save)
(define-key my-selected-mode-map (kbd "s") #'swiper-region)
(define-key my-selected-mode-map (kbd "g") #'my-google-search)
(define-key my-selected-mode-map (kbd "w") #'my-weblio-search)
(define-key my-selected-mode-map (kbd "d") #'deepl-translate)
```

リージョン選択開始時に IME を自動 OFF、解除時に元の状態に戻します。

### 9.6. [flymake] 構文チェック

`flycheck` から `flymake`（built-in）に戻しています。`prog-mode` と `markdown-mode` で有効化します。


## 10. Makefile 連携（09-make.el）

### 10.1. compile-autoclose

コンパイル成功時にウィンドウを自動クローズします。`##>` マーカーがある場合はメッセージを抽出してエコーエリアに表示します。`##>` 単体（空）のときはバッファを全画面表示します。

### 10.2. Ivy 統合 Makefile ターゲット選択

`@` キー（makefile-mode・dired-mode）で Ivy による Makefile ターゲット選択を起動します。`## コメント` がついたターゲットのみ一覧表示し、矢印キーでリアルタイムプレビュー、`C-c C-c` で実行します。


## 11. UI・外観（10-ui.el）

### 11.1. テーマ

`doom-themes` の `doom-dracula` を使用しています。

```elisp
(leaf doom-themes :ensure t
  :hook (after-init-hook . (lambda () (load-theme 'doom-dracula t)))
  :config (setq doom-themes-enable-italic nil))
```

### 11.2. カーソルとハイライト

`hl-line`（built-in）でカーソル行をハイライトします。region の背景色と hl-line をテーマに合わせてカスタムしています。`blink-cursor` は無限点滅（`blink-cursor-blinks 0`）・0.3 秒間隔に設定しています。

### 11.3. [nerd-icons]

`all-the-icons` から `nerd-icons` に移行しました。`nerd-icons-dired` で dired バッファにアイコンを表示します。

初回は `M-x nerd-icons-install-fonts` でフォントをインストールしてください。

### 11.4. 行番号・fill-column インジケーター

`display-line-numbers`（built-in）を `prog-mode` / `text-mode` で有効化します（`lisp-interaction-mode` は除外）。`<f9>` でトグルできます。

`display-fill-column-indicator`（built-in）を gfm-mode / text-mode で有効化し、79 列目にガイドラインを表示します。

### 11.5. 対応括弧のハイライト

```elisp
(leaf paren :tag "builtin"
  :hook (after-init-hook . show-paren-mode)
  :config
  (setq show-paren-style                  'parenthesis)
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-when-point-in-periphery t))

(leaf rainbow-delimiters :ensure t
  :hook (prog-mode-hook . rainbow-delimiters-mode))
```

### 11.6. [whitespace] 行末スペースの表示と削除

`global-whitespace-mode` で行末スペースを赤くハイライトします。`C-c s`（`my-cleanup-for-spaces-safe`）で行末空白を削除し、UTF-8 エンコーディングを保証します。

### 11.7. [doom-modeline] モードライン

```elisp
(leaf doom-modeline :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :config
  (setq doom-modeline-icon            t)
  (setq doom-modeline-major-mode-icon nil)
  (setq doom-modeline-minor-modes     nil)
  (line-number-mode   0)
  (column-number-mode 0))
```

### 11.8. アクティブウィンドウのモードライン強調

dimmer-mode の代わりに、分割時のアクティブウィンドウをモードライン（紫ボーダー）で視覚的に示す方式を採用しています。minibuffer・hydra・Flymake・Compilation・which-key のポップアップウィンドウはカウントから除外します。


## 12. ユーティリティ（20-utils.el）

### 12.1. [which-key]

Emacs 29 built-in になりました。`which-key-idle-delay 0.0` で即時表示します。

### 12.2. [key-chord]

MELPA 版からフォーク版（`minorugh/key-chord`）に切り替えています。`sit-for` を `read-event` タイムアウトに変更し、重いバッファでのスタールを修正しています。

| chord | コマンド |
|-------|---------|
| `l;` | init-loader-show-log |
| `df` | my-describe-command（03-ivy.el） |
| `fg` | my-describe-variable（03-ivy.el） |
| `..` | hydra-browse/body（70-hydra-browse.el） |
| `@@` | howm-list-all（50-howm.el） |
| `,,` | my-howm-create-with-category（50-howm.el） |
| `p@` | hydra-package/body |

### 12.3. [sequential-command] バッファ端への移動

フォーク版（`minorugh/sequential-command`）を `:vc` でインストールしています。

* `C-a` を連続で押すと 行頭 → バッファ先頭 → 元の位置
* `C-e` を連続で押すと 行末 → バッファ末尾 → 元の位置

### 12.4. [quickrun]

`<f5>` で現在のバッファを実行します。

### 12.5. パッケージ管理 hydra

`p@` で起動します。

```
Package: _l_og  _i_nstall  _d_elete  _u_pgrade  up-_a_ll  _v_c-up-all
```

### 12.6. Gist / Lepton 連携

`gist-region-or-buffer` でリージョンまたはバッファ全体を Gist に投稿します。`open-lepton` で Lepton（GitHub Gist クライアント）を起動します。

### 12.7. YaTeX（LaTeX 編集）

```elisp
(leaf yatex :ensure t
  :mode ("\\.tex\\'" "\\.sty\\'" "\\.cls\\'")
  :config
  (setq tex-command             "platex")
  (setq dviprint-command-format "dvpd.sh %s"))
```

`dvpd.sh` は `dvipdfmx` で PDF を生成して `evince` で表示するシェルスクリプトです。`M-c` でコンパイル、`M-v` で PDF 表示します。


## 13. Dired（30-dired.el）

### 13.1. 基本設定

```elisp
(setq dired-listing-switches "-AlhF --group-directories-first --no-group")
(setq dired-omit-files       "^\\.$\\|^\\.[^\\.].*$\\|\\.elc$")
(setq dired-dwim-target t)
(setq dired-recursive-copies  'always)
(setq dired-recursive-deletes 'always)
```

### 13.2. キーバインド

| キー | 機能 |
|------|------|
| `<left>` | 親ディレクトリへ（同バッファ） |
| `<right>` / `RET` | ファイルは新バッファ、ディレクトリは同バッファ |
| `w` | wdired モード |
| `s` | sudo で削除 |
| `o` | xdg-open で関連アプリで開く |
| `a` | dired-omit-mode トグル |
| `[` | hide-details-mode |
| `t` | my-open-tig |
| `]` | gitk |
| `p` | パーミッション早見表 |
| `.` | xsrv deploy |
| `,` | xsrv download |
| `i` | sxiv で画像一覧 |

### 13.3. omit モードの制御

特定ディレクトリ（`~/`・dotfiles・xsrv-GH・src など）では omit を無効化し、隠しファイルを表示します。

### 13.4. パーミッション早見表

`p` キーで `*Permission Help*` バッファを右サイドバーに表示します。


## 14. リモート・xsrv 連携（40-remote.el）

xsrv（Xserver）との連携設定をすべてここに集約しています。

### 14.1. xsrv ルート判定

```elisp
(defconst my-xsrv-roots
  `((,(expand-file-name "~/src/github.com/minorugh/xsrv-GH/")
     . ,(expand-file-name "~/Dropbox/GH/"))
    (,(expand-file-name "~/src/github.com/minorugh/xsrv-minorugh/")
     . ,(expand-file-name "~/Dropbox/minorugh.com/"))))
```

xsrv-GH・xsrv-minorugh 配下かどうかを判定するヘルパーを用意しています。

### 14.2. Deploy / Download（dired キーバインド）

* `.` キー（`xsrv-deploy-dired`）：dired カーソル位置のファイルをサーバーに deploy
* `,` キー（`xsrv-download-dired`）：xsrv-GH/xsrv-minorugh からローカル Dropbox にダウンロード

### 14.3. xsrv 2ペイン表示

`my-open-xsrv-2pane` で xsrv 側とローカル Dropbox 側を左右分割で表示します。アクティブウィンドウにはヘッダー強調（`#1A2640` 背景）とサーバー/ホームアイコンを付与します。ウィンドウ分割線（divider）はオレンジ（`#ff9900`）で強調します。

### 14.4. [git-peek] コミット差分プレビュー

Claudeと共同開発した自作パッケージです。`:vc` でインストールしています。xsrv 配下では差分表示後に 2 ペインを自動復元します。

### 14.5. 動的フォルダー保護 & rsync lock

gospel-haiku の動的フォルダー（kukai/data・voice など）を自動 read-only 化します。read-only を解除すると `~/xsrv-rsync.lock` を発行して rsync を停止し、全バッファを閉じたら自動で lock を解除します。`tempbuf` との連携で unlock し忘れを防ぎます。

### 14.6. xsrv 配下バッファの背景色

xsrv-GH / xsrv-minorugh 配下のファイルバッファは背景色（`#233B6C`）で識別できます。

### 14.7. my-tig-bridge

`my-tig-bridge.el` で tig と git-peek を連携させています。tig 側で `E` キーを押すと `emacsclient` 経由で `git-peek-from-hash` が呼ばれ、選択したコミットを git-peek で開きます。


## 15. メモ環境（50-howm.el）

### 15.1. [howm] Wiki 型メモ

```elisp
(leaf howm :ensure t
  :hook (emacs-startup-hook . howm-mode)
  :chord (("@@" . howm-list-all)
          (",," . my-howm-create-with-category)))
```

メモは `~/Dropbox/howm/` に Markdown 形式（`.md`）で保存します。ファイル名は `%Y/%m/%Y%m%d%H%M.md` の形式です。タイトルヘッダーは `=`（howm デフォルトの `*` から変更）。

### 15.2. カテゴリ定義

通常カテゴリと特殊エントリの 2 種類を定義しています。

| キー | カテゴリ | 挿入文字列 |
|------|---------|---------|
| `m` | memo | `memo: ` |
| `i` | idea | `idea: ` |
| `t` | tech | `tech: ` |
| `d` | 日記 | `日記: ` |
| `g` | 園芸 | `園芸: ` |

特殊エントリ（`c`=code/Perlスクラッチ、`p`=創作/俳句ノート新規、`n`=推敲/俳句ノート）は外部関数に委譲します。

### 15.3. カテゴリ色分け

カテゴリごとにフェイスを定義し、記事バッファとサマリーバッファの両方に適用します。ライト/ダークテーマ対応の配色を設定しています。

### 15.4. メモ作成（my-howm-create-with-category）

`,,` または howm サマリーの `,` で起動します。縦リストでカテゴリを表示し、1 キーで選択して新規メモを作成します。特殊エントリは対応する関数を呼び出します。

### 15.5. カテゴリ検索（my-howm-search-by-category）

howm サマリーの `/` または `C-c /` で起動します。ivy でカテゴリを選択し、そのカテゴリのメモ一覧を表示します。

### 15.6. ゴミ箱への移動（my-howm-move-to-trash）

howm サマリーの `d` でカーソル行のメモを `tmp/trash/` に移動します（タイムスタンプ付きでリネーム）。

### 15.7. Junk（Perl スクラッチ）

`my-junk-new` でタイムスタンプ付き Perl スクラッチファイル（`~/Dropbox/howm/junk/YYYYMMDD.pl`）を作成します。


## 16. Markdown 編集（60-markdown.el）

### 16.1. 基本設定

```elisp
(leaf markdown-mode :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode))
  :bind (("C-c RET" . markdown-follow-link-at-point)
         ("C-c #"   . my-howm-fix-code-comments)
         ("C-c C-c" . markdown-do-command)
         ("M-RET"   . markdown-insert-list-item)))
```

### 16.2. プレビュー

`pandoc` + Chrome でプレビューします。カスタム CSS（`markdown-cream.css`）と `highlight.js` を使ったシンタックスハイライト付きです。コードブロックへのシンタックスハイライトと見出しの段階的サイズ表示を有効化しています。

### 16.3. howm コードコメント修正

`my-howm-fix-code-comments`（`C-c #`、`my-markdown.el`）で howm ファイルのコードブロック内の `# ` を `## ` に置換します。リージョン選択時はバッファ内処理、非選択時は Perl スクリプト経由で処理します。

`super-save` 後に自動実行する `my-howm-fix-after-super-save` も設定しています。

### 16.4. PDF・docx 変換

| 関数 | 変換先 |
|------|-------|
| `md2pdf` | pandoc + lualatex で PDF 生成 → `xdg-open` で表示 |
| `md2docx` | pandoc で docx 生成 → `xdg-open` で表示 |

### 16.5. 一時ファイル自動削除

markdown バッファを閉じると `/tmp/burl*.html` を自動削除します。


## 17. 翻訳（80-translate.el）

### 17.1. DeepL API 翻訳

2026-03-10 の DeepL API 仕様変更（認証方式を `auth_key` POST ボディから `Authorization` ヘッダー方式に変更）に対応済みです。以前は `deepl-translate` パッケージ（`:vc` インストール）を使用していましたが、規模が小さいため `80-translate.el` に直書きに変更しました。

```elisp
(leaf deepl-translate
  :bind ("C-c d" . deepl-translate))
```

API キーは `~/.env_source/tokens/deepl-api.el` から読み込みます。日本語↔英語を自動判定して翻訳します。結果はエコーエリアに表示し、クリップボードにも追加します。

3000 文字を超える場合は確認プロンプトを表示します。

### 17.2. Google Web 翻訳

```elisp
(leaf google-translate-web
  :bind ("C-c w" . my-google-translate))
```

リージョンまたはカーソル位置の文を取得し、Google Translate の Web サイトをブラウザで開きます。日本語↔英語を自動判定します。


## 18. Hydra メニュー

### 18.1. [hydra-dired] ファイルナビゲーター（70-hydra-dired.el）

`<henkan>` で起動します。ディレクトリへのクイックアクセスと各種操作をまとめています。

主な機能：

* `d`：Dropbox、`e`：.emacs.d、`i`：inits、`s`：src、`h`：Dropbox/GH、`j`：Dropbox/minorugh.com
* `;` / `:`：xsrv 2ペイン表示（GH / minorugh）
* `k`/`b`/`m`/`u`：make ターゲット実行
* `[`：git-peek、`-`：git-peek-deleted、`]`：make git
* `t`：tig、`g`：counsel-git、`v`：markdown-preview
* `@`：howm-list-all、`,`：howm 新規メモ
* `r`：restart-emacs、`x`：xenv 再読み込み

`<henkan>` で hydra-work と相互トグルできます。

#### 補助コマンド

* `my-open`：パスを dired/find-file で開く。`:pos 'top`/`'bottom`/整数 でカーソル位置を指定、`:omit` で omit-mode 無効化、`:emacs` で emacs-state に遷移
* `my-make`：make ターゲットを指定ディレクトリで実行
* `my-2pane-quit`：2ペインを閉じて元のバッファに戻る（divider 解除フック付き）
* `my-reload-xenv`：`~/.xprofile` と keychain 環境変数を Emacs セッションに再読み込み
* `keepassxc`：KeePassXC を起動
* `filezilla`：FileZilla を特定サイトで起動（`g`=gospel-haiku、`m`=minorugh、`s`=サイトマネージャー）

### 18.2. [hydra-work] 俳句作業メニュー（70-hydra-dired.el）

`<henkan>`（hydra-dired から遷移）または `<f14>` で起動します。俳句・文芸関係のワークスペースへのショートカットが中心です。

主な機能：

* 各種文芸ファイルへのクイックアクセス（`d`：日記、`t`：定例、`s`：吟行、`k`：近詠 など）
* `n`/`v`/`i`：yasnippet 操作
* `p`/`r`：ps-print
* `g`/`l`：gist / Lepton
* `e`：easy-hugo
* `c`/`u`/`o`：大文字化・小文字化

### 18.3. [hydra-browse] ブラウザランチャー（70-hydra-browse.el）

`..`（key-chord）で起動します。お気に入りサイトへのワンキーアクセスです。

#### GitHub Deploy（`d` キー）

`my-github-deploy` で `~/Dropbox/Changelog/` の `changelog-YYYYMMDD.md` を ivy で選択し、`CHANGELOG.md` の先頭に追記して `make git` で push します。


## 19. ブログ管理（80-easy-hugo.el）

[`easy-hugo`](https://github.com/masasam/emacs-easy-hugo) で Hugo 製のブログを管理しています。

メインブログ（snap）を blog1 として、`easy-hugo-bloglist` で blog2〜8 まで計 8 サイトを管理しています。

| ブログ | URL |
|-------|-----|
| blog1（main） | snap.minorugh.com |
| blog2 | minorugh.github.io |
| blog3〜8 | minorugh.com サブサイト群 |

新規ポスト作成後は `advice-add` で `my-easy-hugo-newpost-after` を実行し、`evil-emacs-state` に切り替えてカーソルを末尾に移動・保存します。

`e` キーで設定ファイル（`80-easy-hugo.el`）を直接開けます。


## 20. Neotree（80-neotree.el）

```elisp
(leaf neotree :ensure t
  :bind (("<f7>" . my-neotree-toggle)))
```

`doom-themes-neotree-config` でテーマと統合しています。

`my-neotree-toggle` は現在のファイルまたはディレクトリを基準にツリーを表示します。ファイルを開いたら Neotree を自動で閉じます（`neotree-enter-hide`）。起動時にテキストを 1 段階縮小します（`neotree-text-scale`）。モードラインは非表示です。

`j`/`k` で移動、`a` で隠しファイルトグル、`<left>`/`<right>` で親/子ディレクトリへ移動します。


## 21. 執筆モード（90-darkroom.el）

`darkroom` パッケージを使わず、独自の `my-darkroom-mode`（マイナーモード）として実装しています。

`<f8>` でトグルします。

### 21.1. カスタマイズ可能な変数

| 変数 | デフォルト | 説明 |
|------|---------|------|
| `my-darkroom-margin` | 0.15 | サイドマージンの比率（ウィンドウ幅の 15%） |
| `my-darkroom-text-scale` | 2 | テキストズームレベル |
| `my-darkroom-line-spacing` | 0.2 | 行間 |

### 21.2. IN/OUT の動作

**IN 時：**
* 行番号・whitespace-mode を無効化
* モードライン・ヘッダーラインを非表示
* 全画面・サイドマージン適用・行間を広げる
* IME が OFF なら自動で ON にする

**OUT 時（`<f8>` で戻る）：**
* すべて元に戻す
* IME を OFF にする

### 21.3. NeoMutt 連携

NeoMutt が外部エディタとして `neomutt-XXXX` バッファを開いたとき、自動で darkroom に入ります。`C-x #`（server-edit）で抜けるときも `server-done-hook` で確実に終了します。


## 22. ローカルパッケージ（elisp/）

### 22.1. seiho-haiku.el

阿波野青畝の俳句データ 366 日分を収録したローカルパッケージです。`dashboard` の「今日の一句」ウィジェットから呼ばれます。フォント・ウェイト・ボックスカラーなどの表示設定は変数でカスタマイズできます。

### 22.2. my-template.el

俳句・文芸活動用のファイルテンプレート関数を定義しています。`hydra-work` から呼び出します。

* `my-diary-new-post`：日記ファイルに当日エントリを挿入
* `my-haiku-note-post`：俳句ノートに当日エントリを挿入（重複防止）
* `my-teirei-new-post` / `my-swan-new-post` など：各句会テキストのテンプレート挿入

### 22.3. my-sen-cleanup.el

俳句選者作業（`minoru_sen.txt`）用の Perl スクリプト連携パッケージです。

* `my-sen-cleanup`（`;c`）：`sen_cleanup.pl` を非同期実行し、成功で `revert-buffer`
* `my-sen-restore`（`;r`）：`.tmp` ファイルから復元

### 22.4. my-markdown.el

`my-howm-fix-code-comments`・`gen-toc-term` を定義しています。

### 22.5. my-tig-bridge.el

`my-open-tig`（`t` キー in dired）で tig を gnome-terminal で起動し、コンテキスト（ファイルパス）を `/tmp/tig-peek-context` に書き出します。tig 側の `E` キーで `emacsclient` 経由で `git-peek-from-hash` を呼び、選択コミットを git-peek で開きます。

### 22.6. my-evil-cheat-sheet.el

`?` キーで呼び出せる evil キーバインドチートシートです。ivy ジャンプとセクションジャンプを実装しています。


## 23. おわりに

私の Emacs は、Web ページのメンテナンスや俳句・文芸活動がメインで、「賢くて多機能なワープロ」という存在です。

本設定の特徴をまとめると以下のとおりです。

* **evil-mode** を中心とした vi/vim スタイルの操作体系（`i` のみ編集トリガー）
* **leaf.el** による宣言的なパッケージ管理
* **howm** + **markdown** によるメモ・文書管理
* **hydra** による階層的なコマンドランチャー（hydra-dired / hydra-work / hydra-browse）
* **nerd-icons** / **doom-themes** / **doom-modeline** による現代的な UI
* `tmp/` 配下への履歴・キャッシュの一元管理
* `elisp/` 配下へのローカルパッケージの集約
* **xsrv** との rsync lock・2ペイン連携による安全なサーバーファイル管理
* **git-peek** + **my-tig-bridge** による Git 差分プレビュー

<div style="float:left">
&ensp;<a href="https://twitter.com/share" class="twitter-share-button" data-via="minorugh" data-lang="jp" data-count="horizontal">Tweet</a>
</div>
