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

