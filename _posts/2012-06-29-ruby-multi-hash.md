---
layout: default
tags: ruby
---

## Ruby 多次元ハッシュ

PHPでこんなことをRubyでもやりたい。
   
    $a = array();
    $a['foo']['bar']['fuga'] = 'hoge';

PHPのノリでやるとこうなる。

    > a = {}
     => {} 
    
    > a['foo']['bar'] = 'hoge'
    NoMethodError: undefined method `[]' for nil:NilClass

Hashの場合、キーが存在しない場合の処理、というtrap::Hashなるものが作成できる。

    # 存在しない場合の処理をブロックで渡す
    > a = Hash.new{ |hash,key| hash[key] = {} }
     => {}
     
    # foo は存在しないキーだが、ここで先ほどのブロックが発動
    #   a['foo'] = {} が呼び出された後に処理が実行されるのでエラーが発生しない
    # 
    > a['foo']['bar'] = 'hoge'
     => "hoge"
    > a
     => {"foo"=>{"bar"=>"hoge"}}

しかし多次元になる場合、Arrayの場合はめんどくさい

- <http://www.ruby-lang.org/ja/old-man/html/Hash.html>
- <http://k.try-z.com/?p=264>

