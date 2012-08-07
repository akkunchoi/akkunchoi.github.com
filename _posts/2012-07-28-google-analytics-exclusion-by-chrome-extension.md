---
layout: default
title: Chrome拡張を使ってGoogle Analyticsの自分のアクセスを除外する
tags: Chrome GoogleAnalytics
---

{{ page.title }}
================


IP固定の場合はIPフィルタリングすることもできるが、IP動的の場合はわざわざクッキーを設定しなければならなかった。

[Analytics blocker](https://chrome.google.com/webstore/detail/jmcpbefnpobogldglnlikgojpaddibgb)はURLにマッチしたサイトへのGoogle Analyticsへの送信をブロックするChrome拡張だ。
これを使えば自分のサイトを登録するだけで、アクセスを除外できるのでとても簡単。

設定は例えばこのように。
アスタリスクを忘れると、トップだけしかブロックしないので注意。

    akkunchoi.github.com/*


ブロックできていれば、アドレスバーに赤い丸が表示される。

![](/images/posts/analytics-blocker.png)

[Google Analytics Debugger](https://chrome.google.com/webstore/detail/jnkmfdileelhofjcijamephohjechhna)を使っても確認できる。
ブロックが成功していれば、トラッキングが送信されないはずだ。
