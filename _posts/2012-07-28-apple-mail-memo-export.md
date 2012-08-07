---
layout: posts
title: Apple Mail (Mail.app) のメモをエクスポートする
tags: MacOSX
---

Apple Mail (Mail.app) のメモは保存が早く、iPhoneと同期できて重宝していたのだけど、[変な問題](/apple-mail-memory-problem.html) が解決できず、別のツールに乗り換えすることを検討してみた。

問題はエクスポートをどうするか。メモはgmailに保存しているので、最悪IMAPでアクセスすれば取得できるのだけど、良いスクリプトを発見。

<http://veritrope.com/tech/export-apple-mail-messages-and-notes-to-text-files/>

Apple MailをAppleScriptで操作してファイルに書き出すというスクリプト。
期待通り１メモが１ファイルで保存された。
これはすごい。製作者に感謝。
AppleScript習得したら色んなことができそうだ。

使い方はの通り。

1. 上記スクリプトをファイルに保存。
2. AppleScriptエディタで開く。
3. Apple Mailでエクスポートしたいメモを選択状態にして
4. 実行する。
5. するとデスクトップの "Temp Export Folder" に保存される


Notational Velocityに移行する予定なため、ファイル名の連番を消す（重複する場合は付ける）ように少し書き換えた。

<https://gist.github.com/2847462>


