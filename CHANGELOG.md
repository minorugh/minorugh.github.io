## 2026-03-29

# CHANGELOG-20260329.md

## 2026-03-28

### 解決した問題
- `20-check.el` の `void-variable textlint` エラー修正
  → `(leaf textlint ...)` を `with-eval-after-load` に書き換え

### git-peek.el 開発
- `my-git-show-file.el` をベースに開発開始
- リアルタイムプレビュー実装（`advice-add` 方式）
- `display-buffer-in-side-window` で上部固定表示
- `git-peek-preview-height` 変数で高さ調整可能に
- GitHub リポジトリ公開: https://github.com/minorugh/git-peek
- Gitea への追加は後日

### ~/.emacs.d/elisp/Makefile 改良
- `toggle-elc` を `find` 再帰検索に変更
- コンパイル後に `make compile` 自動実行
- `compile` ターゲットを `update-directory-autoloads` に変更
- サブディレクトリの autoload 登録に成功

### 次回課題
- 関数名を `git-peek` に統一、著作権ヘッダー追加
- `git-peek-deleted`（削除済みファイル対象）実装
- フルパス対応、diff 表示、コンテキスト判定
- Qiita 記事最終仕上げ
- `~/Dropbox/makefile` に git-peek リポジトリ追加
- シンボリックリンク設定

---

## 2026-03-28

# CHANGELOG-20260328

## my-git-show-file.el 開発ログ

### 概要
git 管理下の過去ファイルを ivy で検索・プレビュー・保存するツールを改良。

### 改良内容

#### 1. リアルタイムプレビュー実装
- `ivy-next-line` / `ivy-previous-line` に `advice-add` でフック
- カーソル移動のたびに `git show` でファイル内容を取得して `*git-preview*` バッファを更新
- `:update-fn` / `ivy-update-fns-alist` は今回のケースでは効かなかった（カーソル移動では発火しない）
- `advice-add` 方式が確実と判明

#### 2. プレビューウィンドウの表示改善
- `display-buffer-reuse-window` → `display-buffer-in-side-window` に変更
- `side . top` で画面上部に固定表示
- 高さを `my-git-show-file-preview-height` 変数で調整可能に
```elisp
(defvar my-git-show-file-preview-height 0.8
  "Height ratio of preview window (0.0-1.0).")
```

| 値    | 用途                                            |
|-------|-------------------------------------------------|
| `1.0` | ほぼ全画面（dired 等から使うとき）              |
| `0.8` | デフォルト（汎用）                              |
| `0.5` | 上下分割（現在ファイルと過去版を対比したいとき）|

#### 3. RET 後のクリーンアップ
- `:action` 内で `my-git-show-file--active` を `nil` に戻す
- `*git-preview*` バッファを `kill-buffer` で自動削除

### ファイル配置
```
~/.emacs.d/elisp/my-git-show-file/my-git-show-file.el
~/.emacs.d/elisp/my-git-show-file/README.md
```

### 次回検討事項
- 現在バッファでファイルを開いている場合、`buffer-file-name` + `:preselect` で
  ファイル選択を自動的に当該ファイル名にプリセット
- dired の場合、`dired-get-filename` でカーソル下のファイル名をプリセット
- 起動時にコンテキスト（通常バッファ／dired）を判定して分岐する実装
- まとめてリクエスト予定


## ~/.emacs.d/elisp/ Makefile 改良

### 背景
`~/.emacs.d/elisp/` 配下にサブディレクトリ形式のパッケージが混在する構成。
`normal-top-level-add-subdirs-to-load-path` で全サブディレクトリを load-path に追加。
`my-loaddefs.el` で `;;;###autoload` を一括管理。

### 変更内容

#### toggle-elc の改善
- `ls *.elc` → `find` による再帰検索に変更（サブディレクトリの .elc も対象）
- elc 削除時に `my-loaddefs.el` を消さないよう修正
- コンパイル後に `$(MAKE) compile` を自動実行（loaddefs 再生成まで一発完了）

#### compile の改善
- `loaddefs-generate` の第6引数に `t` を追加（サブディレクトリを再帰的に処理）

### 操作まとめ
| コマンド       | 動作                                      |
|----------------|-------------------------------------------|
| `make`         | elc がなければコンパイル → loaddefs 再生成 |
| `make`（2回目）| elc があれば削除（loaddefs は残る）        |
| `make compile` | loaddefs のみ再生成                        |

### git-show-file ディレクトリへの移行手順
```bash
mv ~/.emacs.d/elisp/my-git-show-file.el ~/.emacs.d/elisp/git-show-file/
# README.md も配置後
cd ~/.emacs.d/elisp && make
```
`my-loaddefs.el` に `my-git-show-file` のエントリが生成されていれば完了。

## ~/.emacs.d/elisp/Makefile compile ターゲット最終解決

### 問題
`loaddefs-generate` はサブディレクトリの `.el` を再帰的に処理できなかった。
（第6引数の再帰フラグ、`directory-files-recursively` 経由など複数の方法を試したが全滅）

### 原因
- `.elc` が存在すると `loaddefs-generate` がスキップする仕様
- 出力先と同ディレクトリのファイルをスキップする挙動も確認

### 解決
`update-directory-autoloads` に切り替えで解決。
deprecated 警告は出るが Emacs 30.1 でも正常動作する。

### 最終的な compile ターゲット
```makefile
compile:
	$(EMACS) --batch -Q \
	  --eval "(require 'autoload)" \
	  --eval "(let ((generated-autoload-file \"$(LOADDEFS)\")) \
	    (update-directory-autoloads \"$(ELISP_DIR)\"))" \
	  --eval "(message \"Done: %s\" \"$(LOADDEFS)\")"
```

### 確認済み
`my-loaddefs.el` に `git-show-file/my-git-show-file` のエントリが正常登録された。


## 本日の開発まとめ

### 解決した問題
1. `20-check.el` の `void-variable textlint` エラー
   → `(leaf textlint ...)` を `with-eval-after-load` に書き換え

2. `my-git-show-file.el` リアルタイムプレビュー実装
   → `advice-add` で `ivy-next-line` / `ivy-previous-line` にフック
   → `display-buffer-in-side-window` で上部固定表示
   → `my-git-show-file-preview-height` 変数で高さ調整可能

3. `~/.emacs.d/elisp/Makefile` 改良
   → `toggle-elc` を `find` 再帰検索に変更
   → コンパイル後に `make compile` 自動実行
   → `compile` ターゲットを `update-directory-autoloads` に変更
   → サブディレクトリ `git-show-file/` の autoload 登録に成功

### 成果物
- `~/.emacs.d/elisp/git-show-file/my-git-show-file.el`
- `~/.emacs.d/elisp/git-show-file/README.md`
- `~/.emacs.d/elisp/Makefile`
- `qiita-git-as-storage.md`（Qiita 記事バージョンアップ版）

### 次への課題（未着手）
- diff 表示対応（現在版と過去版の差分をプレビューに表示）
- フルパス対応（`index.html` 等同名ファイルが複数ディレクトリに存在する場合）
- コンテキスト判定（現在バッファのファイル名を自動プリセット、dired では
  カーソル下ファイルをプリセット）
- Qiita 記事最終仕上げ（タイムスタンプ自動挿入 `my:magit-insert-timestamp` を組み込む）
- my-git-show-file.elは初期の命名、ここまで進化してきたのでgit-peek.el に変更し単独リポジトリで公開したい。
- 著作権は、発案者（私）とclaude（コード生成）との共著であることをヘッダに書く
;; Copyright (C) 2026 Minoru Yamada and Claude (Anthropic)

---

## 2026-03-27

# CHANGELOG-20260327

## gitk テーマ調整
- `~/.config/git/gitk` に `set want_ttk 1` を設定
- Dracula テーマはすでに設定済みだったことを確認
- Tk の制約でフレーム枠の改善は限界と判断

## tig インストール
- `sudo apt install tig` で導入
- 基本操作確認：コミット移動、diff表示、ツリー表示
- dotfiles Makefile の `install` グループに `tig` を追加

## my:git-show-file 実装（`09-funcs.el`）
- git 管理リポジトリから過去バージョンのファイルを取り出す Emacs コマンド
- 操作フロー：ファイル選択（ivy）→ そのファイルの変更履歴から選択（ivy）→ 保存
- 保存先：`~/Dropbox/backup/tmp/ファイル名_YYYYMMDD-HHMM`
- 保存後に `~/Dropbox/backup/tmp/` を dired で開く
- コミット日時をファイル名に埋め込む（`%cd --date=format:` を `concat` で組み立て）
- `format` 関数内での `%` エスケープ問題を `concat` で回避
- 世代バックアップの代替として git を活用する画期的なワークフローが完成

## my:tig 実装（`09-funcs.el`）
- カレントディレクトリの git リポジトリで tig を gnome-terminal で開く Emacs コマンド
- `locate-dominating-file` でリポジトリルートを自動検出
- `start-process` で gnome-terminal を起動し tig を実行

## 40-hydra-dired.el キーバインド変更
- `("g" gitk-open)` → `("g" my:git-show-file)` に変更（gitk から卒業）
- `("t" my:tig)` を追加（tig でコミット履歴確認）

---

## 自作 Emacs Lisp の autoload 化対応

### 背景

Claude と共同で作成した便利関数が増加し、Emacs 起動時間への影響が出始めたため、
`require` による即時ロードから `autoload` による遅延ロードへ移行した。

---

### 変更ファイル一覧

**修正（`;;;###autoload` 追加）**

| ファイル | autoload数 | 主な変更 |
|---|---|---|
| `my_dired.el` | 34 | 全関数に `;;;###autoload` 追加 |
| `my_github.el` | 1 | 全関数に `;;;###autoload` 追加 |
| `my_template.el` | 13 | 全関数に `;;;###autoload` 追加 |

**整備（ヘッダー・`provide`・`lexical-binding` も追加）**

| ファイル | autoload数 | 主な変更 |
|---|---|---|
| `my_git-show-file.el` | 1 | ヘッダー・`lexical-binding`・`provide`・`declare-function`・`;;;###autoload` を新規追加 |
| `my_marhdown.el` | 3 | ヘッダー・`lexical-binding`・`provide`・`;;;###autoload` を新規追加 |

---

### 新規追加ファイル

- `~/.emacs.d/elisp/Makefile`
  - `make` で `my-loaddefs.el` を再生成
  - `make clean` で `my-loaddefs.el` を削除

---

### init.el の変更

`init-loader` の `:init` ブロック内、`load-path` 設定の直後に1行追加。

```emacs-lisp
(load "~/.emacs.d/elisp/my-loaddefs.el" t t)
```

---

### 削除対象

inits 群に存在する以下の `require` を削除する。

```emacs-lisp
(require 'my:dired)
(require 'my:template)
(require 'my:github)
```

---

### 運用ルール（今後）

1. 自作 `.el` には必ず `lexical-binding: t`・`;;;###autoload`・`provide` の3点セットを書く
2. 関数を追加・変更したら `cd ~/.emacs.d/elisp && make` を実行して `my-loaddefs.el` を再生成する
3. inits 群には `require` を書かない


---

## Emacs 接イェイファイルの  my: プレフィックスを my- に全面変更

### elisp/ 配下のファイルリネーム
```bash
for f in my:*.el my:*.elc; do mv "$f" "${f/my:/my-}"; done
```

### ファイル内シンボル名（provide/require/関数名）一括置換
```bash
grep -rl "my:" --include="*.el" --exclude-dir=tmp . | xargs sed -i 's/my:/my-/g'
```

### Makefile の : エスケープ問題を .PHONY 方式で回避
- ターゲット名に `:` を使うと make がセパレータと誤認するため

### elisp/Makefile の LOADDEFS を手動修正
```bash
sed -i 's/my:loaddefs/my-loaddefs/g' ~/.emacs.d/elisp/Makefile
```

---

## elisp/Makefile を大幅改善

### toggle-elc ターゲット追加
- `.elc` があれば削除、なければバイトコンパイルのトグル動作
- `a.out: toggle-elc` で `make -k` 一発実行
- `clean` は `toggle-elc` に委譲してコード重複を排除

### auto-compile 導入を試みたが断念
- シンボリックリンク経由のパス問題やフック未登録など原因不明
- `elisp/` のバイトコンパイルは `make -k`（toggle-elc）で手動運用に決定

### ターゲットにコメント追加
- 各ターゲットに `## 英語説明` を追記

### 成果品
```makefile
# Makefile for ~/.emacs.d/elisp/
# Usage: make           → toggle *.elc (compile if none, remove if exists)
#        make compile   → regenerate my-loaddefs.el
#        make clean     → same as toggle-elc
ELISP_DIR  := $(shell cd "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))" && pwd)
LOADDEFS   := $(ELISP_DIR)/my-loaddefs.el
EMACS      := emacs

.PHONY: all clean compile toggle-elc

a.out: toggle-elc

toggle-elc: ## Toggle *.elc: remove if exists, byte-compile if not
	@if ls *.elc 2>/dev/null | grep -q .; then \
	    rm -f $(LOADDEFS) *.elc; \
	    echo "Removed $(LOADDEFS) and *.elc"; \
	else \
	    $(EMACS) --batch -Q \
	      --eval "(byte-recompile-directory \"$(ELISP_DIR)\" 0 t)"; \
	    echo "Compiled *.elc"; \
	fi

clean: ## Same as toggle-elc
	@$(MAKE) toggle-elc

compile: ## Regenerate my-loaddefs.el using loaddefs-generate
	@echo "Generating $(LOADDEFS) ..."
	$(EMACS) --batch -Q \
	  --eval "(loaddefs-generate \"$(ELISP_DIR)\" \"$(LOADDEFS)\")" \
	  --eval "(message \"Done: %s\" \"$(LOADDEFS)\")"
	@echo "Done."
```

---

## 20-check.el `void-variable textlint` エラー修正

### 症状
- Emacs 起動時に以下のエラーが発生
  - `File mode specification error: (void-variable textlint)`
  - `eval-after-load-helper: Symbol's value as variable is void: textlint`
- 各モードで文字色（syntax highlight）が反映されず、プレーンテキスト表示になる

### 原因
`20-check.el` の `(leaf textlint ...)` ブロックが問題。
`textlint` は Emacs パッケージとして存在しないため `:ensure nil` にしているが、
`:after flycheck` と組み合わさったとき `eval-after-load-helper` が
`textlint` シンボルを変数として解決しようとしてエラーになる。

### 修正
`(leaf textlint ...)` ブロック全体を `with-eval-after-load` に書き換え。

**変更前**
```elisp
(leaf textlint
  :ensure nil
  :doc "Checker for textlint."
  :after flycheck
  :config
  (flycheck-define-checker textlint ...))
```

