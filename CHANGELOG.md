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

