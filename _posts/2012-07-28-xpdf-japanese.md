---
layout: posts
title: xpdfを使ってPDFから日本語抽出
tags: pdf 
---

環境はMacOSX, homebrewです。

homebrewでxpdfをインストールする。

    $ brew install xpdf

動作確認。

    $ pdftotext hoge.pdf

日本語が含まれる場合、このようなエラーが出る。

    Error: Unknown character collection 'Adobe-Japan1'

調べてみると日本語用の設定が必要なようだ。

1. [xpdf](http://www.foolabs.com/xpdf/download.html)のサイトからLanguage Support Packagesの xpdf-japanese.tar.gz をダウンロード。
2. 解凍したものを ```/usr/local/share/xpdf/japanese``` に配置する。
3. ```/usr/local/etc/xpdfrc``` に add-to-xpdfrc の内容を追記する。
4. ここまでだと、エラーはなくなるが、日本語が読み飛ばされる。textEncoding設定のコメントを外す

xpdfrcはこのようになります。

    # コメントを外す
    textEncoding UTF-8
    ...
    # 追記
    cidToUnicode    Adobe-Japan1    /usr/local/share/xpdf/japanese/Adobe-Japan1.cidToUnicode
    unicodeMap  ISO-2022-JP /usr/local/share/xpdf/japanese/ISO-2022-JP.unicodeMap
    unicodeMap  EUC-JP      /usr/local/share/xpdf/japanese/EUC-JP.unicodeMap
    unicodeMap  Shift-JIS   /usr/local/share/xpdf/japanese/Shift-JIS.unicodeMap
    cMapDir     Adobe-Japan1    /usr/local/share/xpdf/japanese/CMap
    toUnicodeDir            /usr/local/share/xpdf/japanese/CMap


以上で、日本語が出力されるようになりました。

- <http://watermans-linuxtips.blogspot.jp/2008/12/pdf.html>
- <http://oku.edu.mie-u.ac.jp/~okumura/linux/?Xpdf>