**変更後**
```elisp
(with-eval-after-load 'flycheck
  (flycheck-define-checker textlint
    "A linter for prose."
    :command ("textlint" "--format" "unix" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message (one-or-more not-newline)
                       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
              line-end))
    :modes (markdown-mode gfm-mode org-mode web-mode)))
```

---

## 2026-03-26

# CHANGELOG-20260326

## init.md の旧版（GitHub 掲載版）から新版への変更点をまとめています。

---

## ドキュメント全体の構成変更

| 項目 | 旧版 | 新版 |
|------|------|------|
| セクション構成 | 機能カテゴリ別（任意順） | ファイル番号順（00-base → 90-easy-hugo） |
| ファイル名表記 | アンダースコア区切り（`00_base.el`） | ハイフン区切り（`00-base.el`） |
| ディレクトリ構成 | 概略のみ（旧ファイル名・存在しないファイルを含む） | 実際の `ls` 出力に完全一致 |
| `elisp/` 配下 | 記載なし | ローカルパッケージを明示 |
| ファイル番号の意味 | 記載なし | カテゴリ表として追記 |
| `test.el` | ミニマル起動ファイルとして記載 | `init-mini.el` に改名、内容も更新 |

---

## 起動設定

### early-init.el

| 項目 | 旧版 | 新版 |
|------|------|------|
| native-comp 対応 | なし | `native-comp-jit-compilation nil` 追加 |
| パッケージ初期化の委譲 | なし | `package-enable-at-startup nil` 追加 |
| `load-prefer-newer` | なし | `noninteractive` 条件付きで追加 |
| フレームリサイズ抑制 | なし | `frame-inhibit-implied-resize t` 追加 |
| 起動時チラつき抑制 | `inhibit-redisplay` / `inhibit-message` + hook | `set-face-attribute` で背景色を直接指定（よりシンプル） |
| フォント設定 | `init.el` 内 | `early-init.el` に移動（起動高速化） |
| 言語環境設定 | `init.el` 内 | `early-init.el` に移動 |

### init.el

| 項目 | 旧版 | 新版 |
|------|------|------|
| Emacs バージョンチェック | なし | 29.1 以上を要求 |
| leaf のインストール方法 | `package-install 'leaf` | `use-package leaf :ensure t` 経由 |
| package-archives | gnu / melpa / **org** | gnu / melpa のみ（org elpa 削除） |
| `init-loader-byte-compile` | なし | `t` を設定（自動バイトコンパイル） |
| `custom-file` の分離 | なし | `tmp/custom.el` に明示分離 |
| `elisp/` の load-path 追加 | なし | サブディレクトリも含めて追加 |
| `exec-path-from-shell` | `PATH` のみ継承 | `SSH_AUTH_SOCK` も継承（keychain 連携） |

### init-mini.el（旧 test.el）

| 項目 | 旧版（test.el） | 新版（init-mini.el） |
|------|----------------|---------------------|
| ファイル名 | `test.el` | `init-mini.el` |
| alias 記述 | `alias eq = '...'`（スペースあり・誤り） | `alias eq="..."` |
| 補完 | ivy（外部パッケージ） | `fido-mode` / `fido-vertical-mode`（built-in） |
| electric-pair | なし | `electric-pair-mode` 追加 |

---

## パッケージの追加・変更・削除

### 新規追加

| パッケージ | ファイル | 概要 |
|-----------|---------|------|
| `evil` + `evil-leader` | 03-evil.el | vi/vim スタイル操作体系（旧ドキュメントに記載なし） |
| `goggles` | 07-highlight.el | 編集領域フラッシュ（volatile-highlights の代替） |
| `rainbow-delimiters` | 07-highlight.el | 括弧のレインボー表示 |
| `super-save` | 20-edit.el | スマート自動保存（auto-save-buffers-enhanced の代替） |
| `atomic-chrome` | 20-edit.el | ブラウザのテキストエリアを Emacs で編集 |
| `undohist` | 20-edit.el | undo 履歴の永続化 |
| `sudo-edit` | 20-edit.el | root 権限でファイル編集 |
| `ediff` 設定 | 20-edit.el | 差分編集（水平分割・シンプルモード） |
| `hide-mode-line` | 30-ui.el | imenu-list / neotree でモードライン非表示 |
| `display-fill-column-indicator` | 30-ui.el | 79列目ガイドライン（built-in） |
| `projectile` | 30-utils.el | プロジェクト管理 |
| `persistent-scratch` | 30-utils.el | scratch バッファ永続化 |
| `bs` | 30-utils.el | バッファ循環（built-in） |
| `deepl-translate` | 70-translate.el | DeepL API 翻訳（自作パッケージ） |
| `deepl-translate-web` | 70-translate.el | ブラウザで DeepL を開く |
| `mozc-cursor-color` | 06-mozc.el | IME 状態をカーソル色で表示（自作パッケージ） |
| `avy` | 04-counsel.el | キーワードジャンプ |
| `migemo` + `my:ivy-migemo-re-builder` | 04-counsel.el | swiper での日本語インクリメンタル検索 |
| `google-this` | 10-selected.el | カーソル位置の単語を Google 検索 |
| `textlint` チェッカー | 20-check.el | 文章の lint（flycheck 連携） |
| `ispell` / `hunspell` | 20-check.el | スペルチェック |
| `hydra-dired` | 40-hydra-dired.el | ディレクトリランチャー（`M-.`） |

### パッケージの置き換え・移行

| 旧パッケージ | 新パッケージ | ファイル | 理由 |
|-------------|------------|---------|------|
| `volatile-highlights` | `goggles` | 07-highlight.el | より現代的な実装 |
| `all-the-icons` | `nerd-icons` | 30-ui.el | Emacs 29 時代の標準 |
| `all-the-icons-dired` | `nerd-icons-dired` | 30-ui.el | 同上 |
| `all-the-icons-ivy-rich` | — | — | nerd-icons 移行により不要 |
| `flymake` + `flymake-posframe` | `flycheck` | 20-check.el | 構文チェックを flycheck に統一 |
| `auto-save-buffers-enhanced` | `super-save` | 20-edit.el | シンプルで安定した実装 |
| `auto-save-buffers-enhanced`（scratch 用） | `persistent-scratch` | 30-utils.el | scratch 専用パッケージに分離 |
| `swiper-migemo`（el-get） | `my:ivy-migemo-re-builder` | 04-counsel.el | 外部依存を排除し内製化 |
| `mozc-posframe` | `mozc-popup` | 06-mozc.el | 候補表示スタイルの変更 |
| `defadvice` (mozc) | `advice-add` | 06-mozc.el | 現代的な advice API に統一 |

### 削除されたパッケージ

| パッケージ | 理由 |
|-----------|------|
| `restart-emacs` | `C-x C-c` を `server-edit` に変更したため不要 |
| `smartparens` | `elec-pair`（built-in）で代替 |
| `open-junk-file` | `org-capture` テンプレートで代替 |
| `tempbuf` | `super-save` + `persistent-scratch` で代替（※ elisp/ には残存） |
| `amx` | `prescient` の履歴機能で代替 |
| `ivy-prescient` の分散設定 | `05-company.el` に集約 |
| `symbol-overlay` | — |
| `emacs-livedown` | `markdown-preview-use-browser` で代替 |
| `page-break-lines`（独立設定） | `01-dashboard.el` 内に統合 |
| `nyan-mode` | doom-modeline から削除 |
| `popwin` 独立設定 | `30-utils.el` に統合（機能は継続） |

---

## 各ファイルの主な変更点

### 00-base.el

- `bidi-paragraph-direction 'left-to-right` 追加（描画高速化）
- `vc-follow-symlinks t` 追加
- `delete-by-moving-to-trash t` 追加
- `require-final-newline t` / `next-line-add-newlines nil` 追加
- シェル系ドットファイルの `auto-mode-alist` 設定を追加
- 履歴・データファイルのパスを `tmp/` 配下に一元管理
- `handle-delete-frame` の上書き追加（最後のフレームを最小化）
- `C-x C-c` → `server-edit`（誤終了防止）
- `delete-this-file`（`C-x /`）追加
- `other-window-or-split` から `dimmer` / `follow-mode` 連動を削除（シンプル化）

### 02-git.el

- キーバインド：`M-g s` → `C-x g`
- `hydra-magit` 追加（blame / checkout / log / gitk / timemachine）
- `gitk-open` 関数追加
- `diff-hl` を `02-git.el` に移動・色を明示設定
- `git-timemachine-toggle` → `git-timemachine`

### 04-counsel.el

- `counsel-ag` に `advice-add` でカーソル位置ワードを初期入力に利用
- `swiper-migemo`（el-get）廃止 → `my:ivy-migemo-re-builder` で内製化
- `avy` 追加（`C-r`）
- アイコン表示を `all-the-icons-octicon` → nerd-icons フォント直接指定に変更

### 05-company.el

- `company-idle-delay`：`0`（即時）→ `0.5`
- 補完トリガー：`C-<return>` → `<backtab>`
- `prescient` / `yasnippet` を本ファイルに集約

### 06-mozc.el

- `mozc-posframe` → `mozc-popup`
- `mozc-leim-title`：`"かな"` → `"あ"`
- `my:toggle-input-method` 新設（evil 連携）
- `my:mozc-config` 追加（設定ダイアログ）
- `mozc-tool` 呼び出し：`compile` → `start-process`
- `?` / `!` の即時入力を削除（`,` / `.` のみ残存）
- `mozc-protobuf-get` への `advice-add` パッチ追加（仕様変更対応）

### 07-highlight.el

- `volatile-highlights` → `goggles`
- `rainbow-delimiters` 追加
- `elec-pair` で text-mode を無効化（yasnippet 競合回避）
- `aggressive-indent` を `global` 有効化（html-mode 除外）
- `web-mode` をこのファイルに移動、`web-mode-enable-auto-indentation nil` 追加

### 08-dimmer.el

- 起動方法を改善：`window-configuration-change-hook` で初回自動有効化
- minibuffer 出入り時・imenu-list 表示時に自動 on/off
- `dimmer-configure-*` を `dimmer-excludes` にまとめて startup hook で実行
- `dimmer-fraction`：`0.6` → `0.5`
- `other-window-or-split` との連動廃止

### 10-selected.el

- `my:koujien` / `my:eijiro` 削除
- `chromium-translate` 削除
- `my:google` → `my:google-this`（`google-this` パッケージ利用）
- `deepl-translate`（`d`）追加
- `region-or-read-string` ヘルパー追加
- `inactivate-input-method` → `deactivate-input-method`（API 変更対応）

### 20-check.el

- `flymake` + `flymake-posframe` → `flycheck` に移行
- `textlint` チェッカー追加
- `ispell` / `hunspell` 設定追加

### 20-edit.el

- `auto-save-buffers-enhanced` → `super-save`
- `imenu-list` をこのファイルに移動、`j`/`k` キーバインド追加
- `atomic-chrome` 追加
- `ediff` 設定追加
- `undohist` 追加
- `sudo-edit` 追加
- `open-junk-file` / `tempbuf` 削除

### 30-ui.el

- `all-the-icons` → `nerd-icons` / `nerd-icons-dired`
- `hide-mode-line` 追加
- `display-fill-column-indicator` 追加（79列ガイドライン）
- `whitespace` の `my:cleanup-for-spaces-safe` 強化（NBSP・ゼロ幅スペース対応）
- `nyan-mode` 削除
- `line-spacing` の `my:linespacing` 設定削除

### 30-utils.el

- `which-key`：MELPA → built-in（`:ensure nil`）、`which-key-delay 0.0` 追加
- `key-chord`：MELPA → `elisp/` ローカルパッケージ
- `persistent-scratch` 追加（scratch 永続化）
- `toggle-scratch` をここで管理
- `bs` 追加（`M-]`/`M-[`）
- `projectile` 追加
- `sequential-command`：el-get → `elisp/` ローカルパッケージ
- `prescient` / `amx` を他ファイルに移動

### 60-howm.el

- migemo 連携設定を追加（`cmigemo` 直接指定）
- `howm-view-title-regexp` で `##` 以降を一覧から除外
- `howm-user-font-lock-keywords` を拡張（7カテゴリ）
- `howm-template` で3種類のテンプレートを定義
- `my:howm-create-note` / `my:howm-create-memo` / `my:howm-create-tech` 追加
- `my:howm-fix-after-super-save`（Perl スクリプト連携）追加
- `org-capture` との連携廃止、howm 独自関数に統一

### 60-markdown.el

- `README.md` → `gfm-mode`、その他 → `markdown-mode` と使い分け
- プレビュー：`emacs-livedown` → `pandoc` + Chrome
- `my:howm-fix-code-comments` 追加（`C-c #`）
- `my:delete-tmp-markdown-html` 追加
- `gen-toc-term` 追加
- `md2pdf` / `md2docx` 追加（pandoc 変換）
- カスタム CSS + `highlight.js` によるプレビュー強化

### 60-org.el

- `org-agenda-files`：`~/Dropbox/org/` → `~/Dropbox/howm/org/`
- `org-agenda-span`：`30`（数値）→ `'month`（シンボル）
- `org-startup-truncated nil` 追加
- `org-capture-templates` を大幅拡張（8カテゴリ）
- `timep-use-speed-commands` → `org-use-speed-commands`（typo 修正）
- `calendar` / `japanese-holidays` をこのファイルに統合

### 70-translate.el

- `deepl-translate`（自作パッケージ）追加
- `deepl-translate-web` 追加（ブラウザ連携）
- DeepL API 認証方式の変更対応（2026-03-10）

### 80-darkroom.el

- トリガーキー：`[f12]` → `[f8]`
- `toggle-frame-fullscreen` 追加（全画面化）
- `evil-emacs-state` / `evil-normal-state` 連携追加
- `line-spacing`：`my:linespacing` への依存を廃止、直接 0 / 0.2 を設定
- `view-mode` 連動廃止
- `revert-buffer` 廃止

### 90-easy-hugo.el

- 管理ブログ数：1 → 8（`easy-hugo-bloglist` で blog2〜8 を追加）
- カスタムヘルプメニュー（`easy-hugo-help`）定義
- `my:edit-easy-hugo` 追加（設定ファイルを直接開く）
- `my:easy-hugo-newpost-after` 追加（新規ポスト後の evil 連携）

---

## typo・誤記の修正（旧ドキュメントから引き継がれていたもの）

