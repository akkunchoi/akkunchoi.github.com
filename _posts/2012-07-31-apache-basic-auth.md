---
layout: posts
title: Apache Basic認証
tags: apache
---

* toc
{:toc}

## Basic認証の仕組み

1. クライアントがページをリクエストする（この時点ではまだ認証がかかってるかどうか知らない）
2. クライアントに401レスポンスを返す
3. ユーザにIDとパスワードの入力を求める
4. 認証ヘッダを含めてページをリクエストする
5. 成功すれば、通常のページを。そうでなければ再度401を返す

## .htpasswd ファイルを作成する

    # -c ファイル新規作成
    # -s パスワードをSHA1
    $ htpasswd -c -s .htpasswd username

## httpd.conf / .htaccess での設定

    AuthUserFile    /path/to/.htpasswd
    AuthName        "basic auth"
    AuthType        Basic
    Require valid-user

## 特定のファイルには認証をかけない

[Satisfy](http://httpd.apache.org/docs/2.2/mod/core.html#satisfy) ディレクティブを使う。
これは、RequireとAllowが両方使われている場合に、詳細な設定を行う場合に使用する。

    # 画像のみ認証をかけない
    <FilesMatch "\.(gif|jpe?g|png)$">
        Satisfy Any
        Allow from all
    </FilesMatch>

## 特定のIPからのアクセスには認証をかけない

    Satisfy Any
    Allow from 127.0.0.1

