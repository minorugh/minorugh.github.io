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

```codesession
~/.emacs.d
│
├── elisp/                        ← ローカルパッケージ置き場
│   ├── bin/
│   ├── css/
│   ├── my-github.el
│   ├── my-markdown.el
│   ├── my-template.el
│   └── my-dired.el
├── elpa/
├── inits/
│   ├── 00-base.el
│   ├── 01-dashboard.el
│   ├── 02-git.el
│   ├── 03-evil.el
│   ├── 04-counsel.el
│   ├── 05-company.el
│   ├── 06-mozc.el
│   ├── 07-highlight.el
│   ├── 08-dimmer.el
│   ├── 09-funcs.el
│   ├── 10-selected.el
│   ├── 20-check.el
│   ├── 20-edit.el
│   ├── 30-ui.el
│   ├── 30-utils.el
│   ├── 40-hydra-dired.el
│   ├── 40-hydra-menu.el
│   ├── 40-hydra-misc.el
│   ├── 50-dired.el
│   ├── 50-neotree.el
│   ├── 60-howm.el
│   ├── 60-markdown.el
│   ├── 60-org.el
│   ├── 70-translate.el
│   ├── 70-yatex.el
│   ├── 80-darkroom.el
│   ├── 90-easy-hugo.el
│   └── makefile
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
| 10-19 | 入力・選択サポート |
| 20-29 | 編集・チェック |
| 30-39 | UI・ユーティリティ |
| 40-49 | Hydra メニュー |
| 50-59 | ファイラー |
| 60-69 | メモ・文書編集 |
| 70-79 | 外部ツール連携 |
| 80-89 | 執筆モード |
| 90-99 | ブログ管理 |


## 2. 起動設定

ブートシーケンスは以下のとおりです。

1. `early-init.el` の読み込み
2. `init.el` の読み込み
3. `inits/` のファイル群を読み込み（init-loader 使用）

### 2.1. [early-init.el] 早期初期化

`early-init.el` は Emacs 27 から導入されました。`init.el` でパッケージや GUI の初期化が実行される前にロードされます。

[https://github.com/minorugh/dotfiles/blob/main/.emacs.d/early-init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/early-init.el)

#### 2.1.1. GC・起動高速化

```code
;; GCを起動完了まで実質停止
(setq gc-cons-threshold most-positive-fixnum)

;; native-comp の JIT コンパイルを無効化
(setq native-comp-jit-compilation nil)

;; パッケージ初期化を init.el に委譲
(setq package-enable-at-startup nil)

;; 非インタラクティブ時は新しいソースを優先
(setq load-prefer-newer noninteractive)