| 箇所 | 旧（誤） | 新（正） |
|------|---------|---------|
| alias 記述 | `alias eq = '...'` | `alias eq="..."` |
| `.coderc` | `.coderc` | `.bashrc` |
| `company-yasunippets` | `company-yasunippets` | `company-yasnippet` |
| `councel-fontawesome` | `councel-fontawesome` | `counsel-fontawesome` |
| `FontAwesome` パッケージ名 | `FontAwesome` | `fontawesome` |
| `code-quote-argument` | `code-quote-argument` | `shell-quote-argument` |
| `code-command-to-string` | `code-command-to-string` | `shell-command-to-string` |
| `gonome-terminal` | `gonome-terminal` | `gnome-terminal` |
| `timep-use-speed-commands` | `timep-use-speed-commands` | `org-use-speed-commands` |
| `#!/bin/code`（dvpd.sh） | `#!/bin/code` | `#!/bin/zsh` |
| セクション名 | `デレクトリ構成` | `ディレクトリ構成` |


---

## Thunderbird バックアップ構成の整理

### thunderbird-backup.sh
- バックアップ先を `.thunderbird/`（隠しディレクトリ）から `profile/` に変更
- `set -e` を削除、`pkill` に `|| true` を追加（autobackup.sh の終了コード判定と整合）
- `mkdir -p "$DST"` を追加（初回実行時のディレクトリ自動作成）
- ログにタイムスタンプを追加（mattermost-backup.sh と形式を統一）

### ~/Dropbox/backup/thunderbird/README.md
- 作業中メモ（thunderbird-backup.md）と古い README.md を廃棄
- 現状構成を正確に反映した README.md に書き直し
- スクリプトパスを `dotfiles/cron/` に明記
- External Editor Revived の GLIBC 制約を表形式で記載

### ~/Dropbox/makefile
- `melpa` ターゲットのコメントを「git push 方式」に更新
- 古い tar.gz 世代管理処理（`rm -rf` + `tar cfz` の2行）を削除
- 修正履歴に `2026-03-26` エントリを追加


---

## Gnome keyring 管理方式の変更

### 変更概要

P1（親機）の keyring 管理をシンボリックリンク方式から実体コピー方式に移行した。
あわせて autostart.sh の条件分岐を削除し、mozc 同期・keyrings コピーを両機共通処理に統一した。

### 変更前

- P1：`~/.local/share/keyrings` → `~/Dropbox/backup/keyrings` のシンボリックリンク（Dropbox が正本）
- サブ機：`autostart.sh` 起動時に `cp -a` でコピー

### 変更後

- P1・サブ機共通：起動時に `autostart.sh` が Dropbox から `rsync` でコピー
- P1：毎晩 `autobackup.sh` で `~/.local/share/keyrings` を Dropbox にバックアップ

### 変更ファイル

**`~/Dropbox/makefile`**
- `keyring-backup` ターゲットを追加

```makefile
## Gnome keyring を Dropbox にバックアップ（P1 の実体 → Dropbox）
keyring-backup:
	rsync -av --delete ${HOME}/.local/share/keyrings/ ${HOME}/Dropbox/backup/keyrings/
```

- `keyring` ターゲットのコメントアウトコード（旧シンボリックリンク方式）を削除
- `make keyring` の説明を「全機共通コピー方式」に更新

**`/usr/local/bin/autobackup.sh`**
- `run_target "keyring" keyring-backup` を追加（mozc-backup の後）

**`~/.autostart.sh`**
- P1 判定の `if` 条件分岐を完全に削除
- mozc 同期・keyrings コピーを両機共通処理に統一
- `cp -a` → `rsync --delete` に変更

```bash
# 両機共通: mozc 設定と keyrings を Dropbox からリストア
rsync -av --delete ~/Dropbox/backup/mozc/.mozc/ ~/.mozc/
rsync -av --delete ~/Dropbox/backup/keyrings/ ~/.local/share/keyrings/
```

### P1 での移行手順（実施済み）

```bash
rm -f ~/.local/share/keyrings
rsync -av --delete ~/Dropbox/backup/keyrings/ ~/.local/share/keyrings/
```

### ~/Dropbox/backup/ サブディレクトリ README 整備
- 各サブディレクトリに README.md を新規作成（changelog, emacs, filezilla, gitea, gnupg, icons, keypassX, keyrings, mattermost, mozc, ssh, tokens, zsh）
- 内容は「何が入っているか・どのスクリプトが読み書きするか」の最小限に統一

### Gnome Keyring 管理方式の変更
- P1：シンボリックリンク方式 → 実体コピー方式に移行（`rm -f ~/.local/share/keyrings` → `rsync`）
- autobackup.sh に `keyring-backup` ターゲットを追加
- autostart.sh の P1 判定条件分岐を削除、mozc・keyrings リストアを両機共通化
- keyrings.bak/ を保険として保留中（再起動確認済み、数日後に削除予定）

### Thunderbird バックアップ構成の整理
- thunderbird-backup.sh：バックアップ先を `profile/` に変更、`set -e` 削除、タイムスタンプ追加
- thunderbird/README.md：現状構成を正確に反映した内容に書き直し
- ~/Dropbox/makefile：melpa コメントを「git push 方式（7日分世代バックアップ併用）」に更新、旧 tar.gz 世代管理処理を削除

---

### elpa バックアップ方式を刷新
- .emacs.d/elpa 内の .git 管理・elpa.git ベアリポジトリを廃止
- ~/Dropbox/backup/elpa/ を新設、rsync + git push（Gitea・Xserver）方式に移行
- .emacs.d/Makefile を廃止、melpa ターゲットを ~/Dropbox/makefile に直接統合
- Gitea の旧 elpa リポジトリを削除・再作成、Xserver に elpa.git ベアリポジトリ新設

---

## 2026-03-25

# CHANGELOG-20260325

### Removed
- `deploy.sh` — makefile に統合済みのため削除

### Changed
- `_config.yml` — `remote_theme` を URL 形式から `user/repo` 形式に修正
- `_config.yml` — `exclude` リストを実在するファイルのみに整理
- `docs/makefile` — `deploy.sh` 依存を解消、ターゲット名を `git` に統一
- `docs/README.md` — タイポ修正 (Configulation → Configuration)
- `README.md` — リポジトリ構成と deploy 手順を追記
- `makefile` — `changelog`/`log`/`cat`/`commits`/`actions` ターゲットを追加

### Fixed
- `docs/_includes/extra/head.html` — テーマが自動生成する HTML の重複を解消（空ファイルに）

### Added
- `CHANGELOG.md` — 新規作成、追記運用開始
- `github-deploy` — Emacs 関数、changelog-YYYYMMDD.md から CHANGELOG.md に自動追記

---

## 2026-03-24

# CHANGELOG-20260324

## dotfiles/devils/ README 作成

### 内容

ログイン時の Emacs 自動起動・常駐化の仕組みを `dotfiles/devils/README.md` としてまとめた。
3つの要素で構成している：

1. **devilspie + devils_startup.sh** — ログイン時に自動起動＆最小化
2. **Emacs server** — init.el で server-start、emacsclient からフレームを開ける
3. **handle-delete-frame 上書き** — 最後の1フレームを閉じても終了させない

### handle-delete-frame について

`delete-frame-functions` フックを使う方法も試みたが、
✕ボタン経由のフレーム削除を止められなかったため元の実装を継続採用。
`frame.el` の組み込み関数上書きはリスクがあるとされるが、
長期間問題なく動作しており実績ある実装として維持する。

### 対象ファイル

- `dotfiles/devils/README.md` — 新規作成

---

## my:dired.el / my:template.el リファクタリング

### 背景

- `my:dired.el` は load-path を通すだけで `require` していなかった
- `my:template.el` は 00-base.el に autoload を書き連ねていたが、ロード時間への寄与はほぼゼロで、メンテナンスコストの方が大きかった
- 両ファイルとも「hydra から呼ばれるプライベートな設定を別ファイルに分離する」という設計意図があるため、ファイル分離は維持する方針とした

### 変更内容

#### my:dired.el

- `leaf my:dired` ブロックを廃止し、トップレベルの `defun` 群に整理
- `:defun` 宣言を `declare-function` に置き換え（flycheck 警告対策）
- `my:w_kukai` の重複定義を削除（2番目の定義を残す）

#### my:template.el

- `leaf *my:template` ブロックを廃止し、トップレベルの `defun` 群に整理
- `:defun` 宣言を `declare-function` に置き換え
- `*` プレフィックスと `(provide 'my:template)` の矛盾を解消
- `setq string` を `let` に修正（グローバル変数汚染の防止）・3箇所
- `my:minoru_sen` を呼び出し元より前に移動（定義順の整合）

#### 40-hydra-dired.el

- `:require my:dired` を追加

#### 40-hydra-menu.el

- `:require my:template` を追加

#### 00-base.el

- `my:template` 関係の autoload 宣言を削除

### leaf での :require 書式

```elisp
(leaf *hydra-dired
  :require my:dired
  ...)

(leaf *hydra-work
  :require my:template
  ...)
```

leaf 展開時に `(require 'my:dired)` / `(require 'my:template)` が実行される。

---

## Docker httpd: Tailscale 経由スマホ確認用ポート追加

### 背景と問題

ローカルネットワーク内では `gh.local:8080` / `minorugh.local:8080` というホスト名で
2つのサイトを切り替えてアクセスできていた。これは Apache のバーチャルホスト機能で
ブラウザが送る `Host:` ヘッダーを見てサイトを振り分けている仕組み。

Tailscale 経由で出先のスマホからアクセスする場合、`.local` ドメインは
mDNS（ローカルネットワーク内だけの名前解決）なので使えず、
IP アドレス直打ち（`http://100.x.x.x:8080/`）しか手段がない。

ところが IP 直打ちでは `Host:` ヘッダーが `100.x.x.x` になるため
バーチャルホストの振り分けが機能せず、`vhosts.conf` の先頭に書かれたサイトしか
表示できなかった。つまり2サイトの切り替えが不可能だった。

### 解決策

ポート番号でサイトを振り分ける方式を採用。Apache に8081番ポートも Listen させ、
ポートごとに表示するサイトを固定することで IP 直打ちでも切り替えを可能にした。

### 変更ファイルと内容

#### httpd.conf

```
Listen 80
Listen 8081   ← 追加
```

#### vhosts.conf

```apache
# ポート80（既存）: ホスト名で振り分け。先頭を gh.local に変更
# → IP直打ちのデフォルトが gospel-haiku.com になる
<VirtualHost *:80>
    ServerName gh.local
    DocumentRoot /var/www/html/gospel-haiku.com/public_html
    ...
</VirtualHost>

<VirtualHost *:80>
    ServerName minorugh.local
    DocumentRoot /var/www/html/minorugh.com/public_html
    ...
</VirtualHost>

# ポート8081（新規追加）: minorugh.com 専用
<VirtualHost *:8081>
    ServerName minorugh.local
    DocumentRoot /var/www/html/minorugh.com/public_html
    ...
</VirtualHost>
```

#### docker-compose.yml

```yaml
ports:
  - "8080:80"
  - "8081:8081"   ← 追加
```

### アクセス方法

| URL | サイト | 用途 |
|---|---|---|
| `http://gh.local:8080/` | gospel-haiku.com | ローカル（従来通り） |
| `http://minorugh.local:8080/` | minorugh.com | ローカル（従来通り） |
| `http://100.x.x.x:8080/` | gospel-haiku.com | Tailscale経由スマホ確認 |
| `http://100.x.x.x:8081/` | minorugh.com | Tailscale経由スマホ確認 |

### 操作手順

```bash
cd ~/src/github.com/minorugh/dotfiles/docker/httpd
docker compose down
docker compose up -d
docker ps   # 両ポートが表示されれば OK
```

---

## 2026-03-23

# CHANGELOG-20260323

## howm-fix-code-comments.pl — トグル機能追加

コードブロック内の `#` 変換ロジックを拡張した。

- `# foo` → `## foo`（howm list 除外）
- `## foo` → `# foo`（削減）
- `### foo` → `## foo`（削減）

キーバインド `C-c #` で呼び出せるようにして快適な運用を実現。

## deepl-translate.el — provide 追加・警告修正

- `(provide 'deepl-translate)` が抜けていたため leaf ブロックで
  `failed to provide feature 'deepl-translate'` エラーが発生していた。
  ファイル末尾に追加して解消。
- `;;; lexical-binding` 追加により bytecomp warning を解消。
- `flycheck-disabled-checkers: (emacs-lisp-checkdoc)` を Local Variables
  ブロックに追加して checkdoc info を抑制。

## inits/ 全ファイル — `:custom-face` → `custom-set-faces` 統一

auto-compile 後に `:custom-face` キーワードが定数リストを変更しようとして
エラーになる問題を解消するため、以下4ファイルの `:custom-face` ブロックを
`:config` 内の `custom-set-faces` 呼び出しに書き換えた。

- `02-git.el` — `diff-hl-change/delete/insert`
- `07-highlight.el` — `goggles-added/changed/removed`、`show-paren-match`
- `30-ui.el` — `region`、`hl-line`
- `60-markdown.el` — `markdown-code-face`、`markdown-pre-face`

## 60-howm.el — `:defun` 宣言漏れ修正

`my:howm-fix-after-super-save` が `:defun` に未記載だったため、
bytecomp が「関数が定義されていない」と警告を出していた。
`:defun` リストに追加して解消。

## compile-log クリーン確認

全 29 ファイルの auto-compile が警告ゼロで完了することを確認した。
`Compiling internal form(s)` はステータスメッセージであり警告ではない。

## cron スクリプト刷新 — ログ形式を1ジョブ1ブロックに整理

### automerge.sh

各Stepの結果を個別に出力する形式に書き直した。
重複出力バグ（末尾で `echo` と `>> /tmp/cron.log` を二重に書いていた）も同時に修正。

```
[automerge] START: 2026-03-23 23:40:01
[automerge] Step1 rsync dmember: OK
...
[automerge] END: 2026-03-23 23:40:08 (OK)
```

### autobackup.sh

`make -f makefile` を一括実行していた従来方式を廃止。
各ターゲット（melpa/git-push/mattermost/mozc）を個別に呼び出し、
結果をそれぞれログに出力する方式に変更。

```
[autobackup] START: 2026-03-23 23:50:01
[autobackup] melpa: OK
[autobackup] git-push (GH+minorugh.com): OK
[autobackup] mattermost: OK
[autobackup] mozc: OK
[autobackup] END: 2026-03-23 23:50:20 (OK)
```

試運転で全ステップ正常動作を確認。automerge 3秒、autobackup 11秒。

### README 更新

以下2ファイルの cron 関連記述を現状に合わせて修正。

- `~/Dropbox/README.md` — `myjob.sh` → `automerge.sh`、ログパス `/tmp/myjob.log` → `/tmp/cron.log` に修正
- `~/dotfiles/cron/README.md` — ログ形式サンプルを新フォーマットに更新

---

## 60-markdown.el — my:howm-fix-code-comments リージョン対応

`C-c #` 一本でファイル全体処理とリージョン処理を自動判別する方式に拡張。

