---
layout: default
title: Jekyll + github pages を使って git + markdown でサイト構築
tags: ruby jekyll github markdown
---

[github pages]と[Jekyll]を使ってサイト構築してみました。

## はじめに

git + markdown でのサイト管理が便利そうなので、ホスティングまでできる[github pages]を使ってみました。

ちなみに[Octopress], [Jekyll bootstrap]を使えばもっと簡単に設置できると思います（後で知った）。

## username.github.com

まずは github pages のユーザーページをセットアップ。

- (1) github [Create a New Repo](https://github.com/new) へ。
- (2) Repository name に "[username].github.com" と入力。[username]は自分のIDです。
  - "username = 自分のユーザID" でない場合はドメインのルートにならず、パスを切るようです。
- (3) 普通にリポジトリを作成する。

        mkdir username.github.com
        cd username.github.com
        git init
        touch README
        git add README
        git commit -m 'first commit'
        git remote add origin git@github.com:username/username.github.com
        git push -u origin master


- (4) リポジトリページの Admin から GitHub Pages 内の Automatic Page Generator で適当にテーマ選択。
  - 自分のユーザIDをドメインにした場合（ID: akkunchoiならakkunchoi.github.com）はGeneratorのデータが自動的にmasterにマージされたが、そうでない場合は gh-pages ブランチに作成された。
  - README から HTML 作成ができるので、ペライチなら Jekyll 使わなくてもいい。
- (5) 以上で github pages のセットアップ完了。


## Jekyll のインストール

インストールはgemから。

    $ gem install jekyll

最初rvmで動作させていたのを忘れて、`sudo gem install jekyll`してしまった。すると、違う場所に保存されたり、root権限になってたりでややこしいことになったが、uninstall して、`sudo` せずに install で問題なくインストールできた。

## Jekyll 用にファイルを配置する

最低限必要なファイルは次の通り。

    /
    |-- _config.yml
    |-- _layouts
         `-- default.html


_config.yml の内容はこんな感じで。[設定オプション一欄](https://github.com/mojombo/jekyll/wiki/Configuration)

    auto: true
    server: true
    markdown: kramdown

default.html には Auto Generator で生成されたHTMLを元に作成しました。コンテンツ部分を `{{ content }}` に置き換えるだけです。

この作業には [Radium Software](http://radiumsoftware.tumblr.com/post/10518849682)さんの
[リポジトリ](https://github.com/unity-yb/unity-yb.github.com)を参考にしました。


## ページを作成してみる

index.md を作成します。

    ---
    layout: default
    ---
    
    ## トップページです
    
    ....

`---` の部分はページのメタデータです。layoutは必須です。タイトル、カテゴリ、タグなども設定できます。詳細は[YAML-Front-Matter](https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter)。


jekyllを起動

    $ jekyll

<http://localhost:4000> で表示されればOKです。

## 公開

`push` するだけでOK。 github pagesが内部でJekyllを動作させて、生成してくれる。http://username.github.com/ で見れれば完了。

Octpressは、静的HTMLをローカルで生成してアップロードしているそうだ。動的な出力を行うプラグインを動作させるためにはこの方法にするか、自分でホスティングするしかなさそう。

## 他わかったこと

- _config.ymlに設定した変数はテンプレート内では site.hoge で取得できる。
- layout: nil でレイアウトなしで出力できる。
- テンプレートエンジン [Liquid デザイナー用マニュアル](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers)
- raw は使用できない。


[Jekyll]: https://github.com/mojombo/jekyll/
[github pages]: http://pages.github.com/
[Octopress]: http://octopress.org/
[Jekyll bootstrap]: http://jekyllbootstrap.com/
[Liquid]: http://liquidmarkup.org/

