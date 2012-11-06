---
layout: posts
title: Git 空ブランチ (Orphan branch)
tags: git
---

## 空ブランチ

Gitではコミットやブランチを作成する場合、必ず親を指定する必要があります。今までの歴史を全て辿れるようにするためです。

空ブランチを作成すると、今までの歴史とは全く別の新たな歴史を、同じリポジトリ内で開始することができます。


## 作成方法１: Github pagesの場合

Github pages ではプロジェクトサイトを作成する際にはプロジェクトのリポジトリ内で空ブランチを作成します。
空ブランチを使う理由はわかりませんが、プロジェクト本体には影響させず、リポジトリ内に同梱させるためにこの手法を採用したのだと思います。

    # HEADをnew_branchに切り替える。
    git symbolic-ref HEAD refs/heads/new_branch

    # symbolic-refを直接変更した場合はインデックスとワーキングツリーが残るので削除する
    rm .git/index
    git clean -fdx
    
    # new_branchの内容をコミット
    touch .gitignore
    git add .
    git commit
    git push -u origin new_branch

[各コマンドの意味はこちらを参考にしました](http://d.hatena.ne.jp/kanonji/20110221/1298263044)。

## 作成方法２: orphanオプション

Git 1.7.2 では checkout に orphan オプションがが追加されました。これで、空ブランチ（orphan branch）が簡単に作成できるようになります。

    git checkout --orphan new_branch_name

orphan とは孤児のことです。

<http://irohiroki.com/2010/08/02/push-orphan-to-heroku>


## 空ブランチの用途

- [git-checkout](http://www.kernel.org/pub/software/scm/git/docs/git-checkout.html) によると、全履歴を見せずにツリーを公開したい場合や、公開すべきでないコードが履歴に含まれている場合に空ブランチが有効だと書いてあります。
- github pagesのユーザーページ。Jekyllプラグインを使用するためにソースとは別に出力HTMLだけの空ブランチを作成（Octpress方式）。
- サーバーサイドプログラミングができない HTML/CSS/JS だけで作られたプロジェクト。製品版では開発版とは別のディレクトリ構造にしなければならない場合など。

空ブランチを作成しなくても新たにリポジトリを作成するという手段もあります。実質的には同じことです。
どちらがより適切かどうかはプロジェクトによって判断する必要があると思います。