### 動作仕様

- リージョンなし → 従来通り Perl スクリプトでファイル全体を処理
- リージョンあり + コードブロック内 → Elisp でリージョン内の行のみトグル処理
- リージョンあり + コードブロック外 → "not in code block" メッセージを表示

### トグルロジック（リージョン処理時）

- `# foo` → `## foo`
- `## foo` → `# foo`
- `### foo` → `## foo`

### 実装ポイント

- `my:howm-fix--in-code-block-p` ヘルパー関数を追加
  カーソル位置より前の ` ``` ` の出現回数が奇数なら「コードブロック内」と判定
- `copy-marker` で `end` を固定し、バッファ編集中の位置ずれを防止
- ` ``` ` 行をリージョンに含めなくても正しく動作する

### 動作確認済み

---

## migemo 関連設定を全面修正

### howm migemo 復活 (60-howm.el)

Emacs 30.1 移行後に howm の migemo 検索が動かなくなっていた原因を特定。
`howm-migemo-command` は howm が参照しない変数で、正しい設定変数は
`howm-migemo-client` だった。

**修正内容：**

```elisp
;; 誤（howm が参照しない変数）
(setq howm-migemo-command "/usr/bin/cmigemo")

;; 正
(setq howm-migemo-client '((type . cmigemo) (command . "/usr/bin/cmigemo")))
(setq howm-migemo-client-option '("-q" "-d" "/usr/share/cmigemo/utf-8/migemo-dict"))
```

### migemo leaf ブロック整理 (04-counsel.el)

`with-eval-after-load 'isearch` による暫定設定を廃止し、
leaf ブロックに統一。

```elisp
(leaf migemo :ensure t
  :doc "Japanese incremental search through dynamic pattern expansion."
  :hook (after-init-hook . migemo-init)
  :config
  (setq migemo-command "/usr/bin/cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix))
```

### swiper-migemo 復活 (04-counsel.el)

`dash.el` のアナフォリックマクロ（`--map`、`--partition-by`、`it`）が
`lexical-binding: t` 環境で動作しないため、素の Elisp で書き直した。
`:vc` leaf キーワードも廃止し `with-eval-after-load 'swiper` にインライン化。

### 動作確認済み。

---

## md2pdf / md2docx xdg-open 修正

### 問題
pandoc変換後に `xdg-open` が機能しない（ファイルは生成される、エラーも出ない）。

### 原因
`start-process-shell-command` はシェル経由実行のため、Emacsの環境変数
（`DISPLAY`、`DBUS_SESSION_BUS_ADDRESS` など）が引き継がれないケースがある。

### 修正
`start-process-shell-command "xdg-open" ...` を `call-process "xdg-open"` に変更。
ファイルパスを引数として直接渡すことで解決。

---

## howm-fix-code-comments リファクタリング

### 背景
トグル機能を持つ複雑な実装から、実用上必要な機能に絞ったシンプル版に整理。

### 変更内容

**elisp側 (`~/.emacs.d/inits/` 該当ファイル)**
- `my:howm-fix--in-code-block-p` 関数を削除
- リージョン処理のコードブロック内限定チェックを廃止（バッファ内どこでも動作）
- トグル処理（`## `→`# `、`### `→`## `）を削除
- `# ` → `## ` の一方向変換のみに簡略化

**Perl側 (`~/.emacs.d/elisp/howm-fix-code-comments.pl`)**
- `## `→`# ` と `### `→`## ` のトグルパターンをコメントアウトで残す
- `# ` → `## ` の一方向変換のみ有効化

### 設計方針
- ファイル全体処理はPerlで一発処理
- 取りこぼし修正はリージョン選択で手軽に対応
- トグルは不要と判断。Perl側はコメントアウトで将来の可能性を残す

---

## 追加作業ログ（2026-03-23）

### STEP 1：P1 蓋閉めスリープ無効

`/etc/systemd/logind.conf` を確認。以下の2行がコメントなしで有効済みだった：

```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

```bash
sudo systemctl restart systemd-logind
```

### STEP 2：P1 Tailscale インストール

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up  # Google アカウントで認証
sudo systemctl enable --now tailscaled
tailscale ip -4    # → 100.96.55.61
```

### STEP 3：X250 Tailscale インストール

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up  # 同じ Google アカウントで認証
sudo systemctl enable --now tailscaled
tailscale ip -4    # → 100.119.220.1
```

### STEP 4：X250 Mattermost デスクトップアプリ

公式から直接 .deb を取得してインストール：

```bash
wget https://releases.mattermost.com/desktop/6.1.0/mattermost-desktop_6.1.0-1_amd64.deb
sudo dpkg -i mattermost-desktop_6.1.0-1_amd64.deb
```

ブラウザで `http://100.96.55.61:8065` → "View Desktop App" からアプリに誘導、ログイン成功。

### STEP 5：Pixel 8 Tailscale 設定

Mattermost アプリは導入済み。Google Play で Tailscale をインストールし、同じ Google アカウントでログイン。サーバー URL を `http://100.96.55.61:8065` に変更してログイン成功。

### 完了

- [x] P1 蓋閉めスリープ無効
- [x] P1 Tailscale インストール・設定（100.96.55.61）
- [x] X250 Tailscale インストール・設定（100.119.220.1）
- [x] X250 Mattermost デスクトップアプリ導入・ログイン確認
- [x] Pixel 8 Tailscale インストール・ログイン確認
ilscale

---

## 2026-03-22

# CHANGELOG-20260322

## Mattermost Docker環境 再構築・移行作業

### 背景
- 当初はDropbox共有によるサブ機との共同運用を想定して構築
- 安定しないためメイン機（P1）単独運用に方針変換
- 過去に複数セッションでymlを書き直した結果、Dropboxパス・GitLab残骸等が混入
- 本日、完全クリーン再構築を実施

---

### 午前の作業（事前準備）

- 不要な匿名ボリューム92個を `docker volume prune` で削除（1.919GB解放）
- DBバックアップ取得: `~/mattermost_backup.sql`（324KB、09:15）
- GitLabコンテナ（誤混入）を削除

---

### 午後の作業

#### Phase 1 — docker-compose.yml再構築

**問題点の確認:**
- 全ボリュームが `~/Dropbox/backup/mattermost/` を直接マウントしていた
- `data`, `logs`, `config`, `plugins`, `db` の全5ディレクトリがDropboxパス
- 旧方針（Dropbox共有運用）のまま完全に残存

**実施内容:**
- `~/Docker/mattermost/{db,data,config,logs,plugins}` を新規作成
- `~/Docker/README.md` を作成（誤削除防止）
- `docker-compose.yml` を新規作成（全ボリュームを `/home/minoru/Docker/mattermost/` 配下に変更）
- 匿名ボリューム2個（旧データ）を削除
- `sudo chown -R 2000:2000 /home/minoru/Docker/mattermost` でパーミッション設定
- クリーン状態でコンテナ起動・動作確認（セットアップ画面表示を確認）

**DBリストア:**
- `docker stop mattermost` でMattermostのみ停止（postgresは維持）
- DROP DATABASE → CREATE DATABASE でDB初期化
- `~/mattermost_backup.sql` から `\restrict` 行を除去してリストア
- `docker start mattermost` で再起動
- ログイン確認済み、ユーザー数4件（システム2＋作成済み2）

#### Phase 2 — バックアップスクリプト見直し

**旧 `mattermost-backup.sh` の問題点:**
- バックアップ先がDropboxパス直指定（継続）
- `config` と `data` を tar.gz で7世代管理
- `sudo tar` が必要でchown処理が必要だった

**新 `mattermost-backup.sh` の仕様:**
- `data/`, `config/`, `logs/`, `plugins/` を rsync で上書き同期
- DBは `pg_dump` で `mattermost.sql` に上書き保存（世代管理なし）
- バックアップ先: `~/Dropbox/backup/mattermost/`（Dropboxがバージョン管理）
- `BACKUP_DIR` を `/home/minoru/Dropbox/...` に固定（sudo実行時の$HOME問題を回避）
- 動作確認済み

**Dropbox側の旧データ整理:**
- `db/` ディレクトリ削除（新方針では不要）
- `20260321.tar.gz` 削除
- `mattermost_20260321.sql` 削除

#### Phase 3 — Makefile類の修正

**dotfiles/docker/Makefile:**
- `mattermost` ターゲットの `chown` パスを Dropbox → `/home/minoru/Docker/mattermost` に変更
- `mattermost-backup` ターゲットをシンプル化（`mattermost-backup.sh` を呼ぶだけ）

**dotfiles/Makefile:**
- `docker-setup` ターゲットを新方針に対応
  - ディレクトリ作成 + Dropboxからrsyncでデータ復元
- `mattermost-restore-db` ターゲットを新規追加
  - DBをDropboxの `mattermost.sql` からリストア

**新規リストア手順（3ステップ）:**
```
Step 1: make docker-setup          # ディレクトリ作成＋rsyncでデータ復元
Step 2: make mattermost            # コンテナ起動
Step 3: make mattermost-restore-db # DBリストア
```

**dotfiles/README.md:**
- ターゲット一覧を新方針に合わせて更新（Step1〜3を明記）
- 更新履歴に本日分を追記

---

### 最終確認

```
mattermost       healthy  0.0.0.0:8065->8065/tcp
mattermost-postgres  healthy  5432/tcp
gitea            Up       0.0.0.0:3000->3000/tcp
httpd            Up       0.0.0.0:8080->80/tcp
```

- `~/Docker/mattermost/` — ローカルデータ正常
- `~/Dropbox/backup/mattermost/` — rsyncバックアップ済み
- ログイン確認済み

---

## UPower 蓋閉じ警告の調査と修正

### 症状

ノートの蓋を閉じると GNOME/Xfce の通知領域に以下の警告が出る：

```
電源管理
GDBus.Error:org.freedesktop.DBus.Error.AccessDenied: Permission denied
```

### 原因調査

`dbus-monitor` で蓋閉じ時の DBus シグナルを監視：

```bash
dbus-monitor --system 2>&1 | grep -i "upower\|power\|denied\|lid" &
```

蓋閉じ時に以下のシグナルを確認：

```
path=/org/freedesktop/UPower
interface=org.freedesktop.DBus.Properties
member=PropertiesChanged
  string "LidIsClosed"
  variant "Device cannot be used while the lid is closed"
```

### 原因

UPower が蓋閉じ＝デバイス使用不可と判定している。  
外部モニターでクラムシェル運用しているにもかかわらず、UPower がそれを考慮せず  
Xfce パワーマネージャーに `AccessDenied` を返していた。

以前修正した `brightness-switch` 問題（`xfconf-query` で値を 0 に設定）と同系統。

### 修正手順

#### 1. UPower 設定ファイルを編集

```bash
sudo nano /etc/UPower/UPower.conf
```

以下の行を変更：

```
# 変更前
IgnoreLid=false

# 変更後
IgnoreLid=true
```

#### 2. UPower を再起動

```bash
sudo systemctl restart upower
```

#### 3. 動作確認

蓋を閉じて警告が出ないことを確認する。

### 追記：UPower の IgnoreLid=true では解決せず

`/etc/UPower/UPower.conf` の `IgnoreLid=true` ＋ `sudo systemctl restart upower` を試みたが警告は継続。

真の原因は **Xfce パワーマネージャーが自分で蓋閉じを処理しようとして DBus の権限エラーになっていた**こと。

#### 実際の修正コマンド

```bash
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -s 0
```

変更前の値：
- `lid-action-on-ac` : 2
- `lid-action-on-battery` : 1

変更後の値：
- `lid-action-on-ac` : 0（AC接続時＝自宅クラムシェル運用で何もしない）
- `lid-action-on-battery` : 0（一時的）→ その後 1 に戻す

#### 最終設定値

外出時バッテリー駆動で蓋閉じサスペンドが必要なため `lid-action-on-battery` を 1 に戻した：

```bash
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -s 1
```

| キー | 値 | 意味 |
|---|---|---|
| `lid-action-on-ac` | 0 | AC接続時：何もしない（自宅クラムシェル） |
| `lid-action-on-battery` | 1 | バッテリー時：サスペンド（外出時） |

### 状態

- [x] 原因特定
- [x] 修正適用
- [x] 動作確認（警告消滅を確認）

---
*2026-03-22 解決*

---

## 2026-03-21

# CHANGELOG-20260321

## Thunderbird: ExtEditorR アドオン修復 ✅

- **原因:** Debian 12 の GLIBC 2.36 では v1.2.0 バイナリが動かない（GLIBC 2.39 必要）
- **対処:**
  - バイナリは v1.1.0 のまま（`~/Dropbox/backup/thunderbird/addons/external-editor-revived`）
  - xpi（拡張機能）は v1.2.0 のまま
  - アドオン設定の **Bypass version check** にチェックを入れて Apply
- **備考:** Debian 13（GLIBC 2.40）に上げれば v1.2.0 バイナリも動くようになる

---

## Thunderbird: アドレス帳復元 ✅

- **原因:** Thunderbird 設定整理の過程で `abook.sqlite` の中身が空になった
  - スキーマ（`list_cards` / `lists` / `properties`）は残っていたがデータが0件
- **復元手順:**
  1. ゴミ箱に複数の `abook.sqlite` が存在することを確認
     ```bash
     find ~/.local/share/Trash -name "abook*" 2>/dev/null
     ```
  2. `Mail` ディレクトリ由来のファイルに 131KB の WAL が残っていた（3月11日付け）
  3. WAL をマージして 381件のデータを確認・復元
     ```bash
     cp ~/.local/share/Trash/files/Mail/.thunderbird/r5oy09ua.default-default/abook.sqlite /tmp/abook_recovery.sqlite
     cp ~/.local/share/Trash/files/Mail/.thunderbird/r5oy09ua.default-default/abook.sqlite-wal /tmp/abook_recovery.sqlite-wal
     sqlite3 /tmp/abook_recovery.sqlite "PRAGMA wal_checkpoint(FULL);"
     sqlite3 /tmp/abook_recovery.sqlite "SELECT COUNT(*) FROM properties;"  # → 381
     cp ~/.thunderbird/r5oy09ua.default-default/abook.sqlite ~/.thunderbird/r5oy09ua.default-default/abook.sqlite.bak
     cp /tmp/abook_recovery.sqlite ~/.thunderbird/r5oy09ua.default-default/abook.sqlite
     ```
- **備考:** 復元データは3月11日時点のもの。それ以降に追加した連絡先は失われている可能性あり
- **備考:** 現行Thunderbirdのアドレス帳スキーマは `cards` ではなく `list_cards` / `lists` / `properties` を使用。古いコマンド（`SELECT COUNT(*) FROM cards;`）はエラーになるので注意

