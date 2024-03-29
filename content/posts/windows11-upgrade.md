+++
date = "2022-01-31T19:20:43+09:00"
categories = ["tech"]
tags = ["windows"]
title = "Windows11 非対応 CPU+TPM+セキュアブート回避最強編"
+++

Windows11を導入するためには３つの条件が必須になっています。

```
１． CPU
     ※ Intelの Coreシリーズは第8世代以降（Core i3/i5/i7の8000以降）
     ※ AMDの Ryzenシリーズは第2世代以降（Ryzen 5 2600以降）
２． TPM1.2/2.0
３． UEFI/セキュアブート（boot）
```

我が家で家族が使っているマシン5台について、Windows11へのアップグレードを試みましたがいづれもシステムチェックで引っかかりアウトでした。

まず最初に見つけた Tipsでレジストリを編集して3台は成功しました。

- [【 Microsoft公式情報＋α】互換性チェックを回避して Windows 11にアップグレードする方法](https://atmarkit.itmedia.co.jp/ait/articles/2110/13/news014.html) 

しかし残りの2台（Thinkpad X220、L540）は、セキュアブートでひっかかって駄目。

こちらもレジストリ編集でいけたという Tipsもあったので試しましたがアウトでした。

諦めるのは癪なので、ググって「最強編」なる Tipsを見つけました。

- [Windows11 非対応 CPU+TPM+セキュアブート回避の簡単まとめ（手っ取り早く導入する最強編）](https://www.broadcreation.com/blog/news/86520.html?utm_source=pocket_mylist) 

インスール用の ISOファイルを USBにコピーして、sourcesフォルダ内にある appraiserres.dllを削除してインストールするというものでした。
ただし、その手順にやや注意事項があるようなので転載しておきます。

## 1. appraiserres.dllを削除
ダウンロードした ISOファイルを直接編集して appraiserres.dllを削除しよとしてもできませんでしたので、一度 USBにコピーして作業しました。
削除でもリネームでも構わないようで、念の為に Windows10の appraiserres.dllと差し替えるという方もいましたが、私の場合は削除で問題なくインストールできました。


## 2. ISOファイルから起動
ISOファイルをダブルクリックすると下記の通りマウントされるので setup.exeを実行すます。

![Alt Text](https://live.staticflickr.com/65535/51853953653_7236caf098_o.jpg) 


## 3. セットアップ画面

ISOファイル中の setup.exeを実行すると、何度か画面が変遷して下記の画面で入力まちになります。

![Alt Text](https://live.staticflickr.com/65535/51853909983_83318d2014_o.jpg) 

ここでのポイントは、必ず

```
「セットアップでの更新プログラムのダウンロード方法の変更」
```

をクリックしてインストールしなければいけません。

そのまま次へを押してしまいますとすステムチェックされてインストール出来ません。

## 4. 更新プログラムの入手は「今は実行しない」を選ぶ

続いて次の画面に代わります。

![Alt Text](https://live.staticflickr.com/65535/51854155839_5045731520_o.jpg) 

ここでも大事なポイントがあり、

```
今は実行しない
```
にチェックを入れて「次へ」を押します。

この方法で残り2台も無事 Windows11へアップグレードできました。

## 5. この手法の問題点

先人の Tipsによるとこの最強編でインストールしたら日々のアップデートを自動でしてくれないとのことでした。

けれども私の場合は、今のところ2台共その心配はなく機嫌よく動いて、自動アップデートにも対応しているようです。

2台共 Windows10 Proだったのでそのへんが関係しているのかもされえません。

まだ、完全に安心はできないですが暫く様子を見てみましょう。


でも Micro Softが、どうな目算があってこんな意地悪な制限をするのか不可解、単なるパソコンメーカー販促への義理だてとしか思えない。
