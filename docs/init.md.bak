---
layout: default
title: Emacs Configuration
---

# Emacs Configuration

## 1. はじめに
```note
* ここは [@minoruGH](https://twitter.com/minorugh)  の Emacs設定ファイルの一部を解説しているページです。
* [init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el) 本体は、[GitHub](https://github.com/minorugh/dotfiles/tree/main/.emacs.d) に公開しています。
* 本ドキュメントは、[@takaxp](https://twitter.com/takaxp)さんの了解を得て [takaxp.github.io/](https://takaxp.github.io/init.html) の記事を下敷きにした模倣版です。
```
![emacs](https://minorugh.github.io/img/emacs29.4.png)

### 1.1. 動作確認環境
以下の環境で使用しています。が、動作を保証するものではありません。

* ThinkPad P1 Gen1 i7/32GB/1TB
* Debian 12.7  86_64 GNU/Linux
* 自分でビルドした GNU Emacs 29.4

### 1.2. デレクトリ構成
* 設定ファイルの構成は下記のとおりです。

```codesession
~/.emacs.d
│
├── elisp/
├── elpa/
├── inits/
│   ├── 00_base.el
│   ├── 01_dashboard.el
│   ├── ...
│   ├── 90_ecode.el
│   └── 99_chromium.el
├── snippets/
├── tmp/
├── early-init.el
├── init.el
└── mini-init.el

```

## 2. 起動設定
* Emacs-29.4導入にあわせて `early-init.el` を設定しました。 
* ブートシーケンスは以下のとおり。

1. `early-init.el` の読み込み
2. `init.el` の読み込み
3. `inits/` のファイル群を読み込み （init-loader 使用）

### 2.1. [early-init.el] eary-initを使う
* [`early-init.el`](https://ayatakesi.github.io/emacs/28.1/html/Early-Init-File.html) は、Emacs27から導入されました。 
* [https://github.com/minorugh/dotfiles/blob/main/.emacs.d/early-init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/early-init.el)

`init.el` でパッケージシステムやGUIの初期化が実行される前にロードされるので、UI関係や `package-enable-at-startup` のようなパッケージ初期化プロセスに影響を与える変数をカスタマイズできます。

#### 2.1.1. GCを減らす
GC の閾値を最大にしておくことで GC を実質止めることができます。これもとりあえず書いておけば速くなる系なのでおすすめです。

```code
(setq gc-cons-threshold most-positive-fixnum)
```

起動をわずかに高速化するには、package-enable-at-startup を nil に設定します


#### 2.1.2. 初期フレーム設定
これらの設定を、`eary-init.el`へ移すことで起動時間を短縮できます。

```code
(push '(fullscreen . maximized) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
```

#### 2.1.3. 画面のチラつきを抑える
* 初期化ファイル読み込みのプロセスで画面がチラつくのを抑制しています。

```code
;; Suppress flashing at startup
(setq inhibit-redisplay t)
(setq inhibit-message t)
(add-hook 'window-setup-hook
		  (lambda ()
			(setq inhibit-redisplay nil)
			(setq inhibit-message nil)
			(redisplay)))

;; Startup setting
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq byte-compile-warnings '(cl-functions))
(custom-set-faces '(default ((t (:background "#282a36")))))
```

### 2.2. [init.el] Emacs27に対応
* `early.init.el` とともにEmacs27に対応させました。
* [https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/init.el) 

#### 2.2.1. 初期フレームの設定
* Magic File Name を一時的に無効にすることで、起動時間を短縮できます。
* GC設定とともに設定ファイル読み込み後に正常値に戻します。

```code
(unless (or (daemonp) noninteractive init-file-debug)
  (let ((old-file-name-handler-alist file-name-handler-alist))
    (setq file-name-handler-alist nil)
    (add-hook 'emacs-startup-hook
              (lambda ()
                "Recover file name handlers."
                (setq file-name-handler-alist
                      (delete-dups (append file-name-handler-alist
                                           old-file-name-handler-alist)))))))

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda ()
            "Recover GC values after startup."
            (setq gc-cons-threshold 800000)))
```

#### 2.2.2. leaf.elを使う
`use-pacage.el` を使っていましたが、
[@conao3](https://qiita.com/conao3) さんの開発された `leaf.el` に触発されて全面的に書き直しました。

[Emacs入門から始めるleaf.el入門](https://qiita.com/conao3/items/347d7e472afd0c58fbd7)

```code
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
					   ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
	(package-refresh-contents)
	(package-install 'leaf))

  (leaf leaf-keywords
	:ensure t
	:init
	(leaf hydra :ensure t)
	(leaf el-get :ensure t)
	:config
	(leaf-keywords-init)))
```


#### 2.2.3. init-loader を使う

* [emacs-jp/init-loader:Loader of configuration files.](https://github.com/emacs-jp/init-loader/) 

`init-loader.el` は、設定ファイル群のローダーです。 指定されたディレクトリから構成ファイルをロードします。これにより、構成を分類して複数のファイルに分けることができます。

`init-loader` には、エラーが出た設定ファイルは読み込まれない...という特徴があり原因究明がしやすくなるというメリットがある。またログの出力機能を備えていることもメリットとして挙げられる。

起動時間が犠牲になるということで敬遠される向きもあるが微々たるもので、恩恵のほうが遥かに大きい。

```code
(leaf init-loader
  :ensure t
  :config
  (custom-set-variables
   '(init-loader-show-log-after-init 'error-only))
  (init-loader-load))
```

### 2.3. [test.el] テスト用の最小初期化ファイル
* 最小限の emacs を起動させるための設定です。

[`test.el`](https://github.com/minorugh/dotfiles/blob/main/.emacs.d/test.el) は、
新しいパッケージを試したり設定をテストしたり、エラー等で Emacsが起動しない場合などに使用します。

以下を `.zshrc` または `.coderc` に記述し反映させたのち、シェルから `eq` と入力することで起動することがでます。

```code
alias eq = 'emacs -q -l ~/.emacs.d/test.el'
```

ファイルの PATH は、ご自分の環境に応じて修正が必要です。

### 2.4. [server.el] Server機能を使う

```code
;; Server start for emacs-client
(leaf server
  :require t
  :config
  (unless (server-running-p)
    (server-start)))
```

### 2.5. [exec-path-from-shell.el] 設定をシェルから継承する

* [purcell/exec-path-from-shell: Make Emacs use the $PATH set up by the user's shell](https://github.com/purcell/exec-path-from-shell) 

外部プログラムのサポートを得て動くパッケージは、設定の過程で「プログラムが見つからない」と怒られることがしばしばあります。 `exec-path-from-shell` は、シェルに設定した `PATH` の情報を継承して `exec-path` や `PATH` を設定してくれます。自分は、`shell-commad` や `compile-command` をよく使うので必須のパッケージです。

```Code
(leaf exec-path-from-shell
  :ensure t
  :when (memq window-system '(mac ns x))
  :hook (after-init-hook . exec-path-from-shell-initialize)
  :custom (exec-path-from-shell-check-startup-files . nil))
```
  

## 3. コア設定
Emacs を操作して日本語文書編集するうえで必要な設定。

### 3.1. 言語 / 文字コード
シンプルにこれだけです。

``` code
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
```

### 3.2. [emacs-mozc] 日本語入力
* Debian11 にインストールした Emacs上で [`emacs-mozc`](https://wiki.debian.org/JapaneseEnvironment/Mozc) を使っています。
* debian でのインストール手順は以下の通り。

```code
$ sudo apt-get install fcitx-mozc emacs-mozc
```

Emacsをソースからビルドするときに `--without-xim` しなかったので、インライン XIMでも日本語入力ができてしまいます。
特に使い分けする必要もなく紛らわしいので `.Xresources` で XIM無効化の設定をしました。

```code
! ~/.Xresources
! Emacs XIMを無効化
Emacs*useXIM: false
```

句読点などを入力したとき、わざわざ mozcに変換してもらう必要はないので以下を設定しておくことでワンアクションスピーディーになります。
```code
(leaf mozc
  :ensure t
  :bind (("<hiragana-katakana>" . toggle-input-method)
		 (:mozc-mode-map
		  ("," . (lambda () (interactive) (mozc-insert-str "、")))
		  ("." . (lambda () (interactive) (mozc-insert-str "。")))
		  ("?" . (lambda () (interactive) (mozc-insert-str "？")))
		  ("!" . (lambda () (interactive) (mozc-insert-str "！")))))
  :custom `((default-input-method . "japanese-mozc")
			(mozc-helper-program-name . "mozc_emacs_helper")
			(mozc-leim-title . "かな"))
  :config
  (defun mozc-insert-str (str)
	(mozc-handle-event 'enter)
	(insert str))
  (defadvice toggle-input-method (around toggle-input-method-around activate)
	"Input method function in key-chord.el not to be nil."
	(let ((input-method-function-save input-method-function))
	  ad-do-it
	  (setq input-method-function input-method-function-save))))
```

Emacsで文章編集中にShellコマンドで [`mozc-tool`](https://www.mk-mode.com/blog/2017/06/27/linux-mozc-tool-command/) を起動し、Emacsを閉じることなく単語登録できるようにしています。

```code
(leaf *cus-mozc-tool
  :bind (("s-t" . my:mozc-dictionary-tool)
		 ("s-d" . my:mozc-word-regist))
  :init
  (defun my:mozc-dictionary-tool ()
	"Open `mozc-dictipnary-tool'."
	(interactive)
	(compile "/usr/lib/mozc/mozc_tool --mode=dictionary_tool")
	(delete-other-windows))

  (defun my:mozc-word-regist ()
	"Open `mozc-word-regist'."
	(interactive)
	(compile "/usr/lib/mozc/mozc_tool --mode=word_register_dialog")
	(delete-other-windows)))
```

### 3.3. [Mozc] 辞書の共有
Linux環境でMozcを使うメリットは辞書の共有です。

1. Emacs以外のコンテンツでも同じMozc辞書を使うのでEmacsから単語登録しておけば全てのコンテンツで有効になる。
2. 辞書ファイルをDropboxなどのクラウドに置くことで複数のマシンで共有できる。

#### 3.3.1. Dropboxで辞書を共有する
やり方は簡単です。

1. Dropboxに `~/Dropbox/mozc` フォルダを新規作成します。
2. つぎに、`~/.mozc` フォルダーを `~/Dropboc/mozc/` へコピーします。
2. 最後に、`~/.mozc` を削除してDropboxにコピーした `.mozc` のシンボリックファイルを `~/` へ貼り付けます。

`makefile` で自動化するなら次のようになるかと思います。

```code
mozc_copy:
	mkdir -p ~/Dropbox/mozc
	cp -r ~/.mozc/ ~/Dropbox/mozc/
	test -L ~/.mozc || rm -rf ~/.mozc
	ln -vsfn ~/Dropbox/mozc/.mozc ~/.mozc
```

#### 3.3.2. 辞書共有の問題点
Dropboxに保存された辞書ファイルを複数マシンで同時アクセスした場合、複製（競合コピー）がいっぱい作られるという問題があります。
Google Driveは大丈夫という情報もありますが試せてません。

### 3.4. 基本キーバインド
* いつでもどこでも使えるキーバインド周りの設定をここにまとめています。 

```code
;; C-h is backspace
(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))
(bind-key "M-w" 'clipboard-kill-ring-save)
(bind-key "C-w" 'my:clipboard-kill-region)
(bind-key "s-c" 'clipboard-kill-ring-save)	 ;; Like mac
(bind-key "s-v" 'clipboard-yank)    ;; Like mac
(bind-key "M-/" 'kill-this-buffer)  ;; No inquiry
(bind-key "C-_" 'undo-fu-only-undo) ;; Use undu-fu.el
(bind-key "C-/" 'undo-fu-only-redo) ;; Use undo-fu.el
```

```code
(defun my:kill-whoile-ine-or-region ()
  "If the region is active, to kill region.
If the region is inactive, to kill whole line."
  (interactive)
  (if (use-region-p)
	  (clipboard-kill-region (region-beginning) (region-end))
    (kill-whole-line)))
```

### 3.5. マウスで選択した領域を自動コピー
マウスで選択すると，勝手にペーストボードにデータが流れます．

```code
(setq mouse-drag-copy-region t)
```
### 3.6. compilation buffer を自動的に閉じる
`compile` コマンドをよく使うので実行後は自動で閉じるようにしました。

```code
(setq compilation-always-kill t)
(setq compilation-finish-functions 'compile-autoclose)

(defun compile-autoclose (buffer string)
  "Automatically close the compilation buffer."
  (cond ((string-match "finished" string)
	     (bury-buffer "*compilation*")
		 (delete-other-windows)
		 (message "Build successful."))
	    (t (message "Compilation exited abnormally: %s" string))))
```
また、defaultだと出力が続いてもスクロールされないので自動的にスクロールさせる設定を追加。
```code
(setq compilation-scroll-output t)
```

### 3.7. C-x C-c でEmacsを終了させないようにする
* 終了させることはまずないので、再起動コマンドに変更しています。
* [`restart-emacs`](https://github.com/iqbalansari/restart-emacs) はMELPAからインストールできます。

```code
(leaf restart-emacs
  :ensure t
  :bind ("C-x C-c" . restart-emacs))
```
### 3.8. [aggressive-indent.el] 即時バッファー整形
特定のメジャーモードで、とにかく整形しまくります。

```code
(leaf aggressive-indent
  :ensure t
  :hook ((code-mode-hook css-mode-hook) . aggressive-indent-mode))
```
### 3.9.  [uniquify.el] 同じバッファ名が開かれた場合に区別する
ビルトインの `uniquify` を使います。モードラインの表示が変わります。

```code
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
```

### 3.10. [el-get] パッケージ管理
* MELPAをメインに管理していますが、MELPAにないものは`el-get` でGitHubやEmacsWikiからインストールします。
* 個人用に開発したものも、自分のGitHubリポジトリで管理し`el-get` で読み込んでいます。

## 4. カーソル移動
* 文字移動、行移動、スクロールは、素直に上下左右の矢印キーと`PgUp` `PgDn` を使っています。

### 4.1. [sequential-command.el] バッファー内のカーソル移動
* [https://github.com/HKey/sequential-command](https://github.com/HKey/sequential-command)

標準の `C-a` `C-e` を拡張し、バッファーの先頭と最終行への移動を簡単にしてくれます。
* `C-a` を連続で打つことで行頭→ファイルの先頭→元の位置とカーソルが移動
* `C-e` を連続で打つことで行末→ファイルの最終行→元の位置とカーソルが移動

地味ながら一度使うと便利すぎて止められません。

MELPAから Installできますが、私は HKey氏の改良版を `el-get` でインストールしました。
```code
(leaf sequential-command
  :doc "https://bre.is/6Xu4fQs6"
  :el-get HKey/sequential-command
  :config
  (leaf sequential-command-config
	:hook (emacs-startup-hook . sequential-command-setup-keys)))
```

### 4.2. ウインドウ間のカーソル移動
`C-c o` でもいいですが，ワンアクションで移動できるほうが楽なので、次のように双方向で使えるように設定しています．

画面分割されていないときは、左右分割して新しいウインドウに移動します。

```code
(defun other-window-or-split ()
 "With turn on dimmer."
 (interactive)
 (when (one-window-p)
	 (split-window-horizontally)
	 (follow-mode 1)
	 (dimmer-mode 1))
   (other-window 1))
(bind-key "C-q" 'other-window-or-split)
```

### 4.3. 対応する括弧を選択
* `C-M-SPC` (mark-sexp) は，カーソル位置から順方向に選択．
* `C-M-U` (backward-up-list) は，一つ外のカッコの先頭にポイントを移す．

上記標準機能は使いにくいので `my:jump-brace` を定義しました。
括弧の先頭と最後へ交互にポイント移動します。
```code
(defun my:jump-brace ()
 "Jump to the corresponding parenthesis."
 (interactive)
 (let ((c (following-char))
	 (p (preceding-char)))
   (if (eq (char-syntax c) 40) (forward-list)
	 (if (eq (char-syntax p) 41) (backward-list)
       (backward-up-list)))))
(bind-key "C-M-9" 'my:jump-brace)
```

### 4.4. マーク箇所を遡る
`C-u C-SPC` で辿れるようになります。
```code
(setq set-mark-command-repeat-pop t)
(setq mark-ring-max 32)
(setq global-mark-ring-max 64)
```
`C-x C-x` は、直前の編集ポイントと現在のポイントとを行き来できる設定です。

```code
(defun my:exchange-point-and-mark ()
  "No mark active `exchange-point-and-mark'."
  (interactive)
  (exchange-point-and-mark)
  (deactivate-mark))		 
(bind-key "C-x C-x" 'my:exchange-point-and-mark)
```

### 4.5 [expand-region.el] カーソル位置を起点に選択範囲を賢く広げる
[`expand-region.el`](https://github.com/magnars/expand-region.el) は、カーソル位置を起点として前後に選択範囲を広げてくれます。

2回以上呼ぶとその回数だけ賢く選択範囲が広がりますが、2回目以降は設定したキーバインドの最後の一文字を連打すれば OKです。その場合、選択範囲を狭める時は - を押し， 0 を押せばリセットされます。

```code
(leaf expand-region
  :ensure t
  :bind ("C-@" . er/expand-region))
```

## 5. 編集サポート / 入力補助
ファイル編集や入力補助の設定をまとめている。

### 5.1. 矩形編集/連番入力
24.4 からは、`rectangle-mark-mode` が使えるようになり `C-x SPC` を押下すると矩形モードに入り直感的に矩形選択ができる。

標準の `rect.el` に以下の機能が実装されている。

|矩形切り取り|	C-x r k |
|矩形削除	 |  C-x r d |
|矩形貼り付け|	C-x r y |
|矩形先頭に文字を挿入|	C-x r t |
|矩形を空白に変換する|	C-x r c |

### 5.2. markdownモード
[`markdown-mode.el`](https://github.com/jrblevin/markdown-mode) は、Markdown形式のテキストを編集するための主要なモードです。

```code
(leaf markdown-mode
  :ensure t
  :mode ("\\.md\\'")
  :custom
  `((markdown-italic-underscore . t)
    (markdown-asymmetric-header . t)
	(markdown-fontify-code-blocks-natively . t))
```

markdownファイルのプレビューには、[`emacs-livedown`](https://github.com/shime/emacs-livedown) を使っています。
記事を書きながらライブでプレビュー出来るすぐれものです。

[https://github.com/shime/emacs-livedown](https://github.com/shime/emacs-livedown)

npmがインストールされたnodeが入っていことを確認してからlivedownをインストールします。
```code
$ npm install -g livedown
```

次にEmacsの設定を書きます。
MELPAにはないので`el-get` でインストールします。

```code
(leaf emacs-livedown
 :el-get shime/emacs-livedown
 :bind (("C-c C-c p" . livedown-preview)
        ("C-c C-c k" . livedown-kill)))
```

### 5.3. viewモード
特定の拡張子に対して常に view モードで開きたいときやgzされた code ソースを見るときに [view-mode](https://www.emacswiki.org/emacs/ViewMode) を使います。

下記の設定では、`my:auto-view-dirs` に追加したディレクトリのファイルを開くと `view-mode` が常に有効になります．

```code
(leaf view
  :hook
  (find-file-hook . my:auto-view)
  (server-visit-hook . my:unlock-view-mode)
  :chord ("::" . view-mode)
  :bind (:view-mode-map
		 ("h" . backward-char)
		 ("l" . forward-char)
		 ("a" . beginning-of-buffer)
		 ("e" . end-of-buffer)
		 ("w" . forward-word)
		 ("b" . scroll-down)
		 ("c" . kill-ring-save)
		 ("r" . xref-find-references)
		 ("RET" . xref-find-definitions)
		 ("x" . my:view-del-char)
		 ("y" . my:view-yank)
		 ("d" . my:view-kill-region)
		 ("u" . my:view-undo)
		 ("m" . magit-status)
		 ("g" . my:google)
		 ("s" . swiper-region)
		 ("%" . my:jump-brace)
		 ("@" . counsel-mark-ring)
		 ("n" . my:org-view-next-heading)
		 ("p" . my:org-view-previous-heading)
		 ("o" . other-window-or-split)
		 ("G" . end-of-buffer)
		 ("0" . my:delete-window)
		 ("1" . my:delete-other-windows)
		 ("2" . my:split-window-below)
		 ("+" . text-scale-increase)
		 ("-" . text-scale-decrease)
		 ("/" . (lambda ()(interactive)(text-scale-set 0)))
		 ("_" . kill-other-buffers)
		 (":" . View-exit-and-edit)
		 ("i" . View-exit-and-edit)
		 ("]" . winner-undo)
		 ("[" . winner-redo)
		 ("." . hydra-view/body))
  :init
  ;; Specific extension / directory
  (defvar my:auto-view-regexp "\\.php\\|\\.pl\\|\\.el.gz?\\|\\.tar.gz?\\'")

  ;; Specific directory
  (defvar my:auto-view-dirs nil)
  (add-to-list 'my:auto-view-dirs "~/src/")
  (add-to-list 'my:auto-view-dirs "~/Dropbox/GH/")
  (add-to-list 'my:auto-view-dirs "/scp:xsrv:/home/minorugh/")

  (defun my:auto-view ()
	"Open a file with view mode."
	(when (file-exists-p buffer-file-name)
	  (when (and my:auto-view-regexp
				 (string-match my:auto-view-regexp buffer-file-name))
		(view-mode 1))
	  (dolist (dir my:auto-view-dirs)
		(when (eq 0 (string-match (expand-file-name dir) buffer-file-name))
		  (view-mode 1)))))

  (defun my:unlock-view-mode ()
	"Unlock view mode with git commit."
	(when (string-match "COMMIT_EDITMSG" buffer-file-name)
	  (view-mode 0))))
```
`view-mode` のときにモードラインの色を変えるのは [`viewer.el`]() を使うと設定が簡単です。

```code
;; Change-modeline-color
(leaf viewer
  :ensure t
  :hook (view-mode-hook . viewer-change-modeline-color-setup)
  :custom `((viewer-modeline-color-view . "#852941")
	        (viewer-modeline-color-unwritable . "#2F6828")))
```

`view-mode` からでも簡単な編集ができるように `vim like` なコマンドをいくつか作りました。

```code
(with-eval-after-load 'view
  ;; save-buffer no message
  (defun my:save-buffer ()
	"With clear Wrote message."
	(interactive)
	(save-buffer)
	(message nil))

  ;; Like as 'x' of vim
  (defun my:view-del-char ()
	"Delete charactor in view mode."
	(interactive)
	(view-mode 0)
	(delete-char 1)
	(my:save-buffer)
	(view-mode 1))

  ;; Like as 'dd' of vim
  (defun my:view-kill-region ()
	"If the region is active, to kill region.
If the region is inactive, to kill whole line."
	(interactive)
	(view-mode 0)
	(if (use-region-p)
		(kill-region (region-beginning) (region-end))
	  (kill-whole-line))
	(my:save-buffer)
	(view-mode 1))

  ;; Like as 'u' of vim
  (defun my:view-undo ()
	"Undo in view mode."
	(interactive)
	(view-mode 0)
	(undo)
	(my:save-buffer)
	(view-mode 1))

  ;; Like as 'y' of vim
  (defun my:view-yank ()
	"Yank in view mode."
	(interactive)
	(view-mode 0)
	(yank)
	(my:save-buffer)
	(view-mode 1))

  ;; Like as '%' of vim
  (defun my:jump-brace ()
	"Jump to the corresponding parenthesis."
	(interactive)
	(let ((c (following-char))
		  (p (preceding-char)))
	  (if (eq (char-syntax c) 40) (forward-list)
		(if (eq (char-syntax p) 41) (backward-list)
		  (backward-up-list)))))

  (defun my:org-view-next-heading ()
	"Org-view-next-heading."
	(interactive)
	(if (and (derived-mode-p 'org-mode)
			 (org-at-heading-p))
		(org-next-visible-heading 1)
	  (next-line)))

  (defun my:org-view-previous-heading ()
	"Org-view-previous-heading."
	(interactive)
	(if (and (derived-mode-p 'org-mode)
			 (org-at-heading-p))
		(org-previous-visible-heading 1)
	  (previous-line))))
```

### 5.4. web/htmlモード
HTML編集をするなら[web-mode](https://github.com/fxbois/web-mode) がお勧めなのですが、私の場合あまり使っていません。

出来上がったHTMLの内容を確認したり部分的に変更したり...という程度の使い方です。

```code
(leaf web-mode
  :ensure t
  :mode ("\\.js?\\'" "\\.html?\\'" "\\.php?\\'")
  :custom
  `((web-mode-markup-indent-offset . 2)
	(web-mode-css-indent-offset . 2)
	(web-mode-code-indent-offset . 2)))
```

### 5.5. [darkroom-mode] 執筆モード
[`darkroom.el`](https://github.com/joaotavora/darkroom)  は、画面の余計な項目を最小限にして、文章の執筆に集中できるようにするパッケージです。

[https://github.com/joaotavora/darkroom](https://github.com/joaotavora/darkroom)

[F12] キーで IN/OUT をトグルしています。
`darkroom-mode` から抜けるときは、`revert-buffer` で再読込してもとに戻します。

yes/no確認を聞かれるのが煩わしいので `my:revery-buffer-no-confirm` の関数を作りました。

```code
(leaf darkroom
  :ensure t
  :bind (("<f12>" . my:darkroom-in)
		 (:darkroom-mode-map
		  ("<f12>" . my:darkroom-out)))
  :config
  (defun my:darkroom-in ()
	"Enter to the `darkroom-mode'."
	(interactive)
	(view-mode 0)
	(diff-hl-mode 0)
	(display-line-numbers-mode 0)
	(darkroom-tentative-mode 1)
	(setq-local line-spacing 0.4))

  (defun my:darkroom-out ()
	"Returns from `darkroom-mode' to the previous state."
	(interactive)
	(my:linespacing)
	(darkroom-tentative-mode 0)
	(display-line-numbers-mode 1)
	(my:revert-buffer-no-confirm))

  (defun my:revert-buffer-no-confirm ()
	"Revert buffer without confirmation."
	(interactive)
	(revert-buffer t t)))
```

### 5.6. [yatex] YaTexで LaTex編集
[`yatex.el`](https://github.com/emacsmirror/yatex) は、Emacsの上で動作する LaTeX の入力支援環境です。

ごく一般的な設定例ですが、参考になるとしたら `dviprint-command-format` に `dvpd.sh` というスクリプトを設定して、`YateX.lpr`
コマンドでPDF作成 → プレビューまでの手順を一気に出来るように自動化している点でしょうか。

```code
(leaf yatex
  :ensure t
  :mode ("\\.tex\\'" "\\.sty\\'" "\\.cls\\'")
  :custom `((tex-command . "platex")
			(dviprint-command-format . "dvpd.sh %s")
			(YaTeX-kanji-code . nil)
			(YaTeX-latex-message-code . 'utf-8)
			(YaTeX-default-pop-window-height . 15))
  :config
  (leaf yatexprc
	:bind (("M-c" . YaTeX-typeset-buffer)
		   ("M-v" . YaTeX-lpr))))
```
`YaTeX-lpr` は、`dviprint-command-format` を呼び出すコマンドです。

dviファイルから dvipdfmx で PDF作成したあと、ビューアーを起動させて表示させるところまでをバッチファイルに書き、`chmod +x dvpd.sh ` として実行権限を付与してからPATHの通ったところに置きます。私は、`/usr/loca/bin` に置きました。

[dvpd.sh]
```sh
#!/bin/code
name=$1
dvipdfmx $1 && evince ${name%.*}.pdf
# Delete unnecessary files
rm *.au* *.dv* *.lo*
```
上記の例では、ビューアーに Linux の evince を設定していますが、Mac の場合は、下記のようになるかと思います。

```sh
dvipdfmx $1 && open -a Preview.app ${name%.*}.pdf
```

### 5.7. [yasunippet] Emacs用のテンプレートシステム
テンプレート挿入機能を提供してくれるやつです。
```code
(leaf yasnippet
  :ensure t
  :hook (after-init-hook . yas-global-mode)
  :config
  (leaf yasnippet-snippets :ensure t))
```

以下の設定を追加すると[`company-mode`](https://github.com/company-mode/company-mode) と連携してとても使いやすくなる。
```code
(defvar company-mode/enable-yas t
  "Enable yasnippet for all backends.")
(defun company-mode/backend-with-yas (backend)
  (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
	  backend
	(append (if (consp backend) backend (list backend))
    	    '(:with company-yasnippet))))
(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
(bind-key "C-<tab>" 'company-yasunippets)
```

### 5.8. [iedit] 選択領域を別の文字列に置き換える
[`idet.el`](https://github.com/victorhge/iedit) は、バッファー内の複数箇所を同時に編集するツールです。

同じような機能のものは、複数あるようですが、わたしはこれを愛用しています。
* [`multi-cursors.el`](https://github.com/magnars/multiple-cursors.el) 
* [`replace-from-region.el`](https://www.emacswiki.org/emacs/replace-from-region.el) 
* [`anzu.el`](https://github.com/emacsorphanage/anzu) 

MELPAからpackage-installするだけで使えます。

対象範囲を選択して `C-;` を押すとiedit-modeとなり、選択したキーワードが全てハイライト表示され、モードラインに押すとIedit:とキーワードの出現した回数が表示され、ミニバッファにもメッセージが表示されます。

ここで、ハイライトされた部分を編集すると、他のハイライトも同時に編集されるようになります。編集後、もう一度 `C-;` を押すと確定されiedet-modeを抜けます。

かなりの頻度で使うので、Emacsでは使うことのない `<insert>` にキーバインドしています。

```code
(leaf iedit
  :ensure t
  :bind ("<insert>" . iedit-mode))
```

### 5.9. [selected] リージョン選択時のアクションを制御
[`selected.el`](https://github.com/Kungsgeten/selected.el) は、選択領域に対するスピードコマンドです。

Emacsバッファーで領域を選択した後、バインドしたワンキーを入力するとコマンドが実行されます。
コマンドの数が増えてきたら、ヘルプ代わりに使える [`counsel-selected`](https://github.com/takaxp/counsel-selected) も便利そうです。
```code
(leaf selected
  :ensure t
  :hook (after-init-hook . selected-global-mode)
  :bind (:selected-keymap
		 (";" . comment-dwim)
		 ("c" . clipboard-kill-ring-save)
		 ("s" . swiper-thing-at-point)
		 ("t" . google-translate-auto)
		 ("T" . chromium-translate)
		 ("W" . my:weblio)
		 ("k" . my:koujien)
		 ("e" . my:eijiro)
		 ("g" . my:google)))
```

### 5.10. [selected] browse-urlで検索サイトで開く
検索結果を browse-url で表示させるユーザーコマンドは、検索 urlのフォーマットとさえわかれば、パッケージツールに頼らずともお好みのマイコマンドを作成できます。

```code
(defun my:koujien (str)
  (interactive (list (my:get-region nil)))
  (browse-url (format "https://sakura-paris.org/dict/広辞苑/prefix/%s"
                      (upcase (url-hexify-string str)))))

(defun my:weblio (str)
  (interactive (list (my:get-region nil)))
  (browse-url (format "https://www.weblio.jp/content/%s"
	                  (upcase (url-hexify-string str)))))

(defun my:eijiro (str)
  (interactive (list (my:get-region nil)))
  (browse-url (format "https://eow.alc.co.jp/%s/UTF-8/"
                      (upcase (url-hexify-string str)))))

(defun my:google (str)
	(interactive (list (my:get-region nil)))
	(browse-url (format "https://www.google.com/search?hl=ja&q=%s"
						(upcase (url-hexify-string str)))))

(defun my:get-region (r)
	"Get search word from region."
	(buffer-substring-no-properties (region-beginning) (region-end)))
```

### 5.11. [selected] IME のオン・オフを自動制御する
selectedコマンドを選択するときは、IMEをOffにしないといけないのですがこれを自動でさせます。

領域を選択し始める時に IMEをオフにして、コマンド発行後に IMEを元に戻すという例が、
[`@takaxp`](https://qiita.com/takaxp) さんの [`Qiitaの記事`](https://qiita.com/takaxp/items/00245794d46c3a5fcaa8) にあったので、私の環境（emacs-mozc ）にあうように設定したら、すんなり動いてくれました。感謝！

```code
(leaf *cus-selected
  :hook ((activate-mark-hook . my:activate-selected)
		 (activate-mark-hook . (lambda () (setq my:ime-flag current-input-method) (my:ime-off)))
		 (deactivate-mark-hook . (lambda () (unless (null my:ime-flag) (my:ime-on)))))
  :init
  ;; Control mozc when seleceted
  (defun my:activate-selected ()
	(selected-global-mode 1)
	(selected--on)
	(remove-hook 'activate-mark-hook #'my:activate-selected))
  (add-hook 'activate-mark-hook #'my:activate-selected)
  (defun my:ime-on ()
	(interactive)
	(when (null current-input-method) (toggle-input-method)))
  (defun my:ime-off ()
	(interactive)
	(inactivate-input-method))

  (defvar my:ime-flag nil)
  (add-hook
   'activate-mark-hook
   #'(lambda ()
	   (setq my:ime-flag current-input-method) (my:ime-off)))
  (add-hook
   'deactivate-mark-hook
   #'(lambda ()
	   (unless (null my:ime-flag) (my:ime-on)))))
```

### 5.12. [swiper-migemo] ローマ字入力で日本語を検索
[`avy-migemo-e.g.swiper.el`](https://github.com/momomo5717/avy-migemo) を使って出来ていたのですが、２年ほど前から更新が止まってしまっていて動きません。

つい最近、avy-migemo を使わない [`swiper-migemo`](https://github.com/tam17aki/swiper-migemo)を GitHubで見つけたので試した処、機嫌よく動いてくれています。
MELPAにはアップされていないみたいなので el-get で取得しています。

```code
(leaf swiper-migemo
  :el-get tam17aki/swiper-migemo
  :global-minor-mode t)
```

### 5.13. [smartparent] 対応する括弧の挿入をアシスト
[smartparens.el](https://github.com/Fuco1/smartparens) の設定がいまいちよくわからず、とりあえず次のように設定して今のところ機嫌よく働いている。 

```code
(leaf smartparens
  :ensure t
  :require smartparens-config
  :hook (prog-mode-hook . turn-on-smartparens-mode)
  :config
  (smartparens-global-mode t))
```

### 5.14. [key-chord.el] 同時押しでキーバインド
* 同時押しというキーバインドを提供してくれるやつ
* 同時押し時の許容時間、その前後で別のキーが押されていたら発動しない判断をする、みたいな設定を入れている。

```code
(leaf key-chord
  :ensure t
  :hook (after-init-hook . key-chord-mode)
  :chord (("df" . counsel-descbinds)
		  ("l;" . init-loader-show-log)
		  ("@@" . howm-list-all)
		  ("jk" . open-junk-file))
  :custom
  `((key-chord-two-keys-delay . 0.25)
	(key-chord-safety-interval-backward . 0.1)
	(key-chord-safety-interval-forward  . 0.15)))
```
キーの同時押し判定は 0.15 秒で、それらのキーが押される直前の 0.1 秒以内、または直後の 0.15 秒に押されていたら発動しない、という設定にしている。

改良版の作者の記事だと、直後判定は 0.25 秒で設定されていたが自分は `Hydra` の起動にも使っている上に、よく使うやつは覚えているので表示を待たずに次のキーを押すので 0.25 秒も待っていられないという事情があった。

### 5.15. [fontawesome] fontawesome utility
[`fontawesome.el`](https://github.com/emacsorphanage/fontawesome) は、Emacs での `fontawesome` の入力が簡単に出来るユーティリティです。`helm` や `ivy` とも勝手に連携してくれる。

```code
(leaf FontAwesome
 :ensure t
 :bind ("s-a" . councel-fontawesome))
```

## 6. 表示サポート
ここでは Emacs の UI を変更するようなものを載せている。

### 6.1. 対応するカッコをハイライトする
Built-in の `paren.el` が利用できる。

```code
(leaf paren
  :hook (after-init-hook . show-paren-mode)
  :custom
  `((show-paren-style . 'parenthesis)
	(show-paren-when-point-inside-paren . t)
	(show-paren-when-point-in-periphery . t)))
```

### 6.2. [whitespace]cleanup-for-spaces
`whitespace` の設定はシンプルに `show-trailing-whitespace` のみとし、不用意に入ってしまったスペースを削除するための関数を設定しました。

```code
(leaf whitespace
  :ensure t
  :bind ("C-c C-c" . my:cleanup-for-spaces)
  :hook (prog-mode-hook . my:enable-trailing-mode)
  :config
  (setq show-trailing-whitespace nil)
  :init
  (defun my:enable-trailing-mode ()
    "Show tail whitespace."
    (setq show-trailing-whitespace t))

  (defun my:cleanup-for-spaces ()
    "Remove contiguous line breaks at end of line + end of file."
    (interactive)
    (delete-trailing-whitespace)
    (save-excursion
      (save-restriction
		(widen)
		(goto-char (point-max))
		(delete-blank-lines)))))
```

### 6.3. [diff-hl] 編集差分をフレーム端で視覚化
編集差分の視覚化は、元々 `git-gutter` が提供している機能です。しかし有効にするとフレームの幅が若干広がってしまうなどの不便さがあったので `diff-hl` に乗り換えました。

```code
(leaf diff-hl
  :ensure t
  :hook ((after-init-hook . global-diff-hl-mode)
         (after-init-hook . diff-hl-margin-mode)))
```

### 6.4. [japanese-holidays] カレンダーをカラフルにする
ビルドインの `holidays` と `japanese-holidays.el`を使います。土日祝日に色を着けます。土曜日と日曜祝日で異なる配色にできます。

```code
(leaf calendar
  :leaf-defer t
  :bind (("<f7>" . calendar)
		 (:calendar-mode-map
		  ("<f7>" . calendar-exit)))
  :config
  (leaf japanese-holidays
	:ensure t
	:require t
	:hook ((calendar-today-visible-hook . japanese-holiday-mark-weekend)
		   (calendar-today-invisible-hook . japanese-holiday-mark-weekend)
		   (calendar-today-visible-hook . calendar-mark-today))
	:config
	(setq calendar-holidays
		  (append japanese-holidays holiday-local-holidays holiday-other-holidays))
	(setq calendar-mark-holidays-flag t)))
```

### 6.5. [which-key] キーバインドの選択肢をポップアップする
`guide-key.el` の後発、ディスパッチャが見やすく直感的でとても使いやすい。

```code
(leaf which-key
  :ensure t
  :hook (after-init-hook . which-key-mode)
  :custom (which-key-max-description-length . 40))
```

### 6.6. [all-the-icons.el] フォントでアイコン表示
`all-the-icons.el` を使うとバッファ内やモードライン、ミニバッファでアイコンを表示できるようになります。

[domtronn/all-the-icons.el: A utility package to collect various Icon Fonts and propertize them within Emacs.](https://github.com/domtronn/all-the-icons.el)

初めて使うときはパッケージを使えるようにした後、`M-x all-the-icons-install-fonts` すると自動的にフォントがインストールされます。以下の設定では自動化しています。

```code
(leaf all-the-icons
  :ensure t
  :after doom-modeline
  :custom (all-the-icons-scale-factor . 0.9)
  :config
  (unless (member "all-the-icons" (font-family-list))
	(all-the-icons-install-fonts t)))
```

### 6.7. [all-the-icons-dired]
`dired` でファイルのアイコンを表示します。Emacs27以降、MELPA版は白色にしか表示されないので [jtbm37/all-the-icons-dired](https://github.com/jtbm37/all-the-icons-dired) をel-getでインストールしています。

```code
(leaf all-the-icons-dired
  :el-get jtbm37/all-the-icons-dired
  :after doom-modeline
  :hook (dired-mode-hook . all-the-icons-dired-mode))
```

### 6.8. [all-the-icons-ivy-rich]

```code
(leaf all-the-icons-ivy-rich
  :ensure t
  :hook (after-init-hook . all-the-icons-ivy-rich-mode))
```

### 6.9. [all-the-icons-ibuffer]

```code
(leaf all-the-icons-ibuffer
  :ensure t
  :hook (ibuffer-mode-hook . all-the-icons-ibuffer-mode))
```

### 6.10. [ivy-rich]

```code
(leaf ivy-rich :ensure t
  :hook (after-init-hook . ivy-rich-mode))
```

### 6.11. [amx]

```code
 (leaf amx	:ensure t
	:custom	`((amx-save-file . ,"~/.emacs.d/tmp/amx-items")
			  (amx-history-length . 20)))
```

### 6.12. [imenu-list] サイドバー的にファイル内容の目次要素を表示
[@takaxpさんの改良版/imenu-list](https://github.com/takaxp/imenu-list) を使ってます。 

![Alt Text](https://live.staticflickr.com/65535/51419973025_01d97fe83b_b.jpg) 

```code
(leaf imenu-list
  :ensure t
  :bind ("<f2>" . imenu-list-smart-toggle)
  :custom
  `((imenu-list-size . 30)
	(imenu-list-position . 'left)
	(imenu-list-focus-after-activation . t)))
```

`counsel-css.el` を導入すると便利です。
```code
(leaf counsel-css
  :ensure t
  :hook (css-mode-hook . counsel-css-imenu-setup))
```

### 6.13. [prescient.el] リスト項目の並び替えとイニシャル入力機能（ivy and company）
コマンド履歴を保存、コマンドのイニシャル入力を可能にする。

```code
(leaf prescient
  :ensure t
  :hook (after-init-hook . prescient-persist-mode)
  :custom
  `((prescient-aggressive-file-save . t)
	(prescient-save-file . "~/.emacs.d/tmp/prescient-save"))
  :init
  (with-eval-after-load 'prescient
	(leaf ivy-prescient :ensure t :global-minor-mode t)
	(leaf company-prescient :ensure t :global-minor-mode t)))
```

### 6.14. [rainbow-mode]
[`rainbow-mode.el`](https://github.com/emacsmirror/rainbow-mode/blob/master/rainbow-mode.el) は red, greenなどの色名や #aabbcc といったカラーコードから実際の色を表示するマイナーモードです。
常時表示しているとうざいとケースのあるので、必要なときだけ使えるようにしています。

```code
(leaf rainbow-mode
  :ensure t
  :bind ("C-c r" . rainbow-mode))
```

### 6.15. [dimmer.el] 現在のバッファ以外の輝度を落とす
[takaxp.github.io](https://takaxp.github.io/init.html#org8ba0784e) の設定をそのままパクリました。
on/off できるのが快適です。

`global` 設定にすると多くのシーンでDisable対策の設定が必要になり面倒です。下記の通り発想転換すれば呪いから逃れることができます。

* 画面分割を発動するときに `dimmer-on`
* 画面分割を閉じるときに `dimmer-off`

```code
(leaf dimmer
  :ensure t
  :chord (".." . my:toggle-dimmer)
  :config
  (defvar my:dimmer-mode 1)
  (setq dimmer-buffer-exclusion-regexps '("^ \\*which-key\\|^ \\*LV\\|^ \\*.*posframe.*buffer.*\\*$"))
  (setq dimmer-fraction 0.6)

  (defun my:toggle-dimmer ()
	(interactive)
	(unless (one-window-p)
	  (if (setq my:dimmer-mode (not my:dimmer-mode))
		  (dimmer-on) (dimmer-off))))

  (defun dimmer-off ()
	(dimmer-process-all)
	(dimmer-mode -1))

  (defun dimmer-on ()
	(when my:dimmer-mode
	  (dimmer-mode 1)
	  (dimmer-process-all))))
```

### 6.16. [swiper.el] 文字列探索とプレビューを同時に行う
`swiper-ting-at-piont` は賢くて便利なのですが、`iserch` の感覚で使うときには迷惑なときもあります。

リージョン選択していないときは、`swiper` として機能するように関数を設定し `C-s` にバインドしています。

```code
(defun swiper-region ()
  "If region is selected, `swiper-thing-at-point'. 
If the region isn't selected, `swiper'."
  (interactive)
  (if (not (use-region-p))
      (swiper)
    (swiper-thing-at-point)))
```

## 7. Hydra / コマンドディスパッチャ
[hydra.el](https://github.com/abo-abo/hydra) を使うとよく使う機能をまとめてシンプルなキーバインドを割り当てることができます。

日本では、[smartrep.el](http://sheephead.homelinux.org/2011/12/19/6930/) が有名だったようですが、hydra.elも同様の機能を提供します。

### 7.1. [hydra-menu] 作業選択メニュー 
[`hydra-work-menu`](https://github.com/minorugh/dotfiles/blob/31fbe8f956d453db9804e60f1a244919c6876689/.emacs.d/inits/20_hydra-menu.el#L57) には、
ブログ記事のほかWEB日記や俳句関係のシリーズ記事の追加、編集など、毎日頻繁に開くワークスペースへのショートカットを設定しています。

![hydra-work-menu](https://live.staticflickr.com/65535/50175364331_9fcf3c6c86_b.jpg) 

[`hydra-quick-menu`](https://github.com/minorugh/dotfiles/blob/31fbe8f956d453db9804e60f1a244919c6876689/.emacs.d/inits/20_hydra-menu.el#L5) の方には、
編集作業で頻繁に使うツール群のほか、my:dired でプロジェクトのディレクトリを一発で開くためのショートカットなどを設定しています。

![hydra-quick-menu](https://live.staticflickr.com/65535/50174826063_b4fa442b1e_b.jpg) 


この２つの hydra は、いわば私の秘書のような役割で、どちらからでも相互にトグルで呼び出せるようにしています。

### 7.2. その他の Hydra 設定
hydra で工夫するといろんなコマンドのキーバインドを記憶する必要もなく GUI 感覚で操作できるので積極的に使っています。

[hydra-make](https://github.com/minorugh/dotfiles/blob/31fbe8f956d453db9804e60f1a244919c6876689/.emacs.d/inits/20_hydra-make.el#L5) 
: makeコマンドの選択メニュー

[hydra-package](https://github.com/minorugh/dotfiles/blob/31fbe8f956d453db9804e60f1a244919c6876689/.emacs.d/inits/20_hydra-misc.el#L6) 
: パッケジユーティリティーの選択メニュー

[hydra-browse](https://github.com/minorugh/dotfiles/blob/31fbe8f956d453db9804e60f1a244919c6876689/.emacs.d/inits/20_hydra-misc.el#L33) 
: お気に入りサイトの選択メニュー

[hydra-markdown](https://github.com/minorugh/dotfiles/blob/31fbe8f956d453db9804e60f1a244919c6876689/.emacs.d/inits/40_markdown.el#L18) 
: markdown-mode のコマンド選択メニュー

[hydra-view-mode](https://github.com/minorugh/dotfiles/blob/cc6011493073431405797954c05948ad2ca08289/.emacs.d/inits/40_view-mode.el#L160) 
: view-modeキーバインドのヘルプを兼ねています。

Qitta に詳しい記事を書いています。

* [Hydraで Emacsのキーバインド問題を解消](https://qiita.com/minoruGH/items/3776090fba46b1f9c228)


## 8. 履歴 / ファイル管理

### 8.1. [auto-save-buffer-enhanced] ファイルの自動保存

[auto-save-buffer-enhanced.el](https://github.com/kentaro/auto-save-buffers-enhanced) は、Emacs に本当の自動保存機能を提供します。

Tramp-mode と併用すると emacs が固まってしまうことがあるようなので、 `auto-save-buffers-enhanced-exclude-regexps` を設定して trampでリモート編集時には auto-save-buffers を停止するようにしています。

また、このパッケージには、scratchバッファーの内容も保存してくれるので併せ設定している。

```code
(leaf auto-save-buffers-enhanced
  :ensure t
  :config
  (setq auto-save-buffers-enhanced-exclude-regexps '("^/ssh:" "^/scp:" "/sudo:"))
  (setq auto-save-buffers-enhanced-quiet-save-p t)
  (setq auto-save-buffers-enhanced-save-scratch-buffer-to-file-p t)
  (setq auto-save-buffers-enhanced-file-related-with-scratch-buffer "~/.emacs.d/tmp/scratch")
  (auto-save-buffers-enhanced t)
  (defun read-scratch-data ()
	(let ((file "~/.emacs.d/tmp/scratch"))
	  (when (file-exists-p file)
		(set-buffer (get-buffer "*scratch*"))
		(erase-buffer)
		(insert-file-contents file))))
  (read-scratch-data))
```

### 8.2. 空になったファイルを自動的に削除

howm や org でメモをとるときに、ゴミファイルが残らないように時々メンテしています。ファイルを開いて中味を確認してから、一度閉じて dited で削除するというプロセスは手間がかかりすぎます。

下記の設定をしておくと、`C-x h` で全選択して delete したあと `kill-buffer` することで自動的にファイルが削除されるので便利です。

```code
(defun my:delete-file-if-no-contents ()
  "Automatic deletion for empty files (Valid in all modes)."
  (when (and (buffer-file-name (current-buffer))
			 (= (point-min) (point-max)))
    (delete-file
     (buffer-file-name (current-buffer)))))
(if (not (memq 'my:delete-file-if-no-contents after-save-hook))
    (setq after-save-hook
		  (cons 'my:delete-file-if-no-contents after-save-hook)))

```

### 8.3. [undo-fu] シンプルな undo/redo を提供
[undo-fu](https://github.com/emacsmirror/undo-fu)  はシンプルな undo/redo 機能を提供してくれるやつです。

昔はもっと色々できる [undo-tree](https://github.com/apchamberlain/undo-tree.el)  を使っていたけどそっちにバグがあるっぽいので乗り換えました。

```code
(leaf undo-fu
  :ensure t
  :bind (("C-_" . undo-fu-only-undo)
		 ("C-/" . undo-fu-only-redo)))
```


## 9. 開発サポート

### 9.1. 便利キーバインド
便利機能をワンキーアクションで使えるように設定しています。

| キー | コマンド                  | 説明 |
|--------------|---------------------------|------|
| F1 | emacs help |ivyで提供される便利機能 |
| F2 | imenu-list-smart-toggle | imenuのサイドバー版 |
| F3 | filer-current-dir-open | nautilusを開く |
| F4 | term-current-dir-open | gonome-terminalを開く |
| F5 | quikuran | お手軽ビルド |
| F6 | counsel-linux-app | Linuxアプリランチャー |
| F7 | calendar-toggle | カレンダーのトグル表示 |
| F8 | toggle-menu-bar-mode-from-frame | menu-barのトグル表示 |
| F9 | display-line-numbers-mode | 行番号のトグル表示 |
| F10 | neotree-toggle | Neotreeのトグル表示 |
| F11 | toggle-frame-fullscreen | Emacsの標準機能 |
| F12 | darkroom-mode | darkroom-modeのトグル操作 |
| home | open-dashboard | dashboardの再表示 |
| S-RET | toggle-scratch | `scratch`のトグル表示 |
| insert | iedit-menu | 文字列の置換え |
| muhenkan | minibuffer-keyboard-quit | minibufferを閉じる |

### 9.2. Gist インターフェイス
[`gist.el`](https://github.com/defunkt/gist.el) は、なにげに使いづらく、ローカルで管理する必要も感じないので簡単な関数を作りました。

Emacsから使うためには、`gist` をinstallしておく必要があります。

```sh 
sudo apt install gist
```
`gist -o` とするとポスト後の結果の URLをブラウザで開いてくれるので便利です。

```code
(leaf *gist-configurations
  :bind ("s-g" . gist-region-or-buffer)
  :init
  (defun gist-description ()
	"Add gist description."
	(code-quote-argument (read-from-minibuffer "Add gist description: ")))

  (defun gist-filename ()
	"The character string entered in minibuffer is used as file-name.
If enter is pressed without file-name, that's will be buffer-file-neme."
	(interactive)
	(let ((file (file-name-nondirectory (buffer-file-name (current-buffer)))))
	  (read-from-minibuffer (format "File name (%s): " file) file)))

  (defun gist-region-or-buffer ()
	"If region is selected, post from the region.
If region isn't selected, post from the buffer."
	(interactive)
	(let ((file (buffer-file-name)))
	  (if (not (use-region-p))
		  (compile (concat "gist -od " (gist-description) " " file))
		(compile (concat "gist -oPd " (gist-description) " -f " (gist-filename)))))
	(delete-other-windows))
```
`dired` からも使えるように設定しておくと便利です。

```code
  (defun dired-do-gist ()
	"Dired-get-filename do gist and open in browser."
	(interactive)
	(let ((file (dired-get-filename nil t)))
	  (compile (concat "gist -od " (gist-description) " " file)))
	(delete-other-windows))
```
### 9.3. [company.el] 自動補完機能
[yasinippets] との連携機能が便利です。

```code
(leaf company
  :ensure t
  :hook (after-init-hook . global-company-mode)
  :bind (("C-<return>" . company-complete)
		 ("C-<tab>" . company-yasnippet)
		 (:company-active-map
		  ("<tab>" . company-complete-common-or-cycle)
		  ("<backtab>" . company-select-previous)
		  ("<muhenkan>" . company-abort)))
  :custom
  `((company-transformers . '(company-sort-by-backend-importance))
	(company-idle-delay . 0)
	(company-require-match . 'never)
	(company-minimum-prefix-length . 2)
	(company-selection-wrap-around . t)
	(completion-ignore-case . t)
	(company-dabbrev-downcase . nil))
  :config
  (defvar company-mode/enable-yas t
	"Enable yasnippet for all backends.")
  (defun company-mode/backend-with-yas (backend)
	(if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
		backend
	  (append (if (consp backend) backend (list backend))
			  '(:with company-yasnippet))))
  (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends)))
```

### 9.4. [flymake] 構文エラー表示
Emacs26以降は、標準添付の `flymake` が使いやすくなったので、`flycheck` から移行しました。

```code
(leaf flymake
  :hook (prog-mode-hook . flymake-mode)
  :config
  (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)
  (leaf flymake-posframe
	:el-get Ladicle/flymake-posframe
	:hook (flymake-mode-hook . flymake-posframe-mode)
	:custom (flymake-posframe-error-prefix . " ")))
```

### 9.5. [quickrun.el] お手軽ビルド
カレントバッファで編集中のソースコードをビルド・実行して別バッファに結果を得ます。

```code
(leaf quickrun
  :ensure t
  :bind ("<f5>" . quickrun))
```

### 9.6. [magit.el] Gitクライアント
`magit status` は、デフォルトでは `other-window` に表示されますが、フルフレームで表示されるようにしました。

```code
(leaf magit
  :ensure t
  :bind (("M-g s" . magit-status)
		 ("M-g b" . magit-blame)
		 ("M-g t" . git-timemachine-toggle))
  :hook (magit-post-refresh-hook . diff-hl-magit-post-refresh)
  :custom (transient-history-file . "~/.emacs.d/tmp/transient-history")
  :init
  (leaf diff-hl	:ensure t
	:hook ((after-init-hook . global-diff-hl-mode)
		   (after-init-hook . diff-hl-margin-mode)))

  (leaf git-timemachine	:ensure t)

  (leaf browse-at-remote :ensure t
	:custom (browse-at-remote-prefer-symbolic . nil)))
(setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
```

### 9.7. [counsel-tramp.el] 

```code
(leaf counsel-tramp
  :ensure t
  :custom
  `((tramp-persistency-file-name . ,"~/.emacs.d/tmp/tramp")
	(tramp-default-method . "scp")
	(counsel-tramp-custom-connections
	 . '(/scp:xsrv:/home/minorugh/gospel-haiku.com/public_html/)))
  :config
  (defun my:tramp-quit ()
	"Quit tramp, if tramp connencted."
	(interactive)
	(when (get-buffer "*tramp/scp xsrv*")
	  (tramp-cleanup-all-connections)
	  (counsel-tramp-quit)
	  (message "Tramp Quit!"))))
```

### 9.7. [eagy-hugo.el] マルチブログ管理
* [easy-hugo.el](https://github.com/masasam/emacs-easy-hugo) は、Hugoで作成されたブログを書くための Emacs メジャー モードです。
* [https://github.com/minorugh/emacs.d/blob/main/inits/60_easy-hugo.el](https://github.com/minorugh/emacs.d/blob/main/inits/60_easy-hugo.el)

<p><img src="static/screencast.gif" alt="screencast" /></p> 

## 10. メモ環境
* TPOで使い分けるメモツール

### 10.1. Howm Mode
Howm-menuは使わないので `howm-list-all` を初期画面として使っています。

この画面からでも [新規(c)] [検索(s)] ほか一連のhowmコマンドは全て使えます。

```code
(leaf howm
  :ensure t
  :hook ((emacs-startup-hook . howm-mode)
         ())
  :chord ("@@" . howm-list-all)
  :init
  (setq howm-view-title-header "#")
  (defun my:howm-create-file ()
    "Make howm create file with 'org-capture'."
    (interactive)
    (format-time-string "~/Dropbox/howm/%Y/%m/%Y%m%d%H%M.md" (current-time)))
  :config
  (bind-key [backtab] 'howm-view-summary-previous-section howm-view-summary-mode-map)
  (setq howm-directory "~/Dropbox/howm")
  (setq howm-view-split-horizontally t)
  (setq howm-view-summary-persistent nil)
  (setq howm-normalizer 'howm-sort-items-by-reverse-date)
  (setq howm-user-font-lock-keywords
		'(("memo:" . (0 'gnus-group-mail-3))
		  ("note:" . (0 'epa-mark)))))
```

### 10.2. Org Mode
dashboard画面に簡単なタスクを表示させるために `org-agenda` を使っています。

ついでなので `org-capture` からHowm-createを発動できるように`org-capture-template` を作りました。
ただ、`org-capture` からだと画面が半分になるのがいやなので、最大化で開くようにしています。

```code
(leaf org
  :hook (emacs-startup-hook . (lambda () (require 'org-protocol)))
  :chord (",," . org-capture)
  :bind (("C-c a" . org-agenda)
		 ("C-c c" . org-capture)
		 ("C-c k" . org-capture-kill)
		 ("C-c o" . org-open-at-point)
		 ("C-c i" . org-edit-src-exit)
		 (:org-mode-map
		  ("C-c i" . org-edit-special)))
  :custom `((org-log-done . 'org)
			(timep-use-speed-commands . t)
			(org-src-fontify-natively . t)
			(org-startup-indented . t)
			(org-hide-leading-stars . t)
			(org-startup-folded . 'content)
			(org-indent-mode-turns-on-hiding-stars . nil)
			(org-indent-indentation-per-level . 4)
			(org-startup-folded . 'content)
			(org-agenda-files . '("~/Dropbox/org/task.org"))
			(org-agenda-span . 30))
  :config
  (defun my:howm-create-file ()
    "Make howm create file with 'org-capture'."
    (interactive)
    (format-time-string "~/Dropbox/howm/%Y/%m/%Y%m%d%H%M.md" (current-time)))
  ;; Caputure Settings
  (setq org-capture-templates
		'(("m" " Memo with howm" plain (file my:howm-create-file)
		   "# memo: %?\n%U %i")
		  ("n" " Note with howm" plain (file my:howm-create-file)
		   "# note: %?\n%U %i")
		  ("t" " Task" entry (file+headline "~/Dropbox/org/task.org" "TASK")
		   "** TODO %?\n SCHEDULED: %^t \n" :empty-lines 1 :jump-to-captured 1)
		  ("e" " Experiment Perl" entry (file+headline "~/Dropbox/org/experiment.org" "Experiment")
		   "* %? %i\n#+BEGIN_SRC perl\n\n#+END_SRC\n\n%U")
		  ("p" " Code capture" entry (file+headline "~/Dropbox/org/capture.org" "Code")
		   "* %^{Title} \nSOURCE: %:link\nCAPTURED: %U\n\n#+BEGIN_SRC\n%i\n#+END_SRC\n" :prepend t)
		  ("L" " Link capture" entry (file+headline "~/Dropbox/org/capture.org" "Link")
		   "* [[%:link][%:description]] \nCAPTURED: %U\nREMARKS: %?" :prepend t)))
  (setq org-refile-targets
		'(("~/Dropbox/org/archives.org" :level . 1)
		  ("~/Dropbox/org/remember.org" :level . 1)
		  ("~/Dropbox/org/task.org" :level . 1)))
  :init
  ;; Maximize the org-capture buffer
  (defvar my:org-capture-before-config nil
    "Window configuration before 'org-capture'.")
  (defadvice org-capture (before save-config activate)
    "Save the window configuration before 'org-capture'."
    (setq my:org-capture-before-config (current-window-configuration)))
  (add-hook 'org-capture-mode-hook 'delete-other-windows))
```

### 10.3. Open-junk-file
junkファイルの保存も howmフォルダーに置くことで、howmの検索機能が利用できて便利です。

```code
(leaf open-junk-file :ensure t
  :config
  (setq open-junk-file-format "~/Dropbox/howm/junk/%Y%m%d.")
  (setq open-junk-file-find-file-function 'find-file))
```

下記のTipsを参考にして、直近の junkファイルを即開けるように `open-last-junk-file` を定義しました。

* [`Emacs で作成した使い捨てファイルを簡単に開く`](htotps://qiita.com/zonkyy/items/eba6bc64f66d278f0032) 

```code
(leaf em-glob
 :require t
 :config
 (defvar junk-file-dir "~/Dropbox/howm/junk/")
 (defun open-last-junk-file ()
   "Open last created junk-file."
   (interactive)
   (find-file
    (car
	    (last (ecode-extended-glob
	   	   (concat
   			(file-name-as-directory junk-file-dir)
			"*.*.*")))))))
```

### 10.4. Scratchを付箋として使う
作業中の短期的なメモを気軽に使うために `*scratch*`バッファーを付箋メモに使えるように設定してみた。

Emacsを再起動しても`*scratch*` バッファーの内容が消えないように [`auto-save-buffers-enhanced`](http://emacs.rubikitch.com/auto-save-buffers-enhanced/) の `*scratch*` バッファー自動保存機能を併用しています。専用のパッケージもあるようです。

* [persistent-scratch.el:scratch バッファを永続化・自動保存・復元する](http://emacs.rubikitch.com/persistent-scratch/) 

```code
(leaf auto-save-buffers-enhanced
  :ensure t
  :custom
  `((auto-save-buffers-enhanced-exclude-regexps . '("^/ssh:" "^/scp:" "/sudo:"))
	(auto-save-buffers-enhanced-quiet-save-p . t)
	(auto-save-buffers-enhanced-save-scratch-buffer-to-file-p . t)
	(auto-save-buffers-enhanced-file-related-with-scratch-buffer . "~/.emacs.d/tmp/scratch")
	;; Disable to prevent freeze in tramp-mode
	(auto-save-buffers-enhanced-include-only-checkout-path . nil))
  :config
  (auto-save-buffers-enhanced t)
  (defun read-scratch-data ()
	(let ((file "~/.emacs.d/tmp/scratch"))
	  (when (file-exists-p file)
		(set-buffer (get-buffer "*scratch*"))
		(erase-buffer)
		(insert-file-contents file))))
  (read-scratch-data))
```

作業中のバッファーから`*scratch*` バッファーを呼びだすために `toggle-scratch` を定義して愛用しています。
編集中のバッファーとscratchバッファーとをToggle表示します。

```code
(defun toggle-scratch ()
 "Toggle current buffer and *scratch* buffer."
 (interactive)
 (if (not (string= "*scratch*" (buffer-name)))
         (progn
		 (setq toggle-scratch-prev-buffer (buffer-name))
		 (switch-to-buffer "*scratch*"))
	 (switch-to-buffer toggle-scratch-prev-buffer)))
```

## 11. フレーム / ウインドウ制御

### 11.1. 起動時の設定
`*scratch*` バッファーを表示させるのが標準かと思いますが、私は、`dashboard` にしています。

[https://github.com/minorugh/emacs.d/blob/main/inits/01_dashboard.el](https://github.com/minorugh/emacs.d/blob/main/inits/01_dashboard.el) 

![dashboard](https://camo.githubusercontent.com/de931cfbad673c47366b2a3cd8d0aa7eede1ae13899512c0d51ba731866d5c40/68747470733a2f2f6c6976652e737461746963666c69636b722e636f6d2f36353533352f35313633313934363035335f623964383438613335375f622e6a7067) 

### 11.2. 複数フレーム対応

#### 11.2.1. Dimmer-Mode との連携
* 同じバッファーを分割したときは、`follow-mode` にする。
* 画面分割したときは、`dimmer-mode-on` にする。
* 画面分割を閉じたときは、`dimmer-mode-off` にする。

```pre
(leaf *sprit-window-configurations
  :bind (("C-q" . other-window-or-split)
		 ("C-x 2" . my:split-window-below)
		 ("C-x 1" . my:delete-other-windows)
		 ("C-x 0" . my:delete-window)
		 ("<C-return>" . window-swap-states))
  :init
  (defun other-window-or-split ()
	"With turn on dimmer."
	(interactive)
	(when (one-window-p)
	  (split-window-horizontally)
	  (follow-mode 1)
	  (dimmer-mode 1))
	(other-window 1))

  (defun my:split-window-below ()
	"With turn on dimmer."
	(interactive)
	(split-window-below)
	(follow-mode 1)
	(dimmer-mode 1))

  (defun my:delete-window ()
	"With turn off dimmer."
	(interactive)
	(delete-window)
	(follow-mode -1)
	(dimmer-mode -1))

  (defun my:delete-other-windows ()
	"With turn off dimmer."
	(interactive)
	(delete-other-windows)
	(follow-mode -1)
	(dimmer-mode -1))

  (defun kill-other-buffers ()
	"Kill all other buffers."
	(interactive)
	(mapc 'kill-buffer (delq (current-buffer) (buffer-list)))
	(message "killl-other-buffers!"))
```
#### 11.2.2. Scrool-other-Window
`deactive` なwindowをスクロールさせるための設定。

一画面のとき `<next>` / `<prior>` は、PgUp / PgDn として使うが、画面分割のときだけ `other-Window` に対応させている。
標準機能の `C-v: scroll-uo-command` / `M-v: scroll-down-command` を使い分ければ快適に二画面同時閲覧が可能となる。

```code
(leaf *my:scroll-other-window
  :bind (("<next>" . my:scroll-other-window)
		 ("<prior>" . my:scroll-other-window-down))
  :init
  (defun my:scroll-other-window ()
	"If there are two windows, `scroll-other-window'."
	(interactive)
	(when (one-window-p)
	  (scroll-up))
	(scroll-other-window))

  (defun my:scroll-other-window-down ()
	"If there are two windows, `scroll-other-window-down'."
	(interactive)
	(when (one-window-p)
	  (scroll-down))
	(scroll-other-window-down)))
```

### 11.3. [Winner.el] ウインドウ構成の履歴を辿る
* ビルトインの `winner.el` を使います．

ウィンドウ分割状況と各ウィンドウで表示していたバッファの履歴を辿ることができます。
`winner-undo` で直前の状態に戻せます。例えば、誤って `C-x 0` で分割ウィンドウを閉じた時でも即座に元の状態に戻すことが可能です。

### 11.4. [doom-modeline] モードラインをリッチにする

```code
(leaf doom-modeline
  :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :custom
  (doom-modeline-icon . t)
  (doom-modeline-major-mode-icon . nil)
  (doom-modeline-minor-modes . nil)
  :config
  (line-number-mode 0)
  (column-number-mode 0)
  (doom-modeline-def-modeline 'main
    '(bar window-number matches buffer-info remote-host buffer-position parrot selection-info)
    '(misc-info persp-name lsp github debug minor-modes input-method major-mode process vcs checker))
  :init
  (leaf nyan-mode
	:ensure t
	:config
	(nyan-mode 1)
	(nyan-start-animation)))
```

### 11.5. [popwin.el] ポップアップウィンドウの制御 
`anything` 時代はお世話になりましたが、最近はあまりつかってません。

```code
(leaf popwin
  :ensure t
  :hook (after-init-hook . popwin-mode))
```
※ `ecode` は使ってました。

### 11.6 [tempbuf.el]不要なバッファを自動削除する
* `tempbuf.el` は不要になったと思われるバッファを自動的に kill してくれるパッケージ。

使っていた時間が長い程、裏に回った時には長い時間保持してくれる。
つまり、一瞬開いただけのファイルは明示的に kill しなくても勝手にやってくれるのでファイルを開いてそのまま放置みたいなことをしがちなズボラな人間には便利なやつ。

* `my:tembuf-ignore-files`: 勝手に kill させないファイルの指定
* `find-file-hook`: `find-file` や `dired` で開いたファイルが対象
* `dired buffer` /`magit-buffer`: 強制的に削除

```code
(leaf tempbuf
  :el-get minorugh/tempbuf
  :hook ((find-file-hook . my:find-file-tempbuf-hook)
		 (dired-mode-hook . turn-on-tempbuf-mode)
		 (magit-mode-hook . turn-on-tempbuf-mode) )
  :init
  (setq my:tempbuf-ignore-files
		'("~/Dropbox/org/task.org"
          "~/Dropbox/org/capture.org"))

  (defun my:find-file-tempbuf-hook ()
	(let ((ignore-file-names (mapcar 'expand-file-name my:tempbuf-ignore-files)))
      (unless (member (buffer-file-name) ignore-file-names)
		(turn-on-tempbuf-mode)))))
```

## 12. フォント / 配色関連

### 12.1 カーソル行に色をつける
* ビルトインの `hl-line` を使います.

* http://murakan.cocolog-nifty.com/blog/2009/01/emacs-tips-1d45.html 
* https://www.emacswiki.org/emacs/highlight-current-line.el

機能別に`hl-line` のon/off や色を変えたりという設定もできますが、私の場合は、シンプルに `global` 設定して色は `theme` に依存というスタイルです。

```code
(global-hl-line-mode 1)
```

### 12.2 カーソルの点滅を制御
以下の例では、入力が止まってから 10 秒後に 0.3 秒間隔で点滅します。次に入力が始まるまで点滅が続きます．

```code
(setq blink-cursor-blinks 0)
(setq blink-cursor-interval 0.3)
(setq blink-cursor-delay 10)
(add-hook 'emacs-startup-hook . blink-cursor-mode)
```
### 12.3 フォント設定
* GUI / CUI 共通で `Cica` を使っています。

Cicaフォントは、Hack、DejaVu Sans Mono、Rounded Mgen+、Noto Emoji等のフォントを組み合わせて調整をした、日本語の等幅フォントです。

* [プログラミング用日本語等幅フォント Cica](https://github.com/miiton/Cica)

#### 12.3.1 Cicaフォントのインストール
* Linux 環境でのインストールの方法です。

```warning
[オフィシャルページ](https://github.com/miiton/Cica/releases/tag/v5.0.3)にある最新の `Cica v5.03` は、
`page-break-lines` で表示が乱れます。
```

1. [Cica-v5.0.1のダウンロードページ](https://github.com/SSW-SCIENTIFIC/Cica/releases)から、
([Cica-v5.0.1.zip](https://github.com/SSW-SCIENTIFIC/Cica/releases/download/v5.0.1-no-glyph-mod/Cica-v5.0.1.zip)) をダウンロードします。
2. 上記サイトの存続は怪しいので自分のサイトにも置いておきます。 [`Cica-v5.0.1.zip` ](https://minorugh.xsrv.jp/Cica/Cica-v5.0.1.zip)
3. zipファイルを展開します。

```codesesion
$ unzip Cica-v5.0.1.zip
```
4. LICENSE.txtを確認し、ファイルを `/usr/local/share/fonts/` または `~/.fonts/` にコピーします。

```codesession
$ sudo cp Cica-{Bold,BoldItalic,Regular,RegularItalic}.ttf ~/.fonts/
$ sudo fc-cache -vf
$ fc-list | grep Cica
/home/minoru/.fonts/Cica-v5.0.1/Cica-Regular.ttf: Cica:style=Regular
/home/minoru/.fonts/Cica-v5.0.1/noemoji/Cica-Regular.ttf: Cica:style=Regular
/home/minoru/.fonts/Cica-v5.0.1/noemoji/Cica-RegularItalic.ttf: Cica:style=Italic
/home/minoru/.fonts/Cica-v5.0.1/noemoji/Cica-Bold.ttf: Cica:style=Bold
/home/minoru/.fonts/Cica-v5.0.1/Cica-BoldItalic.ttf: Cica:style=Bold Italic
/home/minoru/.fonts/Cica-v5.0.1/Cica-Bold.ttf: Cica:style=Bold
/home/minoru/.fonts/Cica-v5.0.1/noemoji/Cica-BoldItalic.ttf: Cica:style=Bold Italic
/home/minoru/.fonts/Cica-v5.0.1/Cica-RegularItalic.ttf: Cica:style=Italic
```

#### 12.3.2 Cicaの設定
* メイン機（Thinkpad E590）とサブ機（Thinkpad X250）とでそれぞれに適した値を決めています。

```code
(add-to-list 'default-frame-alist '(font . "Cica-18"))
;; for sub-machine
(when (string-match "x250" (code-command-to-string "uname -n"))
  (add-to-list 'default-frame-alist '(font . "Cica-15")))
```

### 12.4 行間を制御する
`line-spacing` 行間を制御する変数です。バッファローカルな変数なので、ミニバッファも含めて、各バッファの行間を個別に制御できます。

[@takaxpさんのブログ記事](https://pxaka.tokyo/blog/2019/emacs-buffer-list-update-hook/) のによると、`global` で `0.3` 以下に設定すると 
`nil` に戻せないという不具合があるとのことなので、Tipsをパクって以下のように設定をしました。

```code
(defun my:linespacing ()
  (unless (minibufferp)
    (setq-local line-spacing 0.2)))
(add-hook 'buffer-list-update-hook #'my:linespacing)
```
`my:linespacing` はシンプルに、 `global` ではなく `local` 変数の `line-spacing` を書き換えます。
`(minibufferp)` で括っているのは、ミニバッファの行間を `my:linespacing` に左右されずに制御するためです。

`darkroom-mode` では、

```code
(setq-local line-spacing 0.4)
```
と行間を大きくするように設定していますが、`dark-room` からでるときに `my:linespacing` に戻しています。

### 12.5 起動時の背景をテーマに合わせる
私はダークテーマを使っているのですがEmacs初期化ファイル読み込み中は一瞬白背景になるのが嫌なので、`eary-init` にテーマと同じ黒背景を設定しています。

```code
(custom-set-faces '(default ((t (:background "#282a36")))))
```

### 12.6 [ivy.el] 選択行をアイコンで強調

```code
  (defun my:ivy-format-function-arrow (cands)
	"Transform into a string for minibuffer with CANDS."
	(ivy--format-function-generic
	 (lambda (str)
	   (concat (if (display-graphic-p)
				   (all-the-icons-octicon "chevron-right" :height 0.8 :v-adjust -0.05)
				 ">")
			   (propertize " " 'display `(space :align-to 2))
			   (ivy--add-face str 'ivy-current-match)))
	 (lambda (str)
	   (concat (propertize " " 'display `(space :align-to 2)) str))
	 cands
	 "\n"))
(setq ivy-format-functions-alist '((t . my:ivy-format-function-arrow)))
```

### 12.6 [volatile-highlights] コピペした領域を強調
コピペ直後の数秒に限定してコピペした領域をフラッシングさせます。

```code
(leaf volatile-highlights
  :ensure t
  :hook (after-init-hook . volatile-highlights-mode)
  :config
  (when (fboundp 'pulse-momentary-highlight-region)
	(defun my:vhl-pulse (beg end &optional _buf face)
	  "Pulse the changes."
	  (pulse-momentary-highlight-region beg end face))
	(advice-add #'vhl/.make-hl :override #'my:vhl-pulse)))
```

### 12.7 [rainbow-mode.el] 配色のリアルタイム確認
`rainbow-mode.el` は `red`, `green` などの色名や `#aabbcc` といったカラーコードから実際の色を表示するマイナーモードです。
常時表示しているとうざいときもあるので、`global` 設定しないで必要なときだけ使えるようにしています。

```code
(leaf rainbow-mode
  :ensure t
  :bind ("C-c r" . rainbow-mode))
```

### 12.8 custom-set-face
色設定が、あちこちに散らばっているとわかりにくので、`custom-set-face` で変更したものは、一箇所にまとめて設定するようにしています。

```code
(custom-set-faces
 '(lsp-face-highlight-read ((t (:background "gray21" :underline t))))
 '(lsp-face-highlight-write ((t (:background "gray21" :underline t))))
 '(markdown-code-face ((t (:inherit nil))))
 '(markdown-pre-face ((t (:inherit font-lock-constant-face))))
 '(markup-meta-face ((t (:stipple nil :foreground "gray30" :inverse-video nil :box nil
	                     :strike-through nil :overline nil :underline nil :slant normal
						 :weight normal :height 135 :width normal :foundry "unknown" :family "Monospace"))))
 '(symbol-overlay-default-face ((t (:background "gray21" :underline t))))
 '(mozc-cand-posframe-normal-face ((t (:background "#282D43" :foreground "#C7C9D1"))))
 '(mozc-cand-posframe-focused-face ((t (:background "#393F60" :foreground "#C7C9D1"))))
 '(mozc-cand-posframe-footer-face ((t (:background "#282D43" :foreground "#454D73")))))
(put 'dired-find-alternate-file 'disabled nil)
```

## 13. ユーティリティー関数

### 13.1. Scratch バッファーを消さない
難しく関数を設定せずとも内蔵コマンドで簡単に実現できます。

```code
;; Set buffer that can not be killed
(with-current-buffer "*scratch*"
  (emacs-lock-mode 'kill))
(with-current-buffer "*Messages*"
  (emacs-lock-mode 'kill))
```

### 13.2. Terminal を Emacsから呼び出す
Emacsで開いている`buffer` の`current-dir` で `gonome-terminal` を起動させるのでとても便利です。
こちらを使うようになってからは`ecode` を使わななりました。

```code
(defun term-current-dir-open ()
  "Open terminal application in current dir."
  (interactive)
  (let ((dir (directory-file-name default-directory)))
    (compile (concat "gnome-terminal --working-directory " dir))))
(bind-key "<f4>" 'term-current-dir-open)
```

### 13.3. Thunar を Emacsから呼び出す
Emacsで開いている`buffer` の`current-dir` で `Debian` の `Thuner` を開くというものです。
使う機会は少ないと思いますが...

```code
(defun filer-current-dir-open ()
  "Open filer in current dir."
  (interactive)
  (compile (concat "Thunar " default-directory)))
(bind-key "<f3>" 'filer-current-dir-open)
```

### 13.4. PS-Printer へのファイルの出力
基本的には Postscript ファイルを打ち出すことのできるPostscript プリンターが必要です。

```code
(defalias 'ps-mule-header-string-charsets 'ignore)
(setq ps-multibyte-buffer 'non-latin-printer
	  ps-paper-type 'a4
	  ps-font-size 9
	  ;; ps-font-family 'Helvetica
	  ps-font-family 'Courier
	  ps-line-number-font 'Courier
	  ps-printer-name nil
	  ps-print-header nil
	  ps-show-n-of-n t
	  ps-line-number t
	  ps-print-footer nil)
```

## 14. おわりに

以上が私の init.el とその説明です。

私の Emacsは、Webページのメンテナンスがメインで、プログラムミング・エディタというよりは、「賢くて多機能なワープロ」という存在です。ありえない…ような邪道キーバインドや未熟な点も多々ありますが、諸先輩に学びながら育てていきたいと願っています。

<div style="flort:left">
&ensp;<a href="https://twitter.com/share" class="twitter-share-button" data-url="{{ .Permalink }}" data-via="minorugh" data-text="{{ .Params.Title }}" data-lang="jp" data-count="horizontal">Tweet</a><script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
</div>
<blockquote class="twitter-tweet" lang="ja"><p lang="ja" dir="ltr"> <a href="https://twitter.com/minorugh/status/839117944260997120"></a></blockquote>