---

## mozc: バックアップ方式変更に伴う rsync 統一 ✅

P1 の `~/.mozc` 管理を Dropbox シンボリックリンクから実ディレクトリ＋毎晩バックアップ方式に変更したことに伴い、mozc リストア処理を `cp -rf` から `rsync` に統一。

**`~/.autostart.sh`（X250 起動時のリストア処理）**
```bash
# 変更後
rsync -av --delete ~/Dropbox/backup/mozc/.mozc/ ~/.mozc/
```

**`~/Dropbox/makefile`（`emacs-mozc` ターゲット）**
```makefile
# 変更後
rsync -av --delete ~/Dropbox/backup/mozc/.mozc/ ~/.mozc/
```

---

## Docker: 全データを ~/Dropbox/backup/ に統一移行 ✅

### 移行内容
- `~/docker-data/mattermost/` → `~/Dropbox/backup/mattermost/`
- `~/Dropbox/docker-data/gitea/` → `~/Dropbox/backup/gitea/`
- `~/docker-data/` および `~/Dropbox/docker-data/` を廃止

### データ構成（移行後）
```
~/Dropbox/backup/mattermost/
  config/   # コンテナマウント
  data/     # コンテナマウント
  logs/     # コンテナマウント
  plugins/  # コンテナマウント
  db/       # postgres データ
  *.tar.gz  # config+data バックアップ（7世代）
  *.sql     # pg_dump バックアップ（7世代）

~/Dropbox/backup/gitea/
  git/
  gitea/
  ssh/
```

### トラブルと解決
- **Gitea が初期化** → `sudo rm -rf ~/Dropbox/docker-data` 実行後に発覚。Dropbox のバージョン履歴から復元成功
- **Mattermost が初期画面** → DBが初期化されていた。`mattermost_20260321.sql` からリストアして復元成功

### Mattermost リストア手順（重要）
> ⚠️ Mattermost が起動した状態でリストアするとテーブルが重複してデータが復元されない。
> 必ず postgres だけ起動した状態でリストアすること。

```bash
cd ~/src/github.com/minorugh/dotfiles/docker/mattermost
docker compose stop mattermost
docker compose stop postgres
sudo rm -rf ~/Dropbox/backup/mattermost/db
docker compose up -d postgres
sleep 10
docker exec -i mattermost-postgres psql -U mattermost mattermost \
  < ~/Dropbox/backup/mattermost/mattermost_YYYYMMDD.sql
docker compose up -d mattermost
```

---

## README 各種更新 ✅

| ファイル | 内容 |
|---|---|
| `dotfiles/README.md` | ターゲット一覧を実態に合わせて更新、cron セクション追加 |
| `~/Dropbox/README.md` | makefile ターゲットを git-push 方式に更新 |
| `dotfiles/docker/README.md` | データパスを backup/ に統一、リストア手順を加筆 |
| `dotfiles/cron/README.md` | autobackup の内容・スクリプト名を実態に合わせて修正 |
| `~/Dropbox/passwd/README.md` | mergepasswd.pl のパス修正、保持期間統一 |


## Docker Mattermost 起動失敗問題の修正

### 症状
PC再起動時に `mattermost` コンテナが `Restarting (1)` 状態になり、
ブラウザで `localhost:8065` に接続できない（ERR_CONNECTION_REFUSED）。
`docker down → up` で復旧することもあるが不安定。

### 原因
PostgreSQL が完全に起動する前に Mattermost が DB 接続を試みてクラッシュループに入る。
`depends_on: condition: service_healthy` だけでは不十分で、
`pg_isready` が応答しても実際の接続受付までにタイムラグがある。

### 修正内容（docker-compose.yml）

**postgres サービス:**
- `healthcheck.test` を `pg_isready -U mattermost -d mattermost` に強化（DB名も指定）
- `healthcheck.interval` を `5s → 10s` に変更
- `healthcheck.retries` を `5 → 10` に増加
- `healthcheck.start_period: 30s` を追加（起動直後の猶予時間）
- `restart: always → unless-stopped` に変更

**mattermost サービス:**
- DSN に `connect_timeout=10` を追加
- `restart: always → unless-stopped` に変更

今日の修正まとめ：

原因: ~/Dropbox/backup/mattermost/config/config.json が 644 でコンテナから書き込み不可
修正: chmod 664 config.json
healthcheckやDB待機は関係なかった


### 未解決課題
`~/Dropbox/backup/mattermost/db` を Dropbox 同期対象から外すことを推奨。
PostgreSQL のデータファイルを Dropbox で同期すると DB 破損リスクがある。
`~/.local/share/mattermost/db` などローカルパスへの移行を検討すること。

---

## 2026-03-19

# CHANGELOG-20260319

## Mattermost Docker セットアップ完了

### DBバックアップ設定
- `dotfiles/cron/mattermost-backup.sh` 新規作成
  - pg_dump → `~/Dropbox/docker-data/mattermost/backup/` に保存
  - 7日以上古いファイルは自動削除、backup.log に成否記録
  - コンテナ未起動時は空ファイル生成を防ぐ起動確認処理を追加
  - crontab 側 `>> /tmp/cron.log 2>&1` でログ統一（automerge・autobackup と同仕様）
- `dotfiles/Makefile` の `autobackup` ターゲットに `mattermost-backup.sh` のシンボリックリンク追加
- `dotfiles/cron/crontab` に毎日午前3時のエントリ追加
- `docker/Makefile` に `mattermost-backup` ターゲット追加（手動実行・ログ末尾表示）
- 動作確認済み：mattermost_20260319_104505.sql (171KB) 生成

### automerge.sh ログ統一
- `/tmp/automerge.log` への出力を廃止、`/tmp/cron.log` に統一
- crontab の automerge 行はすでに `>> /tmp/cron.log 2>&1` だったので変更なし
- スクリプト内の `>> $LOGFILE` を `echo` に変更（crontab リダイレクトに任せる）

### 不具合修正：コンテナ unhealthy 問題
- 原因：`~/Dropbox/docker-data/mattermost/data/` のオーナーが `minoru` のまま
  - `permission denied: open data/testfile` でヘルスチェック失敗
- 対処：`sudo chown -R 2000:2000 .../data` で解決
- 再発防止：`docker/Makefile` の `mattermost` ターゲットに `db/` の chown も追加
  ```makefile
  sudo chown -R 2000:2000 ~/Dropbox/docker-data/mattermost
  sudo chown -R 2000:2000 ~/.local/share/mattermost/db
  ```

### スマホアクセス確認
- 運用方針：P1 単機運用、自宅WiFi内のみ（v6プラスのためポート開放不可）
- Pixel 8 Mattermost アプリから `http://192.168.10.109:8065` でログイン確認
- 用途：スマホ↔PC 間のクリップボード代わり
- Gmail SMTP 経由メール送信：確認済み（me-bot サブアドレス宛）
- 通知：HTTP 運用のため未対応（現状許容）

### sudo NOPASSWD 設定
- Docker 起動時の polkit 認証ダイアログを抑制
- 原因：`make mattermost` 内の `sudo chown` が GUI 経由でパスワード要求
- 対処：`/etc/sudoers` に `minoru ALL=(ALL:ALL) NOPASSWD: ALL` を設定

### .zshrc 整理
- `setxkbmap` / `xmodmap` 呼び出しを削除（`.xprofile` に任せる）
- `RPROMPT` の重複定義を統合
- `precmd` の重複を解消、`case` ブロックに統合
- `setopt` の重複（`hist_reduce_blanks`、`hist_no_store`、`list_packed`）を削除
- `myip` のインターフェース名ハードコードを修正
- docker-compose エイリアスを削除（`docker/Makefile` で管理）
- `github-new`（`hub` 依存）、`get-github-api` 関数を削除
- PATH を History の直後に移動（早期定義）
- セクションを見出しで整理

### Linuxbrew → Hugo .deb 移行
- brew 経由の hugo を削除、GitHub releases の `.deb` に移行
  - `hugo_extended_0.147.0_linux-amd64.deb` をインストール
  - 動作確認済み：`hugo v0.147.0+extended`
- Linuxbrew 本体をアンインストール（`/home/linuxbrew` 削除）
- `.zshrc` の Linuxbrew PATH を削除
- `dotfiles/Makefile` に `hugo` インストールターゲット追加

### ドキュメント整備
- `dotfiles/docker/README.md` 新規作成（構築手順・注意点・リストア手順を記載）

## polkit認証ダイアログ抑制

### 背景
- Docker起動時（PC再起動後の `make mattermost` 初回など）にGUI認証ダイアログが出るようになった
- `make mattermost` 内の `sudo chown` がトリガー
- sudoersの `NOPASSWD: ALL` 設定済みだが効かない → polkitとsudoは別物

### 対処
`/etc/polkit-1/rules.d/49-nopasswd-docker.rules` を作成：

​```javascript
polkit.addRule(function(action, subject) {
    if ((action.id.indexOf("com.docker") === 0 ||
         action.id.indexOf("org.freedesktop.systemd1") === 0) &&
        subject.user === "minoru") {
        return polkit.Result.YES;
    }
});
​```
```bash
sudo systemctl restart polkit
```

### 動作確認済み
- `make down && make mattermost` で問題なし

### 全許可版に更新・動作確認済み
- `/etc/polkit-1/rules.d/49-nopasswd-docker.rules` を全許可版に更新

```javascript
polkit.addRule(function(action, subject) {
    if (subject.user === "minoru") {
        return polkit.Result.YES;
    }
});
```

- `sudo systemctl restart polkit` 実施済み
- PC再起動後の `make mattermost` でダイアログが出ないことを確認 ✓
- `dotfiles/Makefile` に `polkit` ターゲット追加、`docker-setup` の依存に組み込み済み

---

## 2026-03-17

# Docker 開発環境構築ログ
date: 2026-03-17〜18
author: Minoru Yamada

---

## 概要

ローカルDocker環境として以下の3サービスを構築・動作確認した。

- **Gitea**（ポート3000）: セルフホスト型Gitサーバー。ブラウザでリポジトリ閲覧、push/pullはmagitから行う運用。
- **Mattermost**（ポート8065）: セルフホスト型チャット。changelog管理・メモ用途（外部公開なし）。
- **Apache httpd**（ポート8080）: ローカルでのCGIサイト動作確認用。xserverへのアップ前テスト環境。

---

## ディレクトリ構成

```
dotfiles/
├── Makefile                  # 環境リストア専用（Docker起動停止は含まない）
└── docker/
    ├── Makefile              # Docker管理専用
    ├── gitea/
    │   └── docker-compose.yml
    ├── mattermost/
    │   └── docker-compose.yml
    └── httpd/
        ├── docker-compose.yml
        ├── httpd.conf
        └── vhosts.conf

~/Dropbox/
├── docker-data/
│   └── mattermost/           # Mattermostデータ永続化
├── GH/                       # gh.local:8080 のドキュメントルート
└── minorugh.com/             # minorugh.local:8080 のドキュメントルート
```

---

## 完了した作業

### 1. Gitea 構築

- `docker-compose.yml` で構築
- `http://localhost:3000` でブラウザ確認済み
- 管理者アカウント作成・サイト管理パネル確認済み

### 2. Mattermost 構築

- `docker-compose.yml` で構築
- `http://localhost:8065` でブラウザ確認済み
- データディレクトリは `~/Dropbox/docker-data/mattermost/` に配置
- 起動前に `sudo chown -R 2000:2000` が必要（Makefileに組み込み済み）

### 3. Apache httpd 構築

設定ファイル3点を作成:

| ファイル | 役割 |
|---|---|
| `docker/httpd/docker-compose.yml` | コンテナ定義 |
| `docker/httpd/httpd.conf` | Apache本体設定 |
| `docker/httpd/vhosts.conf` | バーチャルホスト設定 |

VirtualHost設定:

| URL | ドキュメントルート |
|---|---|
| `http://minorugh.local:8080` | `~/Dropbox/minorugh.com` |
| `http://gh.local:8080` | `~/Dropbox/GH` |

`/etc/hosts` に追加:

```
127.0.0.1 minorugh.local
127.0.0.1 gh.local
```

両サイトのブラウザ表示確認済み。

### 4. CGI動作確認・トラブル対応

#### パーミッション設定

```bash
find ~/Dropbox/GH -name "*.cgi" -o -name "*.pl" | xargs chmod 755
find ~/Dropbox/GH -type d | xargs chmod 755
```

#### Perlパス修正

xserverでは `/usr/local/bin/perl` だが、Dockerコンテナ内は `/usr/bin/perl`。
CGIファイル1行目を修正:

```perl
#!/usr/bin/perl
```

コンテナ内のPerlパス確認方法:

```bash
docker exec httpd which perl
# → /usr/bin/perl
```

#### CGI.pm モジュールのインストール

Dockerコンテナ内にCGI.pmが入っていないため手動インストール:

```bash
docker exec httpd apt-get update && docker exec httpd apt-get install -y libcgi-pm-perl
```

> ~~コンテナを再作成するたびに再インストールが必要。~~
> → **Dockerfileで自動化済み**（後述）。

### 5. Gitea へのリポジトリ追加

Giteaはブラウザ（`localhost:3000`）でファイル閲覧・履歴確認・旧バージョンDL。
push/pullはmagitから行う。GiteaのWebUIで直接操作はしない運用。

#### 手順

```
1. http://localhost:3000 でリポジトリ作成
   - 「リポジトリの初期設定」チェックなし（空リポジトリ）

2. ローカルでremote追加
   git remote add gitea http://localhost:3000/minoru/リポジトリ名.git

3. 初回push
   git push gitea main
   （ユーザー名: minoru、パスワード: Giteaのパスワード）

4. ブラウザで確認
   http://localhost:3000/minoru/リポジトリ名
```

#### 追加済みリポジトリ

- `GH`
- `minorugh.com`
- `dotfiles`

#### remote URLの確認・修正

```bash
cd ~/Dropbox/GH
git remote -v
# URLが違う場合は修正
git remote set-url gitea http://localhost:3000/minoru/リポジトリ名.git
```

### 6. Makefile 整理

Docker起動停止コマンドがリストア専用の `dotfiles/Makefile` に混在していたため分離。

| ファイル | 役割 |
|---|---|
| `dotfiles/Makefile` | 環境リストア専用。`docker-install` / `docker-setup` ターゲットを追加 |
| `dotfiles/docker/Makefile` | Docker起動停止管理専用。`$(PWD)` を使用して実行場所に依存しない設計 |

#### 新規マシンへのDocker環境セットアップ手順

