---
layout: default
title: rbenv + ruby-build で ruby をインストール
tags: ruby rbenv ruby-build
---

{{ page.title }}
================
* TOC
{:toc}

# MacOSX 
rvmからよりシンプルな構成であるrbenv+ruby-buildに乗り換えたのでメモ。

方針gemはroot権限でbundlerのみ持たせて
一般ユーザーが各自bundle installする

まずは rvm を削除。

    $ rvm implode
    # bashrc等に追加した読み込み設定を手動で削除する。

rbenv, ruby-build を homebrew でインストール。
たったの５コマンドでOK。

    $ brew install rbenv
    $ if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
    $ brew install ruby-build
    $ rbenv install 1.9.3-p194 # バージョンを指定しなければ一欄が出る
    $ rbenv rehash

MacPortsでも下記CentOSの方法を使ってインストールできるかと思っていたが、上手くいかないらしい。portにruby1.9があるのでそれを使う方が良さそう。

# CentOS

CentOSにもrubyを入れる機会があったので、rbenvで入れてみる。

`/usr/local`にroot権限でインストールし、ユーザー共通にする。
gemはbundlerやpassengerのみ入れる。その他はアプリケーションごとにbundleで個別インストールさせる。このようにしておけば、グローバルな場所にgemライブラリをインストールする時にroot権限が必要になるのでわかりやすい。

まずは必要なライブラリをインストール

    $ sudo yum -y update
    $ sudo yum -y install gcc kernel-devel zlib-devel openssl-devel readline-devel curl-devel libyaml-devel sqlite-devel

ちなみに zlib-devel がない状態でrubyをコンパイルするとこんなエラーが出ます。

    ERROR:  Loading command: install (LoadError)
    cannot load such file -- zlib

rbenvとruby-buildはgitから取得する。

    $ cd /usr/local/share
    $ git clone git://github.com/sstephenson/rbenv.git

 `/etc/profile.d/rbenv.sh`を作成する

    export PATH="/usr/local/share/rbenv/bin:$PATH"
    export RBENV_VERSION="1.9.3-p194"
    export RBENV_DIR=/usr/local/share/rbenv
    export RBENV_ROOT=/usr/local/share/rbenv
    eval "$(rbenv init -)"

権限設定して、読み込む。

    $ chmod 755 /etc/profile.d/rbenv.sh
    $ . /etc/profile.d/rbenv.sh

ruby-buildのインストール

    $ cd /usr/local/src
    $ sudo git clone git://github.com/sstephenson/ruby-build.git
    $ cd ruby-build
    $ sudo ./install.sh

rubyをインストール

    $ rbenv install 1.9.3-p194
    $ rbenv rehash
    $ rbenv global 1.9.3-p194
    $ gem install bundler

ロケーションとバージョンを確認

    $ ruby -v
    $ which ruby
    $ gem -v 
    $ which gem

このままでは`sudo ruby`や`sudo gem`ができない。sudo時のパスが違うからだ。パスはsudoersによって管理されている。設定方法は２つある。

    $ visudo

    # env_keep設定で一般ユーザーのパスを引き継ぐようになる。
    # 一般ユーザーが`/usr/local/bin`パスを設定しておけば良い
    Defaults env_keep+="PATH" 

    # またはsecure_pathでsudo時のパスを直接指定できる（セキュリティ的にどうなんだろうか）
    Defaults secure_path = "/sbin:/bin:/usr/local/share/rbenv/shims:usr/local/bin:/usr/bin:"


基本的なことだけど、上手くいかない場合はパスの問題であることが多い。

パスの設定が間違っていると元々入っているrubyやgemやbundleが呼ばれる場合がある。
`gem env`や`echo $PATH`などで常にどこにgemがインストールされるか、何が優先されるのかを把握しておくと良い。
使う予定のない古いバージョンの実行ファイルは削除しておくと良い。