;; フレームリサイズを抑制
(setq frame-inhibit-implied-resize t)
```

#### 2.1.2. 初期フレーム設定

```code
;; エンコーディングとフォント
(prefer-coding-system 'utf-8)
(set-language-environment "Japanese")
(add-to-list 'default-frame-alist '(font . "Cica-18"))

;; UI要素を非表示
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; 最大化表示
(push '(fullscreen . maximized) initial-frame-alist)
```

テーマ読み込み前の一瞬の白背景（フラッシュ）を防ぐため、背景色・前景色は `~/.Xresources` で X11 リソースレベルに設定しています。`early-init.el` ではなく起動前に適用されるため、より確実にフラッシュを抑制できます。

#### 2.1.3. ~/.Xresources による X11 レベルの設定

`early-init.el` が読み込まれる前に Emacs へ適用したい設定は `~/.Xresources` に記述しています。
```
!! Disable XIM when using Emacs
Emacs*useXIM: false

Xft.dpi: 120

!! doom-dracula theme
Emacs.background: #282c36
Emacs.foreground: #f8f8f2
```

| 設定項目 | 内容 |
|---------|------|
| `Emacs*useXIM: false` | XIM（X Input Method）を無効化。Fcitx / IBus との競合・入力遅延を防ぐ |
| `Xft.dpi: 120` | Xft 経由のフォントレンダリング DPI をモニターに合わせて指定 |
| `Emacs.background / foreground` | テーマ読み込み前のフレーム初期色。白フラッシュを防ぐ |

設定変更後は以下で反映します。
```
xrdb -merge ~/.Xresources
```

### 2.2. [init.el] メイン初期化

[https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el)

#### 2.2.1. バージョンチェックと起動高速化

```code
(when (version< emacs-version "29.1")
  (error "This requires Emacs 29.1 and above!"))

;; file-name-handler-alist を一時無効化
(defconst default-handlers file-name-handler-alist)
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

#### 2.2.2. パッケージシステム（leaf.el）

`use-package` から [`leaf.el`](https://github.com/conao3/leaf.el) に全面移行しています。

```code
(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")))
  (package-initialize)
  (use-package leaf :ensure t)

  (leaf leaf-keywords
    :ensure t
    :init
    (leaf hydra :ensure t)
    :config
    (leaf-keywords-init))

  (leaf init-loader
    :ensure t
    :config
    (setq init-loader-show-log-after-init 'error-only)
    (setq init-loader-byte-compile t)
    (init-loader-load)
    :init
    (setq custom-file (locate-user-emacs-file "tmp/custom.el"))
    (let ((default-directory "~/.emacs.d/elisp/"))
      (add-to-list 'load-path default-directory)
      (normal-top-level-add-subdirs-to-load-path))))
```

`init-loader-byte-compile t` を設定することで inits/ 配下のファイルを自動バイトコンパイルします。`custom-file` は `tmp/custom.el` に分離しています。

#### 2.2.3. サーバー・シェル環境

```code
(leaf server
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

```code
;; .zshrc または .bashrc に追記
alias eq="emacs -q -l ~/.emacs.d/init-mini.el"
```

`fido-mode` / `fido-vertical-mode` を使った軽量な補完環境のみを設定しています。外部パッケージは一切使用しません。


## 3. コア設定（00-base.el）

基本的な Emacs の挙動と共通のキーバインドを設定します。

### 3.1. 基本設定

```code
(leaf *basic-configurations
  :config
  (setq-default bidi-display-reordering nil)    ;; 右→左言語の処理を省略（高速化）
  (setq-default bidi-paragraph-direction 'left-to-right)
  (setq make-backup-files nil)                  ;; バックアップファイルを作らない
  (setq auto-save-default nil)                  ;; 自動保存を無効化
  (setq create-lockfiles nil)                   ;; ロックファイルを作らない
  (setq vc-follow-symlinks t)                   ;; シンボリックリンクを直接開く
  (setq completion-ignore-case t)               ;; 補完で大文字小文字を区別しない
  (setq scroll-preserve-screen-position t)      ;; スクロール時にカーソル位置を保持
  (setq mouse-drag-copy-region t)               ;; マウス選択で自動コピー
  (setq delete-by-moving-to-trash t)            ;; 削除ファイルをゴミ箱へ
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets)
  (setq select-enable-clipboard t)
  (defalias 'yes-or-no-p 'y-or-n-p))
```

### 3.2. 履歴・データファイルの一元管理

各種履歴やキャッシュファイルをすべて `~/.emacs.d/tmp/` 配下に集約しています。

```code
(setq tramp-persistency-file-name (locate-user-emacs-file "tmp/tramp"))
(setq transient-history-file      (locate-user-emacs-file "tmp/transient/history"))
(setq project-list-file           (locate-user-emacs-file "tmp/projects"))
(setq savehist-file               (locate-user-emacs-file "tmp/history"))
(setq recentf-save-file           (locate-user-emacs-file "tmp/recentf"))
;; ...他も同様
```

### 3.3. 遅延モード有効化

```code
(leaf *defer-modes
  :hook
  (after-init-hook . global-auto-revert-mode)
  (after-init-hook . save-place-mode)
  (after-init-hook . savehist-mode)
  (after-init-hook . recentf-mode)
  (prog-mode-hook  . goto-address-prog-mode))
```

### 3.4. キーバインドとユーザー関数

```code
(leaf *user-configurations
  :bind (("C-x C-c" . server-edit)      ;; 終了しない（サーバー編集終了）
         ("C-x b"   . ibuffer)
         ("C-x m"   . neomutt)
         ("M-w"     . clipboard-kill-ring-save)
         ("C-w"     . my:clipboard-kill-region)
         ("M-/"     . kill-current-buffer)
         ("C-x /"   . delete-this-file)
         ("C-q"     . other-window-or-split)
         ([muhenkan] . my:keyboard-quit)))
```

`C-x C-c` は誤操作防止のため `server-edit` に変更しています。`delete-this-file` は現在編集中のファイルを確認後に削除してバッファも閉じます。

最後のフレームを閉じようとしたとき、削除せず最小化する `handle-delete-frame` の上書きも設定しています。


## 4. ダッシュボード（01-dashboard.el）

起動画面として `dashboard` を使用しています。

```code
(leaf dashboard
  :ensure t
  :if (display-graphic-p)
  :hook ((emacs-startup-hook . open-dashboard)
         (dashboard-mode-hook . (lambda () (set-window-margins (selected-window) 1 1))))
  :bind ([home] . dashboard-toggle))
```

マシン名が `P1` の場合は agenda も表示します。それ以外は recentf のみです。

```code
(if (string-match "P1" (system-name))
    (setq dashboard-items '((recents . 8) (agenda . 5)))
  (setq dashboard-items '((recents . 5))))
```

バナータイトルはシェルコマンドで動的に生成します。

```code
(setq dashboard-banner-logo-title
      (let* ((uname (split-string (shell-command-to-string "uname -rn")))
             (debian (string-trim (shell-command-to-string "cat /etc/debian_version"))))
        (format "GNU Emacs %s kernel %s Debian %s x86_64 GNU/Linux"
                emacs-version (cadr uname) debian)))
```

`[home]` キーで dashboard と直前のバッファをトグル表示できます。


## 5. Git 関連（02-git.el）

### 5.1. [magit] Git クライアント

```code
(leaf magit :ensure t
  :bind (("C-x g" . magit-status)
         ("M-g"   . hydra-magit/body))
  :config
  (setq magit-display-buffer-function
        #'magit-display-buffer-fullframe-status-v1))
```

`magit-status` はフルフレームで表示します。`M-g` で hydra メニューを呼び出せます。

```
hydra-magit: m)status  b)lame  c)heckout  l)og  g)itk  t)imemachine
```

`gitk-open` 関数でカレントディレクトリの gitk を起動できます。

### 5.2. [diff-hl] 編集差分の視覚化

```code
(leaf diff-hl :ensure t
  :hook ((after-init-hook . global-diff-hl-mode)
         (after-init-hook . diff-hl-margin-mode)))
```

フレーム端に変更箇所をカラーで表示します。色は `custom-set-faces` で明示設定しています。`hydra-diff`（evil-leader の `h`）で hunk 間の移動・revert が行えます。

### 5.3. その他

* `git-timemachine`：ファイルの git 履歴を時系列で閲覧
* `browse-at-remote`：カーソル位置の GitHub ページをブラウザで開く


## 6. Evil Mode（03-evil.el）

vi/vim スタイルの操作体系を導入しています。

### 6.1. 基本方針

insert state は自動的に emacs state に変換します。これにより、insert 状態では通常の Emacs キーバインドがそのまま使えます。

```code
(defalias 'evil-insert-state 'evil-emacs-state)
```

`[muhenkan]` キーでどの state からでも normal state に戻れます。IME も自動的に OFF になります。

```code
(defun my:return-to-normal-state ()
  (interactive)
  (when (use-region-p) (keyboard-escape-quit))
  (when current-input-method (deactivate-input-method))
  (evil-normal-state)
  (message "-- NORMAL --"))
```

### 6.2. キーバインド（normal state）

| キー | コマンド |
|------|---------|
| `C-a` | seq-home（行頭→バッファ先頭） |
| `C-e` | seq-end（行末→バッファ末尾） |
| `SPC` | set-mark-command |
| `_` | evil-visual-line |
| `[muhenkan]` | evil-insert（emacs state） |
| `[home]` | dashboard-toggle |

visual state では `;` でコメント、`c` でコピー、`g` でGoogle検索、`d` でDeepL翻訳、`t` でGoogle翻訳が使えます。

### 6.3. [evil-leader] リーダーキー

リーダーキーは `,` です。

| キー | コマンド |
|------|---------|
| `,0` / `,1` / `,2` / `,3` | ウィンドウ操作 |
| `,o` | other-window-or-split |
| `,w` | window-swap-states |
| `,[` / `,]` | previous/next-buffer |
| `,j` | evil-join-whitespace |
| `,h` | hydra-diff/body |
| `,,` / `,c` | org-capture |
| `,SPC` | avy-goto-word-1 |
| `,?` | vim cheat sheet |

### 6.4. j/k の挙動

折り返し行を自然に移動できるよう `j`/`k` と `gj`/`gk` を入れ替えています。

```code
(evil-swap-key evil-motion-state-map "j" "gj")
(evil-swap-key evil-motion-state-map "k" "gk")
```


## 7. 補完・スニペット

### 7.1. [counsel/ivy] 補完フレームワーク（04-counsel.el）

`ivy` / `counsel` / `swiper` を使用しています。

```code
(leaf counsel :ensure t
  :hook (after-init-hook . ivy-mode)
  :bind (("C-:"     . counsel-switch-buffer)
         ("M-x"     . counsel-M-x)
         ("M-y"     . counsel-yank-pop)
         ("C-,"     . counsel-mark-ring)
         ("s-a"     . counsel-ag)
         ("C-x C-f" . counsel-find-file)
         ("C-x C-r" . counsel-recentf)))
```

選択行には nerd-icons フォントのアイコンを表示しています。

#### 7.1.1. [migemo] 日本語インクリメンタル検索

`swiper` のみ `my:ivy-migemo-re-builder` を使い、ローマ字入力で日本語を検索できます。

```code
(setq ivy-re-builders-alist '((t . ivy--regex-plus)
                              (swiper . my:ivy-migemo-re-builder)))
```

スペースは `.*?` に変換されるため、複数キーワードの柔軟な検索が可能です。

#### 7.1.2. [avy] ジャンプ

```code
(leaf avy :ensure t
  :bind ("C-r" . avy-goto-word-1))
```

#### 7.1.3. swiper の使い分け

`C-s` にバインドした `swiper-region` は、リージョン選択中は `swiper-thing-at-point`、非選択時は通常の `swiper` として機能します。

### 7.2. [company] 自動補完（05-company.el）

```code
(leaf company :ensure t
  :hook (after-init-hook . global-company-mode)
  :bind (("<backtab>"   . company-complete)
         ("C-<tab>"     . company-yasnippet)))
```

全バックエンドに yasnippet を自動付加する設定を入れています。

### 7.3. [prescient] 補完候補の並び替え

`ivy-prescient` と `company-prescient` の両方を有効化し、使用頻度の高い候補を上位に表示します。履歴は `tmp/prescient-save` に永続化します。

### 7.4. [yasnippet] スニペット

```code
(leaf yasnippet :ensure t
  :hook (after-init-hook . yas-global-mode)
  :config (setq yas-indent-line 'fixed))
```


## 8. 日本語入力（06-mozc.el）

### 8.1. 基本設定

```code
(leaf mozc :ensure t
  :bind* ("<hiragana-katakana>" . my:toggle-input-method))
```

`my:toggle-input-method` は、evil-mode が有効なときに `<hiragana-katakana>` で IME を切り替えると同時に `evil-emacs-state` に遷移します。

句読点は mozc を介さず即時挿入します。

```code
(:mozc-mode-map
 ("," . (lambda () (interactive) (mozc-insert-str "、")))
 ("." . (lambda () (interactive) (mozc-insert-str "。"))))
```

### 8.2. mozc ツール起動

| キー | 機能 |
|------|------|
| `s-m` | 設定ダイアログ |
| `s-d` | 単語登録ダイアログ |
| `s-t` | 辞書ツール |

### 8.3. カーソル色による IME 状態表示

`mozc-cursor-color`（自作パッケージ、`elisp/mozc-cursor-color/` 配下）でIMEのオン・オフをカーソル色で視覚的に示します。

### 8.4. 候補表示

`mozc-popup` で変換候補をポップアップ表示します。

### 8.5. mozc_emacs_helper 互換パッチ

`mozc-protobuf-get` に `advice-add` でパッチを当て、`mozc_emacs_helper` の仕様変更後も動作するようにしています。


## 9. ハイライト・表示（07-highlight.el）

### 9.1. [goggles] 編集領域のフラッシュ

`volatile-highlights` の代替として `goggles` を使用しています。編集（追加・変更・削除）直後の領域をカラーでフラッシュします。

```code
(leaf goggles :ensure t
  :hook ((prog-mode-hook . goggles-mode)
         (text-mode-hook . goggles-mode))
  :config (setq-default goggles-pulse t))
```

### 9.2. [paren] 対応括弧のハイライト

```code
(leaf paren :ensure nil
  :hook (after-init-hook . show-paren-mode)
  :config
  (setq show-paren-style 'parenthesis)
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-when-point-in-periphery t))
```

### 9.3. [rainbow-delimiters] 括弧のレインボー表示

`prog-mode` で括弧の深さに応じて色分けします。

### 9.4. [aggressive-indent] 即時インデント整形

`global-aggressive-indent-mode` で有効化し、`html-mode` のみ除外しています。

### 9.5. [web-mode] Web テンプレート編集

`.js` / `.jsx` / `.html` / `.php` ファイルに適用します。`web-mode-enable-auto-indentation nil` で自動インデントを無効にしています。

### 9.6. electric-pair

`text-mode` では `electric-pair-local-mode` を無効化します（yasnippet との競合回避）。


## 10. Dimmer（08-dimmer.el）

非アクティブなウィンドウの輝度を落として、フォーカスを視覚的に明示します。

ウィンドウ構成が変わった最初のタイミングで自動的に有効化し、それ以降はフックを外します。

```code
(defun my:dimmer-activate ()
  (setq my:dimmer-enabled t)
  (dimmer-mode 1)
  (remove-hook 'window-configuration-change-hook #'my:dimmer-activate))
(add-hook 'window-configuration-change-hook #'my:dimmer-activate)
```

`::` キーコードでトグルできます。minibuffer 出入り時と imenu-list 表示時は自動的に OFF になります。

`dimmer-excludes` で which-key / magit / hydra / org との干渉を抑制しています。


## 11. ユーティリティ関数（09-funcs.el）

### 11.1. compilation バッファの自動クローズ

```code
(defun compile-autoclose (buffer string)
  (if (and (string-match "compilation" (buffer-name buffer))
           (string-match "finished" string))
      (progn
        (delete-other-windows)
        (message "Compile successful."))
    (message "Compilation exited abnormally: %s" string)))

(setq compilation-finish-functions #'compile-autoclose)
(setq compilation-scroll-output t)
(setq compilation-always-kill t)
```

### 11.2. ps-print 設定

`lpr` コマンドが存在する場合のみ設定します。A4・Courier・行番号付きで印刷します。

### 11.3. Gist 連携

```code
(defun gist-region-or-buffer ()
  "リージョン選択時はリージョンを、非選択時はバッファ全体を gist に投稿する。"
  ...)
```

`gist -o` でポスト後の URL をブラウザで自動表示します。


## 12. リージョン選択サポート（10-selected.el）

`selected.el` でリージョン選択時のワンキーアクションを設定しています。

```code
(leaf selected :ensure t
  :hook (after-init-hook . selected-global-mode)
  :bind (:selected-keymap
         (";" . comment-dwim)
         ("c" . clipboard-kill-ring-save)
         ("s" . swiper-thing-at-point)
         ("d" . deepl-translate)
         ("t" . google-translate-auto)
         ("w" . my:weblio)
         ("g" . my:google-this)))
```

リージョン選択開始時に IME を自動 OFF、解除時に元の状態に戻します。

`google-this` パッケージで `my:google-this` を定義し、`C-c g` および visual state の `g` にバインドしています。


## 13. 構文チェック（20-check.el）

### 13.1. [flycheck] 構文エラー表示

`flymake` から `flycheck` に移行しています。

```code
(leaf flycheck :ensure t
  :hook ((prog-mode-hook . flycheck-mode)
         (gfm-mode-hook  . flycheck-mode))
  :bind ("C-c f" . flycheck-list-errors))
```

leaf-keywords の `"Unrecognized keyword"` エラーを回避するため `flycheck-emacs-lisp-package-initialize-form` を設定しています。

### 13.2. [textlint] 文章の lint

markdown / gfm / org / web-mode 対象の `textlint` チェッカーを `flycheck-define-checker` で定義しています。

### 13.3. [ispell / hunspell] スペルチェック

```code
(setq ispell-program-name "hunspell")
(setq ispell-really-hunspell t)
(add-to-list 'ispell-skip-region-alist '("[^\000-\377]+"))
```

日本語文字コード範囲はスキップします。


## 14. 編集サポート（20-edit.el）

### 14.1. [super-save] スマート自動保存

`auto-save-buffers-enhanced` から `super-save` に移行しました。

```code
(leaf super-save :ensure t
  :hook (after-init-hook . super-save-mode)
  :config
  (setq super-save-auto-save-when-idle t)
  (setq super-save-idle-duration       1)
  (setq super-save-remote-files        nil)
  (setq super-save-exclude             '(".gpg")))
```

アイドル1秒で自動保存します。リモートファイルと `.gpg` は除外します。

### 14.2. [imenu-list] サイドバー目次

```code
(leaf imenu-list :ensure t
  :bind ([f2] . imenu-list-smart-toggle)
  :config
  (setq imenu-list-focus-after-activation t)
  (setq imenu-list-auto-resize t)
  (setq imenu-list-position 'left))
```

### 14.3. [atomic-chrome] ブラウザとの連携

```code
(leaf atomic-chrome :ensure t
  :hook (after-init-hook . atomic-chrome-start-server)
  :config (setq atomic-chrome-buffer-open-style 'full))
```

ブラウザのテキストエリアを Emacs でフルフレーム編集できます。

### 14.4. [undo-fu] シンプルな undo/redo

```code
(leaf undo-fu :ensure t
  :bind (("C-_" . undo-fu-only-undo)
         ("C-/" . undo-fu-only-redo)))
```

evil の undo システムも `undo-fu` に統一しています（`evil-undo-system 'undo-fu`）。

### 14.5. [undohist] undo 履歴の永続化

undo 履歴を `tmp/undohist/` に保存し、ファイルを開き直しても undo できます。

### 14.6. その他

* `iedit`（`<insert>`）：複数箇所の同時編集
* `expand-region`（`C-@`）：選択範囲を賢く拡張
* `ediff`：水平分割・シンプルモードで差分編集
* `sudo-edit`：現在のファイルを root 権限で編集


## 15. UI・外観（30-ui.el）

### 15.1. テーマ

`doom-themes` の `doom-dracula` を使用しています。

```code
(leaf doom-themes :ensure t
  :hook (after-init-hook . (lambda () (load-theme 'doom-dracula t)))
  :config
  (setq doom-themes-enable-italic nil)
  (doom-themes-org-config))
```

### 15.2. [doom-modeline] モードライン

```code
(leaf doom-modeline :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :config
  (setq doom-modeline-icon            t)
  (setq doom-modeline-major-mode-icon nil)
  (setq doom-modeline-minor-modes     nil)
  (line-number-mode   0)
  (column-number-mode 0))
```

### 15.3. [nerd-icons] アイコン表示

`all-the-icons` から `nerd-icons` に移行しました。`nerd-icons-dired` で dired バッファにアイコンを表示します。

初回は `M-x nerd-icons-install-fonts` でフォントをインストールしてください。

### 15.4. [hide-mode-line] モードラインの非表示

imenu-list と neotree のバッファではモードラインを非表示にします。

### 15.5. 行番号表示

`display-line-numbers`（built-in）を `prog-mode` / `text-mode` で有効化します。`[f9]` でトグルできます。

### 15.6. [whitespace] 不要スペースの除去

`my:cleanup-for-spaces-safe`（`C-c C-c`）で行末の空白・タブ・NBSP・ゼロ幅スペースと末尾の空行をまとめて削除します。

### 15.7. 折り返し列インジケーター

`display-fill-column-indicator`（built-in）を gfm / text-mode で有効化し、79列目にガイドラインを表示します。


## 16. ユーティリティ（30-utils.el）

### 16.1. [which-key] キーバインドのポップアップ

Emacs 29 built-in になりました。`which-key-delay 0.0` で即時表示します。

### 16.2. [key-chord] 同時押しキーバインド

`elisp/key-chord/` のローカルパッケージを使用しています。

| chord | コマンド |
|-------|---------|
| `df` | counsel-descbinds |
| `l;` | init-loader-show-log |

### 16.3. [counsel-tramp] リモートファイル編集

`scp` メソッドで xsrv サーバーへのクイック接続を設定しています。

### 16.4. [viewer] view-mode のモードライン色変更

view-mode 時にモードラインの色を変えて視覚的に区別します。

### 16.5. [persistent-scratch] scratch バッファの永続化

`auto-save-buffers-enhanced` の scratch 保存機能を `persistent-scratch` に移行しました。

```code
(leaf persistent-scratch :ensure t
  :hook (after-init-hook . persistent-scratch-autosave-mode)
  :bind ("S-<return>" . toggle-scratch))
```

`S-<return>` で scratch バッファと直前のバッファをトグルします。

### 16.6. [bs] バッファ循環

`M-]` / `M-[` でバッファを順番に切り替えます。

### 16.7. [projectile] プロジェクト管理

```code
(leaf projectile :ensure t
  :hook (after-init-hook . projectile-mode))
```

### 16.8. [sequential-command] バッファ端への移動

`elisp/sequential-command/` のローカルパッケージを使用しています。

* `C-a` を連続で押すと 行頭 → バッファ先頭 → 元の位置
* `C-e` を連続で押すと 行末 → バッファ末尾 → 元の位置


## 17. Hydra メニュー

### 17.1. [hydra-dired] ディレクトリ・ランチャー（40-hydra-dired.el）

`M-.` で起動します。ディレクトリへのクイックアクセスと外部アプリの起動をまとめています。

主な機能：

* `my:make`：`make <target>` を指定ディレクトリで実行
* `my:open`：ファイル・ディレクトリをオプションで top/bottom 指定して開く
* `my:reload-keychain`：keychain の SSH_AUTH_SOCK を Emacs セッションに再読み込み
* `fzilla-*`：FileZilla を特定サイトで起動
* `keepassxc`：KeePassXC を起動

`hydra-work`（`<henkan>`）と相互トグルできます。

### 17.2. [hydra-work] 作業メニュー（40-hydra-menu.el）

`<henkan>` で起動します。俳句・文芸関係のワークスペースへのショートカットが中心です。

主な機能：

* `terminal-open`（`[f3]`）：カレントディレクトリで gnome-terminal を開き、`xdotool` で隣接ディスプレイに移動
* `thunar-open`（`[f6]`）：カレントディレクトリで Thunar を開き、同様に移動
* `xsrv-gh`（`[f4]`）：xsrv への SSH 接続ターミナルを起動
* `my:run-myjob`：外部スクリプト `myjob.sh` を非同期実行
* 各種文芸ファイルへのクイックアクセス

### 17.3. [hydra-browse] ブラウザランチャー（40-hydra-misc.el）

`..`（key-chord）で起動します。お気に入りサイトへのワンキーアクセスです。

### 17.4. [hydra-package] パッケージ管理

`@@`（key-chord）で起動します。Emacs 29 の built-in パッケージ管理コマンドを利用します。

```
i)nstall  d)elete  u)pgrade  a)ll-upgrade  v)c-update-all
```

### 17.5. [hydra-markdown] Markdown 編集

`40-hydra-misc.el` で定義しています。markdown-mode から呼び出します。

```
i)talic  x)消線  n)footnote  t)able  m)arkup  v)iew  e)xport  p)df  d)ocx
```


## 18. Dired（50-dired.el）

### 18.1. 基本設定

`ls-lisp` を使用することで外部 `ls` コマンドに依存しない構成にしています。

```code
(setq ls-lisp-use-insert-directory-program nil)
(setq ls-lisp-dirs-first t)        ;; ディレクトリを先頭に表示
(setq dired-listing-switches "-AFl")
(setq dired-omit-files "^\\.$\\|^\\.[^\\.].*$\\|\\.elc$")
```

### 18.2. キーバインド

| キー | 機能 |
|------|------|
| `<left>` | 親ディレクトリへ（バッファ増やさない） |
| `<right>` / `RET` | 状況に応じて開く（ファイルは新バッファ、ディレクトリは同バッファ） |
| `w` | wdired モード |
| `s` | sudo-edit |
| `o` | xdg-open で関連アプリで開く |
| `i` | sxiv で画像一覧表示 |
| `a` | dired-omit-mode トグル |

### 18.3. sxiv 連携

`call-sxiv` でディレクトリ内の画像（jpg / png / gif / bmp）を `sxiv` でサムネイル一覧表示します。


## 19. Neotree（50-neotree.el）

```code
(leaf neotree :ensure t
  :after projectile
  :bind (("<f10>" . my:neotree-find)))
```

`doom-themes-neotree-config` でテーマと統合しています。

ファイルを開いたら neotree を自動で閉じ `dimmer-on` します（`neotree-enter-hide`）。起動時にテキストを1段階縮小します（`neotree-text-scale`）。


## 20. メモ環境

### 20.1. [howm] Wiki 型メモ（60-howm.el）

```code
(leaf howm :ensure t
  :hook (emacs-startup-hook . howm-mode))
```

メモは `~/Dropbox/howm/` に Markdown 形式（`.md`）で保存します。ファイル名は `%Y/%m/%Y%m%d%H%M.md` の形式です。

#### 20.1.1. カテゴリ色分け

`howm-user-font-lock-keywords` で以下のカテゴリを色分けしています。

`memo:` / `note:` / `tech:` / `教会:` / `園芸:` / `日記:` / `創作:`

#### 20.1.2. メモ作成

テンプレートを3種類定義しています。

| 関数 | テンプレート |
|------|------------|
| `my:howm-create-memo`（summary の `,`） | `# memo:` |
| `my:howm-create-tech`（summary の `;`） | `# tech:` |

メモ作成後は自動的に `delete-other-windows` + `evil-emacs-state` に遷移します。

#### 20.1.3. super-save との連携

`my:howm-fix-after-super-save` で、howm ファイル保存時に Perl スクリプト（`howm-fix-code-comments.pl`）を実行してコードコメントを自動修正します。

#### 20.1.4. migemo 連携

`howm-use-migemo t` でローマ字入力による日本語検索が可能です。

### 20.2. [org] タスク管理（60-org.el）

org-agenda を使ったタスク管理に限定して使用しています。タスクファイルは `~/Dropbox/howm/org/task.org` です。

`org-capture-templates` で howm ファイルへ直接書き込むテンプレートを多数定義しています。

| キー | カテゴリ |
|------|---------|
| `d` | 日記 |
| `w` | 創作 |
| `e` | 園芸 |
| `c` | 教会 |
| `m` | Memo |
| `i` | Idea |
| `t` | Tech |
| `j` | Junk（Perl スクリプト） |
| `,` | Task（task.org） |

`org-capture` 起動時は全画面表示し `evil-emacs-state` に遷移します。

### 20.3. [calendar / japanese-holidays]

`[f7]` でカレンダーをトグル表示します。土日祝日を色分けして表示します。

### 20.4. [persistent-scratch] scratch バッファ

`S-<return>` で scratch バッファと直前のバッファをトグルします（`30-utils.el` 参照）。


## 21. Markdown 編集（60-markdown.el）

### 21.1. 基本設定

```code
(leaf markdown-mode :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode)))
```

### 21.2. プレビュー

`pandoc` + Chrome でプレビューします。カスタム CSS（`markdown-cream.css`）と `highlight.js` を使ったシンタックスハイライト付きです。

```code
(setq markdown-command
      "pandoc -f markdown+header_attributes-raw_html -t html5")
(setq browse-url-generic-program "google-chrome")
```

### 21.3. howm コードコメント修正

`my:howm-fix-code-comments`（`C-c #`）で howm ファイルのコードブロック内の `# ` を `## ` に置換します。リージョン選択時はバッファ内処理、非選択時は Perl スクリプト経由で処理します。

### 21.4. PDF・docx 変換

| 関数 | 変換先 |
|------|-------|
| `md2pdf` | pandoc + lualatex で PDF 生成 → `xdg-open` で表示 |
| `md2docx` | pandoc で docx 生成 → `xdg-open` で表示 |

`hydra-markdown` から呼び出せます。

### 21.5. その他

* `my:delete-tmp-markdown-html`：markdown バッファを閉じると `/tmp/burl*.html` を自動削除
* `gen-toc-term`：Perl スクリプトで目次を生成し gnome-terminal で表示


## 22. 翻訳（70-translate.el）

### 22.1. [deepl-translate] DeepL API 翻訳

自作パッケージ（`elisp/deepl-translate/` 配下）です。

```code
(leaf deepl-translate
  :bind ("C-c d" . deepl-translate))
```

API キーは `~/Dropbox/backup/tokens/deepl-api.el` から読み込みます。2026-03-10 の DeepL API 仕様変更（認証方式を Authorization ヘッダー方式に変更）に対応済みです。

### 22.2. [google-translate] Google 翻訳

```code
(leaf google-translate :ensure t
  :bind ("C-c t" . google-translate-auto))
```

`google-translate-auto` は日本語↔英語を自動判定して翻訳します。

### 22.3. [deepl-translate-web] ブラウザで DeepL

```code
(leaf deepl-translate-web
  :bind ("C-c w" . my:deepl-translate))
```

リージョン・文・カーソル位置から対象テキストを取得し、DeepL の Web サイトをブラウザで開きます。


## 23. YaTeX（70-yatex.el）

LaTeX 編集環境です。

```code
(leaf yatex :ensure t
  :mode ("\\.tex\\'" "\\.sty\\'" "\\.cls\\'")
  :config
  (setq tex-command             "platex")
  (setq dviprint-command-format "dvpd.sh %s"))
```

`dvpd.sh` は `dvipdfmx` で PDF を生成して `evince` で表示するシェルスクリプトです。

| キー | コマンド |
|------|---------|
| `M-c` | YaTeX-typeset-buffer（コンパイル） |
| `M-v` | YaTeX-lpr（dvpd.sh 実行） |


## 24. 執筆モード（80-darkroom.el）

`[f8]` で darkroom モードに入ります。

```code
(defun my:darkroom-in ()
  (diff-hl-mode 0)
  (display-line-numbers-mode 0)
  (darkroom-tentative-mode 1)
  (toggle-frame-fullscreen)
  (setq-local line-spacing .2)
  (evil-emacs-state))

(defun my:darkroom-out ()
  (darkroom-tentative-mode 0)
  (display-line-numbers-mode 1)
  (diff-hl-mode 1)
  (toggle-frame-fullscreen)
  (setq-local line-spacing 0)
  (evil-normal-state))
```

IN 時：diff-hl・行番号を非表示にし、全画面・行間を広げて `evil-emacs-state` へ遷移します。

OUT 時（`[f8]` で戻る）：すべて元に戻し `evil-normal-state` へ遷移します。


## 25. ブログ管理（90-easy-hugo.el）

[`easy-hugo`](https://github.com/masasam/emacs-easy-hugo) で Hugo 製のブログを管理しています。

メインブログ（snap）を blog1 として、`easy-hugo-bloglist` で blog2〜8 まで計8サイトを管理しています。

```code
(setq easy-hugo-basedir "~/Dropbox/minorugh.com/snap/")
(setq easy-hugo-url    "https://snap.minorugh.com")
```

新規ポスト作成後は `advice-add` で `my:easy-hugo-newpost-after` を実行し、`evil-emacs-state` に切り替えてカーソルを末尾に移動・保存します。

`e` キーで設定ファイル（`90-easy-hugo.el`）を直接開けます。


## 26. おわりに

私の Emacs は、Web ページのメンテナンスや俳句・文芸活動がメインで、「賢くて多機能なワープロ」という存在です。

本設定の特徴をまとめると以下のとおりです。

* **evil-mode** を中心とした vi/vim スタイルの操作体系
* **leaf.el** による宣言的なパッケージ管理
* **howm** + **org** + **markdown** によるメモ・文書管理
* **hydra** による階層的なコマンドランチャー（hydra-dired / hydra-work / hydra-browse）
* **nerd-icons** / **doom-themes** / **doom-modeline** による現代的な UI
* `tmp/` 配下への履歴・キャッシュの一元管理
* `elisp/` 配下へのローカルパッケージの集約

<div style="float:left">
&ensp;<a href="https://twitter.com/share" class="twitter-share-button" data-via="minorugh" data-lang="jp" data-count="horizontal">Tweet</a>
</div>