```bash
# 1. dotfilesをclone
git clone git@github.com:minorugh/dotfiles.git /home/minoru/src/github.com/minorugh/dotfiles
cd /home/minoru/src/github.com/minorugh/dotfiles

# 2. Docker本体インストール（公式リポジトリ経由）
make docker-install
# → ログアウト→再ログインしてグループ反映

# 3. データディレクトリ作成
make docker-setup

# 4. 各サービス起動
cd docker
make docker-start
```

#### docker/Makefile の主要ターゲット

```bash
make gitea          # Gitea 起動
make gitea-down     # Gitea 停止
make mattermost     # Mattermost 起動
make httpd          # httpd 起動
make docker-start   # 全サービス起動
make docker-stop    # 全サービス停止
make docker-ps      # 起動中コンテナ一覧
```

### 7. Dockerfile 作成（CGI.pm自動化）

`docker/httpd/Dockerfile` を作成:

```dockerfile
FROM httpd:2.4
RUN apt-get update && apt-get install -y libcgi-pm-perl && rm -rf /var/lib/apt/lists/*
```

`docker-compose.yml` の `image: httpd:2.4` を `build: .` に変更。
反映手順:

```bash
cd /home/minoru/src/github.com/minorugh/dotfiles/docker/httpd
docker compose down
docker compose up -d --build
```

動作確認済み。コンテナ再作成後もCGI.pmが自動インストールされる。

---

## 次回の作業予定

### 1. CGI絶対パス問題への対応

既存CGIが本番URLで絶対パス指定している場合、ローカルテスト時に本番サーバーへ影響する可能性がある。対応方針:

- 書き込み系CGIはローカルでは動かさない運用
- または `$ENV{HTTP_HOST}` で本番/ローカルを判定する方法を検討

### 2. 03-docker-setup.md の更新

今回の作業内容をドキュメントに反映する。

---

## サブ機（X250）への展開メモ

新規マシンへの展開は上記「新規マシンへのDocker環境セットアップ手順」の通り。
`dotfiles/Makefile` の `docker-install` → `docker-setup` → `docker/Makefile` の `docker-start` の順で完結する。

dotfilesのフルパス: `/home/minoru/src/github.com/minorugh/dotfiles`


## .netrc の作成と git-crypt 対応手順

### 1. Giteaのパスワード省略 → .netrc に登録
echo "machine localhost login minoru password <Giteaのパスワード>" >> ~/.netrc
chmod 600 ~/.netrc

### 2. magitから両方に自動push → originに複数push先を登録
cd ~/src/github.com/minorugh/dotfiles
git remote set-url --add --push origin git@github.com:minorugh/dotfiles.git
git remote set-url --add --push origin http://localhost:3000/minoru/dotfiles.git

# git push origin main 一発でGitHubとGiteaの両方に飛ぶ
# magitの P p も同じ動作になる
# 他のリポジトリ（GH、minorugh.com）も同様に設定する

### 3. .gitattributes に追加（push前に必ず実施）
echo ".netrc filter=git-crypt diff=git-crypt" >> .gitattributes

### 4. .netrc を dotfiles に配置してシンボリックリンク
cp ~/.netrc ~/src/github.com/minorugh/dotfiles/.netrc
# Makefile の init ターゲットの for item に netrc を追加
for item in xprofile gitconfig bashrc zshrc vimrc tmux.conf Xresources textlintrc aspell.conf netrc; do
    ln -vsf {${PWD},${HOME}}/.$$item
done

### 5. 暗号化確認してpush
git-crypt status    # .netrc が encrypted になっていることを確認
git add .gitattributes .netrc
git commit -m "add: .netrc with git-crypt encryption"
git push

### ⚠️ 注意
# git push前に必ず git-crypt status で encrypted を確認すること
# encrypted になっていない状態でpushするとパスワードが平文でGitHubに上がる

---

## 2026-03-16

# 2026-03-16 - ThinkPad / Xmodmap 調整

## 目的
- CapsLock を Control として使用
- PrtSc キーを Right Alt として利用
- Ctrl_R + PrtSc で PrintScreen を維持
- 既存の WM ショートカット (Ctrl_R + → ← / PgUp PgDn) を壊さない
- Emacs の既存 keybind は変更せずに執筆環境向けに最適化

## 修正内容

1. **modifier の破壊を防止**
   - 以前の設定にあった `clear Control`、`clear Mod1`、`clear Mod4` を削除
   - WM が使用する modifier を消さないことで、ショートカットを維持

2. **CapsLock → Control_L**
   ```bash
   clear Lock
   keycode 66 = Control_L
   add Control = Control_L
```
  - Lock modifier を解除したうえで Control として再登録
  - Caps → Ctrl の挙動が安定

3. ThinkPad PrtSc キーを Alt_R 化

``` bash
  keycode 107 = Alt_R Meta_R Print Sys_Req
```
- 通常: Alt_R
- Shift + PrtSc: Meta_R
- Ctrl_R + PrtSc: Print (スクリーンショット用)
- Ctrl_R + Shift + PrtSc: Sys_Req
- これで WM ショートカットやスクリーンショットが両立

4. Alt modifier 安定化

``` bash
remove Mod1 = Alt_R
add Mod1 = Alt_R
```
- Alt_R を追加した場合、Mod1 が壊れることがあるため再登録
- ThinkPad + xmodmap でよく使う安全策

5. 日本語キーボード対応

``` bash
keycode 97 = underscore backslash underscore backslash
```

- JPキーボードの「ろ」キーを _ / \ に割り当て
- 執筆や Emacs 利用で扱いやすく

6. テンキーを常時数字化

``` bash
keycode 87 = 1
keycode 88 = 2
keycode 89 = 3
keycode 83 = 4
keycode 84 = 5
keycode 85 = 6
keycode 79 = 7
keycode 80 = 8
keycode 81 = 9
keycode 90 = 0
keycode 91 = period
```

- NumLock を使わず常に数字入力可能
- 執筆用テンキー活用のため安定化

## 結果


- Caps → Ctrl 動作正常
- PrtSc → Alt_R として利用可能
- Ctrl_R + PrtSc → PrintScreen 動作
- WM の Ctrl_R + → ← / PgUp PgDn ショートカット正常
- Emacs の既存 keybind は壊さず維持

## テスト手順

``` bash
# Xmodmap 適用
xmodmap ~/.Xmodmap

# modifier 状態確認
xmodmap -pm

# キー挙動確認
xev

```

## 備考

- ThinkPad 特有の keycode 107 (PrtSc) を活かした設計
- 今後の拡張や他キーボードでの再現も容易
- Reason: ThinkPad keyboard optimization for writing workflow
- Impact: No change to existing Emacs keybindings

---

## 2026-03-14

# 2026-03-14

## ~/Dropbox/makefile

- `dotfiles` / `gh` ターゲットの `--link-dest` をシングルクォート内バッククォートから変数展開（`$$PREV`）方式に修正
  - シングルクォート内ではバッククォートがシェル展開されないバグを解消
- cron 環境での SSH 認証失敗（`Permission denied (publickey)`）に対応
  - 各ターゲット冒頭で `keychain --noask --quiet --eval` をロードする行を追加
- `dotfiles` / `gh` の Xserver 側バックアップに 90 日超ディレクトリの自動削除を追加
  - `ssh xsrv` のコマンドブロック末尾に `find ... -mtime +90 -exec rm -rf {} +` を追記

---

## 2026-03-13

# Changelog 2026-03-13

## 電源管理：ハイバネーション警告の調査と対処

### 症状
GNOME デスクトップ通知（右上ポップアップ）に以下の警告が頻繁に表示される。

```
GDBus.Error:org.freedesktop.login1.SleepVerNotSupported:
Not enough swap space for hibernation
```

### 環境
- Machine: P1 (ThinkPad)
- OS: Debian 12
- RAM: 30GB / Swap: 約1GB（/dev/nvme1n1p3）

### 調査結果

**原因の特定**

`upower --dump` にて以下を確認：

```
critical-action: HybridSleep
```

UPower のバッテリー残量低下時アクションが `HybridSleep` に設定されており、
systemd-logind がスワップ不足チェックを行って通知を出していた。

**補足事項**

- `/sys/power/disk` に `hibernate` エントリなし → カーネルレベルでハイバネート無効
- バッテリー状態は正常（99%、fully-charged）
- freerdp2-x11（リモートデスクトップ）は本件と無関係
- `/etc/UPower/UPower.conf` の `CriticalPowerAction=Suspend` 変更は
  UPower 0.99.20 では反映されないことを確認（設定ファイルを無視する挙動）

### 対処

ハイバネート関連の systemd ターゲットをマスク：

```bash
sudo systemctl mask hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

結果：

```
Created symlink /etc/systemd/system/hibernate.target → /dev/null
Created symlink /etc/systemd/system/hybrid-sleep.target → /dev/null
Created symlink /etc/systemd/system/suspend-then-hibernate.target → /dev/null
```

### 後始末（要実施）

```bash
sudo rm /etc/UPower.conf
sudo rm -rf /etc/systemd/system/upower.service.d
sudo systemctl daemon-reload
```

### 備考

- UPower 0.99.20（Debian 12）は設定ファイルより動的なカーネル応答を優先する模様
- Debian 13 クリーンインストール時に根本的に解消予定

---

## Thunderbird 設定管理

### 現状把握

**プロファイル構成**

```
~/.thunderbird/                          # Thunderbird 参照先
    profiles.ini / installs.ini
    r5oy09ua.default-default/           # 実使用プロファイル
        prefs.js                        # メイン設定ファイル
        cert9.db / key4.db / logins.json
        ImapMail/                       # ヘッダーキャッシュ（実体は下記）

~/thunderbird/.thunderbird/             # 実体（2.6GB）
    r5oy09ua.default-default/
        ImapMail/                       # Gmail IMAP キャッシュ本体
```

### 対処1：prefs.js のパス修正

`prefs.js` が古い Dropbox パスを参照したままになっていたため修正：

```bash
cp ~/.thunderbird/r5oy09ua.default-default/prefs.js \
   ~/.thunderbird/r5oy09ua.default-default/prefs.js.bak

sed -i 's|/home/minoru/Dropbox/thunderbird/.thunderbird|/home/minoru/thunderbird/.thunderbird|g' \
    ~/.thunderbird/r5oy09ua.default-default/prefs.js

sed -i 's|\[ProfD\]../../Dropbox/thunderbird/.thunderbird/r5oy09ua.default-default/ImapMail/imap.gmail.com|\[ProfD\]../../thunderbird/.thunderbird/r5oy09ua.default-default/ImapMail/imap.gmail.com|g' \
    ~/.thunderbird/r5oy09ua.default-default/prefs.js
```

Thunderbird 再起動で正常動作を確認。

### 対処2：設定ファイルを Dropbox/backup へ移動して symlink 展開

**役割分担**

```
~/Dropbox/backup/thunderbird/    # 動くファイル（実体）
    profiles.ini
    installs.ini
    prefs.js
    cert9.db
    key4.db
    logins.json

~/thunderbird/.thunderbird/      # キャッシュ類（バックアップ不要・Gmail から再同期）
    r5oy09ua.default-default/
        ImapMail/
```

**実施手順**

```bash
mkdir -p ~/Dropbox/backup/thunderbird
PROF=~/.thunderbird/r5oy09ua.default-default
cp ~/.thunderbird/profiles.ini ~/Dropbox/backup/thunderbird/
cp ~/.thunderbird/installs.ini ~/Dropbox/backup/thunderbird/
cp $PROF/prefs.js $PROF/cert9.db $PROF/key4.db $PROF/logins.json \
   ~/Dropbox/backup/thunderbird/

# symlink に置き換え
TBIRD=~/Dropbox/backup/thunderbird
ln -vsf $TBIRD/profiles.ini ~/.thunderbird/profiles.ini
ln -vsf $TBIRD/installs.ini ~/.thunderbird/installs.ini
for item in prefs.js cert9.db key4.db logins.json; do
    ln -vsf $TBIRD/$item $PROF/$item
done
```

Thunderbird 再起動で正常動作を確認。

旧バックアップはリネームして保持：

```bash
mv ~/Dropbox/thunderbird ~/Dropbox/thunderbird.bak
```

### 対処3：Makefile の thunderbird: ターゲット更新

```makefile
thunderbird: ## Thunderbird の設定（Gmail はアプリパスワードで認証）
# サブ機など既存インストールがある場合は事前に手動で削除すること
# | sudo apt remove --purge thunderbird && rm -rf ~/.thunderbird
	$(APT) $@
	mkdir -p ${HOME}/.thunderbird/r5oy09ua.default-default
	$(eval TBIRD := ${HOME}/Dropbox/backup/thunderbird)
	$(eval PROF  := ${HOME}/.thunderbird/r5oy09ua.default-default)
	ln -vsf ${TBIRD}/profiles.ini ${HOME}/.thunderbird/profiles.ini
	ln -vsf ${TBIRD}/installs.ini ${HOME}/.thunderbird/installs.ini
	for item in prefs.js cert9.db key4.db logins.json; do \
		ln -vsf ${TBIRD}/$$item ${PROF}/$$item; \
	done
	sudo ln -vsfn ${HOME}/thunderbird/external-editor-revived /usr/local/bin
	sudo chmod +x /usr/local/bin/external-editor-revived
```

### 設計上の決定事項

- `ImapMail/`（2.6GB）の Xserver バックアップは不要と判断
  → Gmail が正本、リストア後は Thunderbird が自動再同期する
  → neomutt も同じ概念で運用中
- 設定ファイルは Dropbox/backup 管理で十分

---

## 2026-03-12

# CHANGELOG 2026-03-12

## 目次
<div class="toc">
  - [追加した動作](#追加した動作)
  - [結果のフォルダ構成](#結果のフォルダ構成)
  - [備考](#備考)
  - [GPG_README.md 新規作成](#gpg_readme.md-新規作成)
    - [内容](#内容)
  - [gpgimport Makefile — 作業ディレクトリ変更](#gpgimport-makefile—作業ディレクトリ変更)
  - [mymw.pl — 新規作成・機能拡張・動作確認済み](#mymw.pl—新規作成・機能拡張・動作確認済み)
    - [概要](#概要)
    - [処理の流れ](#処理の流れ)
    - [エンジン切り替え](#エンジン切り替え)
    - [Makefile 組み込み（rule.mak の .txt.html: を置き換え）](#makefile-組み込みrule.mak-の.txt.html:を置き換え)
    - [セパレータ行（|---|行）の記法](#セパレータ行|---|行の記法)
    - [使用例](#使用例)
    - [変更履歴](#変更履歴)
  - [mymw.pl — div ブロック変換追加](#mymw.pl—div-ブロック変換追加)
    - [追加機能](#追加機能)
    - [判明した制約](#判明した制約)
    - [トラブルシューティング経緯](#トラブルシューティング経緯)
    - [更新ファイル](#更新ファイル)
  - [mymwref.md — クイックリファレンス更新](#mymwref.md—クイックリファレンス更新)
    - [変更内容（午前）](#変更内容午前)
    - [変更内容（午後）](#変更内容午後)
  - [~/Dropbox/backup/README.md — 新規作成](#~/dropbox/backup/readme.md—新規作成)
    - [対象フォルダー](#対象フォルダー)
    - [備考](#備考)
  - [~/Dropbox/README.md — 新規作成](#~/dropbox/readme.md—新規作成)
    - [内容](#内容)
  - [~/Dropbox/makefile — 更新](#~/dropbox/makefile—更新)
    - [変更内容](#変更内容)
    - [cron追加](#cron追加)
  - [~/src/github.com/minorugh/dotfiles/cron/README.md — 改訂](#~/src/github.com/minorugh/dotfiles/cron/readme.md—改訂)
    - [変更内容](#変更内容)
</div>




## mkindex.pl — 月別アーカイブ機能追加

### 追加した動作
1. 当月分だけで INDEX.md を更新
2. 先月以前の CHANGELOG-*.md があれば `archive/YYYY/MM/` に INDEX.md を生成してから移動
3. 移動後に当月の INDEX.md を再更新

### 結果のフォルダ構成
```
~/Dropbox/backup/changelog/
├── INDEX.md               ← 当月分のみ
├── mkindex.pl
├── CHANGELOG-20260312.md
└── archive/
    └── 2026/
        └── 03/
            ├── INDEX.md
            ├── CHANGELOG-20260304.md
            └── ...
```

### 備考
当月分しかないため動作未確認。来月になったら試す。

---

## GPG_README.md 新規作成

`~/Dropbox/backup/gnupg/GPG_README.md` として設置。

### 内容
- 登場人物の整理（GPG秘密鍵・secret-all.key・git-crypt・SSH秘密鍵）
- GPG秘密鍵と gita-crypt の関係（別物。パスフレーズ共有は運用上の選択）
- secret-all.key のインポートが必要な理由（git-crypt unlock のため。将来のメンテ用だけではない）
- `~/.gnupg/` を dotfiles で管理しない理由（鶏と卵になるため。現状の方針が正解）
- GPG秘密鍵と SSH秘密鍵の違い
- パスフレーズの管理（KeePassXC が最終バックアップ）

---

## gpgimport Makefile — 作業ディレクトリ変更

`~/backup` → `/tmp/gpgwork` に変更。
`/tmp` は再起動時に自動削除されるため作業後のクリーンアップが不要で安全。
`gpg`・`export`・`delete` の3ターゲット全部に適用。
README.md への影響なし。

---

## mymw.pl — 新規作成・機能拡張・動作確認済み

`~/Dropbox/GH/makeweb/mymw.pl` として設置（旧名 `my:mw.pl` から改名）。

### 概要
makeweb.pl の前処理ラッパー。`-table( ... -table)` ブロックを HTML テーブルに
変換してから makeweb エンジンに渡す。makeweb.pl 本体は無改造のまま使える。

### 処理の流れ
```
input.txt → mymw.pl（pretable変換）→ 一時ファイル → makeweb.pl → output.html
```

### エンジン切り替え
冒頭の1行だけ変更:
```perl
my $MAKEWEB_ENGINE = 'makeweb.pl';   # 標準
my $MAKEWEB_ENGINE = 'mw4diary.pl';  # 日記用
my $MAKEWEB_ENGINE = 'mw4ap.pl';     # AP用
```
mymw.pl と同じディレクトリに置けばどこでも使い回し可能。

### Makefile 組み込み（rule.mak の .txt.html: を置き換え）
```makefile
.txt.html:
	perl ~/Dropbox/GH/makeweb/mymw.pl $< $@
```

### セパレータ行（|---|行）の記法
| セパレータ | 意味 |
|---|---|
| `\|---\|` | td、左寄せ（デフォルト。`\|--\|` や `\|----\|` も可） |
| `\|<---\|` | td、左寄せ |
| `\|<--->\|` | td、中央寄せ |
| `\|--->\|` | td、右寄せ |
| `\|---n\|` | td、左寄せ + nowrap |
| `\|<---n\|` | td、左寄せ + nowrap |
| `\|TH\|` | th（縦ヘッダ列）、左寄せ |
| `\|TH<---\|` | th、左寄せ |
| `\|TH<--->\|` | th、中央寄せ |
| `\|TH--->\|` | th、右寄せ |
| `\|TH---n\|` | th、左寄せ + nowrap |

- `-` の数は1個以上であれば何個でも可
- `|---|` 行の直上行が `<thead><tr>...</tr></thead>` として出力される
- アライメントは `style="text-align:..."` で出力
- nowrap は `style="white-space:nowrap"` で出力（アライメントと併記時は `;` で連結）

### 使用例
```
-table(id="result"
|作品|作者|点|選者|
|TH<---|<---|<--->|<---|
|春の海|みのる|7|むべ.藤井.うつぎ.|
-table)
```
→ 作品列が縦ヘッダ(th)左寄せ、点列が中央寄せ、先頭行が `<thead>` で囲まれる。

### 変更履歴
- `my:makeweb.pl` → `my:mw.pl` → `mymw.pl` と改名
- 縦ヘッダ列指定（`TH` プレフィックス）追加
- アライメント指定（`<---` / `<--->` / `--->`）追加
- `|---|` デフォルト左寄せ
- セパレータ直上行を `<thead>` で囲む
- nowrap 指定（末尾 `n`）追加、`style="white-space:nowrap"` で出力
- `-` の数は何個でも可（`|--|` も `|------|` も同じ意味）
- mw4diary.pl での実運転確認済み

---

## mymw.pl — div ブロック変換追加

### 追加機能
- `=TAG< ... =TAG>` → `<div class="TAG"> ... </div>` に変換
  - makeweb の `=mycommand< ... =mycommand>` 書式を応用
  - 追加属性も指定可能: `=box<id="main"` → `<div class="box" id="main">`
  - 閉じタグは必ず `=TAG>`（`=>` は makeweb が処理するので不可）

### 判明した制約
- `-table(` および `=TAG<` は makeweb の `-( ... -)` ブロックの外に書くこと
  - 回避策: `-)` で一度閉じてから `-table(` / `=TAG<` を書く
- ネスト非対応（`=TAG<` の中に `-table(` は入れられない）
- `=TAG< ... =TAG>` の閉じ忘れ対策は未解決
  - 候補: yasnippet でペアを一括挿入、makeweb 外部定義で対処

### トラブルシューティング経緯
1. `-div(class="navi"` 書式を試みたが、makeweb が `-div` を
   未定義コマンド（`-div_pbegin`）として解釈してエラー
2. mw4diary.pl の HTML マップに `div_pbegin` 等を追加する案は
   「makeweb 本体に手を加えない」方針により却下
3. makeweb 既存の `=TAG<` 書式を mymw.pl 前処理で横取りする方式に決定

### 更新ファイル
- `~/Dropbox/GH/dia/mymw.pl`
- `~/Dropbox/GH/makeweb/mymw.pl`
- `~/Dropbox/GH/dia/mymwref.md`

---

## mymwref.md — クイックリファレンス更新

`~/Dropbox/GH/makeweb/mymwref.md` を修正。

### 変更内容（午前）
- 「シンプル（全行 td、左寄せ）」セクションを2つに分割:
  - 「シンプル（セパレータあり・全行 td、左寄せ）」— `|---|` 行あり版
  - 「シンプル（セパレータなし・全行 td）」— セパレータ行なし版
- セパレータなしでも全セル `td` として動作することを明示

### 変更内容（午後）
- `=TAG< ... =TAG>` 書式のセクション追加
- makeweb の `-( ... -)` との関係・注意事項を追記
- yasnippet div ブロック用スニペット追加（key: div）
- 実装済み／未実装コマンド一覧を整理

---

## ~/Dropbox/backup/README.md — 新規作成

`~/Dropbox/backup/` 配下の全サブフォルダーの用途・構成をまとめたREADMEを新規作成。

### 対象フォルダー
CHANGELOG, GH, config, deepl, emacs, filezilla, gist, gnupg, icons, keyrings, mozc, passwd, ssh, zsh の14フォルダー。

### 備考
- `GH/` は Dropbox上のまるごとコピーを廃止。Xserver側でインクリメンタル圧縮バックアップしているため冗長だった
- `keyrings/` は X250がシンボリックリンクではなく起動時コピー運用である旨を明記（GNOME Keyring競合回避）

---

## ~/Dropbox/README.md — 新規作成

Dropboxルートの設計概要をまとめたREADMEを新規作成。

### 内容
- cron自動化の全体像（myjob.sh・makefile の2本）
- makefile の各ターゲット一覧
- 全サブフォルダーの用途説明（GH, minorugh.com, backup, howm, Documents, Site, thunderbird, junk, Public, papa）

---

## ~/Dropbox/makefile — 更新

### 変更内容
- ターゲット名を大文字に統一（`MELPA` / `DOTFILES` / `GH` / `GIT-COMMIT`）
- `GH` を `all` に組み込み（毎夜自動実行）
- 各ターゲットにコメント補足を追加
- cronの設定例をファイル冒頭に記載
- 長いrsyncコマンドを `\` で折り返して可読性改善

### cron追加
```crontab
50 23 * * * make -f /home/minoru/Dropbox/makefile >> /tmp/myjob.log 2>&1
```

---

## ~/src/github.com/minorugh/dotfiles/cron/README.md — 改訂

「作業記録」スタイルから「設定リファレンス」スタイルに改訂。

### 変更内容
- 現在のcrontab全体を冒頭に一覧化
- makefileのcronジョブ（23:50）を3本目として追加
- トラブルシューティング記録は末尾に保持

---

## 2026-03-11

# CHANGELOG 2026-03-11

## myjob.sh バグ修正

### 問題
`myjob.sh` 実行時に全ステップでエラー。
`PASSWD_DIR` が空になっており、全パスがルート直下（`/dmember.cgi` 等）になっていた。

### 根本原因
昨日 `BACKUP_DIR` をサブディレクトリに変更する際、誤って `PASSWD_DIR` をコメントアウトしてしまっていた。

### 修正内容
`/usr/local/bin/myjob.sh` および `dotfiles/cron/myjob.sh` を修正。

```bash
PASSWD_DIR="${HOME}/Dropbox/GH/reg/passwd"
BACKUP_DIR="${HOME}/Dropbox/GH/reg/passwd/backup"
```

### 教訓
- 変数定義を編集するときは前後の行も確認する
- `bash -x スクリプト名` は変数展開の問題を一発で特定できる便利なデバッグ手法

---

## CHANGELOG 管理システムの整備

### mkindex.pl 新規作成
`~/Dropbox/backup/changelog/` に置いた CHANGELOG-*.md から INDEX.md を自動生成するスクリプト。
Emacs quickrun で実行。日付見出しを該当ファイルへのリンクにして `C-c RET` でジャンプ可能。

### デバッグ記録
ファイル名が `CHANGELOG-20260304.md`（8桁・ハイフンなし）なのに
正規表現が `YYYY-MM-DD`（ハイフンあり）を期待していたため動作しなかった。
`/CHANGELOG-(.+)\.md$/` に変更し、8桁を `YYYY-MM-DD` 形式に変換する処理を追加して解決。

---

## 新規PC環境リストア手順の整理

### 確認した正しいリストア手順
SSH キーは `make all` 実行後・再起動後に初めて有効になるため、
それ以前の git clone はすべて HTTPS で行う必要がある。
GitHub の SSH 登録は新規PCでも生きているので再登録は不要。

```
1. OS インストール・Dropbox 同期完了
2. git clone https://github.com/minorugh/gpgimport.git
3. make gpg → GPG 秘密鍵インポート
4. git clone https://github.com/minorugh/dotfiles.git
5. git-crypt unlock（GPG 鍵があれば SSH 不要）
6. make all → ~/.ssh/ シンボリックリンク作成
7. 再起動
8. ssh -T git@github.com で確認
9. gpgimport・dotfiles の git remote を SSH に切り替え
10. make gh → GH リポジトリのリストア
```

### GH リポジトリの構成
`~/Dropbox/GH/` が実体で `~/src/github.com/minorugh/GH/` に `.git` を置く分離構成。
`~/Dropbox/GH/.git` は `gitdir: ...` のポインターファイル。
clone は `~/src/github.com/minorugh/` で行い、展開されたファイルは削除して `.git` だけ残す。

### 修正・作成したファイル
- `~/Dropbox/backup/gnupg/README.md` — 新規作成（出発点の手順書）
- `gpgimport/README.md` — clone を HTTPS に修正
- `gpgimport/Makefile` — dotfiles ターゲットを HTTPS に修正、switch-ssh・gh ターゲット追加
- `dotfiles/README.md` — 手順5・6の clone を HTTPS に修正、再起動後の SSH 切り替え手順を追加

---

## 2026-03-10

# CHANGELOG 2026-03-10

## 問題
再起動後に FileZilla・upsftp.pl で SSH パスフレーズを毎回求められる。
ターミナルは問題なし。X250（サブ機）セットアップ時に発覚。

## 根本原因
`autostart.desktop` の `Exec=bash $HOME/.autostart.sh` で
`$HOME` が展開されずスクリプトが実行されていなかった。
→ keychain が起動せず `SSH_AUTH_SOCK` のソケットが存在しない状態になっていた。

P1 では別の経路（.zshrc 経由）で動いていたため気づかなかった。

## 修正内容

### autostart.desktop
`$HOME` をフルパスに変更。

```
# 変更前
Exec=bash $HOME/.autostart.sh

# 変更後
Exec=bash /home/minoru/.autostart.sh
```

### .xprofile
keychain の起動を削除し `.autostart.sh` に一本化。
`${HOSTNAME}` を `$(hostname)` に統一。

```bash
if [ -f ~/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi
dbus-update-activation-environment --systemd SSH_AUTH_SOCK SSH_AGENT_PID
source ~/.keychain/$(hostname)-sh
```

### .autostart.sh
- `.zsh_history` のコピーを削除（`.zshrc` で親機/サブ機分岐済みのため不要）
- keyrings のコピーを `cp -rf` から `cp -a` に変更
  - `-a` はタイムスタンプ・パーミッションを元のまま保持するため、Default_keyring 以外のファイルのタイムスタンプが再起動のたびに更新される問題を解消

```bash
# 変更前
cp -rf ~/Dropbox/backup/keyrings/. ~/.local/share/keyrings/

# 変更後
cp -a ~/Dropbox/backup/keyrings/. ~/.local/share/keyrings/
```

### Makefile（dotfiles）
- `keyring` ターゲットを P1/サブ機で分岐：
  - P1: Dropbox へのシンボリックリンク（従来通り）
  - サブ機: シンボリックリンクが残っていれば削除するだけ（コピーは autostart.sh が担当）
- `emacs-mozc` の `ln -vsfn -rf` を `ln -vsn` に修正（`-rf` は `ln` には不正なオプション）
- 冒頭の英語手順コメントを削除し README.md に移動
- 全ターゲットの `## コメント` を日本語化
- footer の英語版「Customize settings」ブロックを削除（日本語版のみ残す）

```makefile
keyring:
    $(APT) seahorse libsecret-tools
ifeq ($(shell uname -n),P1)
    # 親機: Dropbox/backup/keyrings へのシンボリックリンク（正本）
    test -L ${HOME}/.local/share/keyrings || rm -rf ${HOME}/.local/share/keyrings
    ln -vsfn {${HOME}/Dropbox/backup,${HOME}/.local/share}/keyrings
else
    # サブ機: シンボリックリンクが残っていれば削除するだけ
    # コピーは起動時に autostart.sh が行う（Dropbox競合防止）
    test -L ${HOME}/.local/share/keyrings && rm -f ${HOME}/.local/share/keyrings || true
endif
```

### filezilla.sh
デバッグログを削除、`export SSH_AUTH_SOCK` を追加して完成。

```bash
source ~/.keychain/$(hostname)-sh 2>/dev/null
export SSH_AUTH_SOCK
filezilla "$@" &
```

### README.md
- Makefile 冒頭の手動準備手順を移動し Markdown で整形
- SSH キー・keychain の仕組みのセクションを新設
- make ターゲット一覧を表形式で追加
- 更新履歴を表形式に整理、誤記（Debian10→Debian11）を修正

## 確認済み動作
- P1・X250 両機とも再起動後にパスフレーズなしで動作
  - upsftp.pl、filezilla.sh、Emacs からの FileZilla 起動、すべて正常
- `~/Dropbox/backup/keyrings/` に競合発生なし
- `cp -a` により Default_keyring 以外のタイムスタンプが保持されることを確認

## 教訓
- `autostart.desktop` の `Exec=` では環境変数 `$HOME` が展開されない
- `cp -rf` ではコピー先のタイムスタンプがコピー実行時刻になる。バックアップ系のコピーには `-a` を使う
- `ln` に `-rf` は不正なオプション（`cp`・`rm` 用）。シンボリックリンク作成には `-vsn` で十分

---

## 追加作業（午後）

### deepl-translate.el — DeepL API 仕様変更対応

DeepL が認証方式を変更したため動作しなくなっていた。
POST ボディの `auth_key` を廃止し、`Authorization` ヘッダーに移行。

```elisp
;; 変更前
:data `(("auth_key" . ,deepl-auth-key)
        ("text" . ,text) ...)

;; 変更後
:headers `(("Authorization" . ,(format "DeepL-Auth-Key %s" deepl-auth-key)))
:data `(("text" . ,text) ...)
```

- 原作者の gist は未対応のまま。自分の GitHub リポジトリ側で修正
- `70-translate.el` の `:url` コメントに修正済みの旨を追記

### gpgimport — USB 依存廃止・AES256 暗号化方式に移行

**問題**：GPG 秘密鍵が USB メディアにしかなく、紛失・劣化リスクがあった。
また Dropbox に保存していた `encrypt.zip` は zip 暗号化強度が低く心もとなかった。

**対応**：
- `secret-all.key` を GPG 対称暗号化（AES256）して Dropbox に保存
- 旧 `encrypt.zip` と生の `secret-all.key` は `shred` で完全削除
- Makefile の `gpg` ターゲットを USB → Dropbox の `.key.gpg` から復号する形に変更
- `export` ターゲットも暗号化まで一本化
- README.md を新規作成（リストア手順を Step 1〜5 で整理）

```bash
# 保存（P1 で一度だけ実施済み）
gpg --symmetric --cipher-algo AES256 \
    -o ~/Dropbox/backup/gnupg/secret-all.key.gpg secret-all.key

# 復元時（make gpg が自動実行）
gpg --decrypt ~/Dropbox/backup/gnupg/secret-all.key.gpg > secret-all.key
```

パスフレーズは SSH 鍵（id_rsa）と統一。

**教訓**：
- zip のパスワード暗号化は強度が低い。秘密情報には GPG 対称暗号化（AES256）を使う
- 保存場所は README.md に明記しない（セキュリティ上）

---

## 追加作業（夕方）

### Dropbox/backup/ の棚卸し

GitHub（dotfiles）と重複している不要なディレクトリを整理・削除した。

**削除したもの**
- `dotfiles/` — GitHub 管理で十分
- `bin/` — dotfiles の bin/ で管理
- `devils/` — dotfiles 管理
- `etc/` — dotfiles 管理
- `local/` — dotfiles 管理
- `tex/` — dotfiles 管理
- `abook/` — dotfiles 管理
- `mutt/` — 不使用
- `w3m/` — dotfiles 管理
- `config/autostart/` — dotfiles 管理
- `config/sxiv/` — dotfiles 管理
- `config/git/` — gist/ に統合

**残したもの（Dropbox が必須）**
- `keyrings/` — keyring 正本
- `mozc/` — mozc 設定正本
- `filezilla/` — FileZilla 設定正本
- `gist/` — gist 認証ファイル・gitk 設定（後述）
- `icons/` — アイコン・壁紙
- `gnupg/` — GPG 秘密鍵（AES256 暗号化済み）
- `config/rclone/` `config/hub` — rclone・hub 設定正本
- `config/git/gitk` → `gist/gitk` に移動（後述）
- `GH/` — myjob.sh のパスワードファイル管理
- `passwd/` — KeePassXC の kdbx ファイル
- `deepl/` — DeepL API キー
- `zsh/` — .zsh_history・cdr 履歴
- `emacs/` — elpa 世代バックアップ・自作ロゴ
- `ssh/` — 保留（気持ちの整理がついたら削除）

### gist と gitk の整理

`gist`（認証ファイル単体）と `config/git/gitk` を `gist/` ディレクトリにまとめた。

```
# 変更前
~/Dropbox/backup/gist          # ファイル単体
~/Dropbox/backup/config/git/gitk

# 変更後
~/Dropbox/backup/gist/gist
~/Dropbox/backup/gist/gitk
```

Makefile の `gist` `gitk` ターゲットのパスを合わせて修正。
`make gist gitk` で P1・X250 両機とも動作確認済み。

---

## 2026-03-09

# CHANGELOG 2026-03-09

## Makefile（dotfiles）

### 変更内容
- `allinstall` の依存リストから `autologin` を削除
- autologin廃止コメントブロックを削除
- `texlive` ターゲットをフルインストールから scheme-medium + collection-langjapanese に変更（約7GB → 約2GB）
- `texlive-full` ターゲットを新設（旧フルインストール手順を保持）
- sudoers編集手順を `sudo nano` から `visudo` に変更
- `cpenv` ターゲットを削除（残骸）
- `filezilla` ターゲットに `fzilla-gh.sh` と `fzilla-gh.desktop` のシンボリックリンク作成を追加

## SSH / keychain 整備

### .autostart.sh
- 冒頭に `pkill ssh-agent && eval $(ssh-agent -s)` を追加（起動時にクリーンなソケットを確保）
- 末尾を `source ~/.keychain/$(hostname)-sh` に変更（keychainの環境変数をセッションに反映）

### .xprofile
- GUIアプリ向けに keychain 環境変数の読み込みを追加

### init.el
- `exec-path-from-shell-copy-env "SSH_AUTH_SOCK"` を `:config` ブロックに統合

## bin/fzilla-gh.sh（新規）

FileZilla を gospel-haiku.com サイトプロファイルで起動するラッパースクリプトを新設。
`.desktop` 経由の起動では `SSH_AUTH_SOCK` が引き継がれないため keychain から読み込む。

## .local/share/applications/fzilla-gh.desktop（新規）

`fzilla-gh.sh` を呼び出す `.desktop` ファイルを新設（パネルランチャー用）。

---

## 2026-03-08

# CHANGELOG 2026-03-08

## Makefile — Debian12向けパッケージ整理

### PACKAGES の変更
- `hub`削除 — `gh`（GitHub CLI）が主流。未使用のため
- `screen` 削除 — `tmux` を使用しているため重複
- `ntp` 削除 — Debian12はsystemd-timedatectlが標準
- `compizconfig-settings-manager` / `compiz-plugins` 削除 — XFCEでは不使用

### BASE_PKGS の変更
Emacsをaptパッケージで運用する方針に変更したため、ソースビルド用ライブラリを大幅削除。

### Makefile ターゲット変更
- `sxiv` → `nsxiv` に変更（ソースビルド方式）
- `emacs-stable` / `emacs-devel` をコメントアウト（記録として保持）
- `init` 内の `.config/hub` シンボリックリンクを削除
- `nextinstall` を sxiv → nsxiv に更新

---

## nsxiv 移行（未完・翌日へ持ち越し）

### 問題1: Imlib2バージョン不足
nsxiv最新版（v34）はImlib2 v1.11.0以上を要求するが、Debian12の公式は v1.10.0 止まり。

暫定対応: v1.11.0要求追加前のコミット `18c24bc` にチェックアウトしてビルド成功（v33相当）

```bash
cd ~/src/nsxiv
git checkout 18c24bc
make clean && make && sudo make install
```

### 問題2: 複数ファイル表示ができない
- 1ファイル指定では開ける
- `*.jpg` や複数ファイル直接指定でも1枚しか表示されない
- v33のバグの可能性あり → 翌日 Imlib2 自前ビルドで v34 を試す

### 現状
- `nsxiv` は `/usr/local/bin/nsxiv` にインストール済み（v33相当）
- `.zshrc` の alias は `iv='nsxiv'` に修正済み
- 複数ファイル表示は未解決

---

## 2026-03-07

# CHANGELOG 2026-03-07

## SSH / keychain 自動入力設定

### 概要
OS起動時にSSH鍵のパスフレーズを自動入力し、ターミナル・GUIアプリ・Perlスクリプトすべてで
パスフレーズを聞かれないようにする設定を整備した。

### 方式
- `keychain` がSSHエージェントを管理
- パスフレーズは `secret-tool`（GNOME Keyring）に保存
- `.autostart.sh` が起動時に `SSH_ASKPASS` 経由で自動入力（`expect` 方式を廃止）

### 変更・追加ファイル

#### .autostart.sh
`SSH_ASKPASS` + `mktemp` 方式で keychain にパスフレーズを自動入力。

```bash
ASKPASS_SCRIPT=$(mktemp /tmp/askpass.XXXXXX.sh)
echo '#!/bin/bash' > "$ASKPASS_SCRIPT"
echo 'secret-tool lookup ssh-key id_rsa' >> "$ASKPASS_SCRIPT"
chmod +x "$ASKPASS_SCRIPT"
DISPLAY=:0 SSH_ASKPASS="$ASKPASS_SCRIPT" SSH_ASKPASS_REQUIRE=force \
    /usr/bin/keychain --eval --quiet ~/.ssh/id_rsa
rm -f "$ASKPASS_SCRIPT"
```

#### .zshrc
keychain の起動は `.autostart.sh` に一本化し、環境変数の読み込みのみ行う。
`--noask` オプションは削除（付けるとキーが agent に登録されない）。

#### upsftp.pl / movepdf.pl
`BEGIN` ブロックで keychain ファイルを読み込み、`SSH_AUTH_SOCK` を環境変数に設定。

### GNOME Keyring の構成
`~/.local/share/keyrings` を `~/Dropbox/backup/keyrings` へのシンボリックリンクにすることで
P1・X250 が同じ keyrings を共有。P1 で一度 `secret-tool store` すれば X250 での登録は不要。

### 廃止したもの
- `expect` によるパスフレーズ自動入力
- `autologin.sh` / `autologin.desktop`
- `.zshrc` の `--noask` オプション

### 教訓
- `$(hostname)` を使うこと。zsh では `$HOSTNAME` が未設定のため空文字になる
- P1 と X250 を同時起動した状態で `secret-tool store` を実行すると Dropbox の競合コピーが発生する

---

## 2026-03-25

### Added

### Changed

### Fixed

### Removed

---

## 2026-03-05

# CHANGELOG 2026-03-05

## gospel-haiku.com — choice_mj.cgi 改修

### 新機能：予選システム
選句を「予選 → 確認 → 確定」の3段階フローに変更。

```
【選句画面】全句表示
  チェック → 「予選する」ボタン
      ↓
【予選画面】チェック済み句のみ表示（繰り返し可）
  チェック → 「予選する」or「決定する」or「やり直す」
      ↓「決定する」
【予選確認】最終候補一覧
      ↓「投票する」
  data.dat に記録（確定）
```

### バグ修正

#### Set-Cookie ヘッダー露出
- `sub header` が `Content-Type` を生出力していたためクッキーが乗れなかった
- `$cookie_obj` のスコープ問題により認証前の画面でクッキーチェックが効かなかった
- `$q_obj->header(-cookie=>$cookie_obj)` を使用する方式に修正

#### sub regist の if/if バグ
`if / if` の二重判定を `if / elsif` に修正。

#### 代入演算子バグ
`if ($max = $count)` → `if ($max == $count)` に修正。

### HTML・CSS 整理
- `sub header` / `sub footer` をサブルーチン化して全画面で共通化
- スタイルを `choice.css` として外部ファイル化
- コメントアウトされた未使用コードを削除

### ファイル構成
```
choice.cgi    ← choice_mj.cgi をリネームして運用
choice.css    ← 新規追加
```

---

## 2026-03-04

# CHANGELOG 2026-03-04

## gospel-haiku.com — appost.cgi / voice.cgi 改修

### 共通変更
- `cgi-lib.pl` 依存を `CGI.pm` に移行
- `use warnings` / `CGI::Carp` によるエラー検出を強化

### appost.cgi 固有の修正

#### スパムキーチェックのバグ修正
`if ($in{'spam_key'} ne my $spam_base_key)` の `my` により新規レキシカル変数が生成され、
スパムキーチェックが事実上無効化されていた。`my` を除去して修正。

#### クエリストリングから $id / $subject を正しく取得
旧コードは `$ARGV` から取得しており CGI 経由では `$id` が常に空になっていた。
`QUERY_STRING` を直接解析する方式に変更。

#### その他バグ修正
- スパムキー入力フォームのコメントアウトを解除
- 削除パスワードの `my` 宣言を修正
- `$file` / `$frag` の `my` 宣言バグを修正（`our` でグローバル宣言済みの変数を `my` 再宣言していた）

### voice.cgi
共通変更（`cgi-lib.pl` → `CGI.pm` 移行）のみ。
同CGIは他のページでも多数使用されているため、各設置箇所で個別に同様の修正を適用すること。

---

