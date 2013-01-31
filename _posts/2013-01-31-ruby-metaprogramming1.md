---
layout: posts
title: Ruby メタプログラミング (1)
tags: ruby
---

書籍メタプログラミングRubyを参考に、メタプログラミングの方法を簡単にまとめます。

<a href="http://www.amazon.co.jp/gp/product/4048687158/ref=as_li_ss_il?ie=UTF8&camp=247&creative=7399&creativeASIN=4048687158&linkCode=as2&tag=ac0689-22"><img border="0" src="http://ws.assoc-amazon.jp/widgets/q?_encoding=UTF8&ASIN=4048687158&Format=_SL110_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=ac0689-22" ></a><img src="http://www.assoc-amazon.jp/e/ir?t=ac0689-22&l=as2&o=9&a=4048687158" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

## オープンクラス

既存のクラスを拡張することができる。

<pre><code data-language="ruby"># Stringクラスを拡張する
class String
  def to_alnum
    gsub /[^\w\s]/, ''
  end
end
</code></pre>

ただし、それが**できる**とはいえ、やる**べき**かどうかはまた別。

- やるべきかどうかの基準
  - （Stringの例の場合）すべての文字列が持っていても問題ない汎用的な機能だろうか？
  - 特定のドメインに特化したメソッドを追加しようとしてないだろうか？

- 他の方法には...
  - 別の AlphanumericString クラスを定義する
  - 特異メソッドを使って、特定の String インスタンスにだけメソッドを追加する。

### クラス定義

クラス定義とその他のコードに違いはない。

<pre><code data-language="ruby"># クラスCを3回定義している？
3.times do
  class C
    puts "Hello"
  end
end
# Hello
# Hello
# Hello
</code></pre>

クラスが存在していない時は、クラスを定義する。メソッドがあればメソッドも定義する。
クラスが存在している時は、既存のクラスを**再オープン**して、メソッドを追加する。

class キーワードはクラス宣言というより、スコープ演算子のようなもの。

既存のクラスを再オープンして、いつでもその場で修正できる。この技術を**オープンクラス**と呼ぶ。

### オープンクラスの問題点

すでに用意されているメソッドを簡単に書き換えられる。
そのため、知らぬ間に依存している機能の動作を変更してバグにつながる可能性がある。

クラスへの安易なパッチを蔑称して**モンキーパッチ**と呼ぶ。

モンキーパッチは「意図せずに起きる」のと「意図的に適用」する場合がある。
便利だが危険がつきまとう。独自のメソッドを定義する前に、クラスに既存のメソッドがないかを注意深く確認すること。


## クラス

### インスタンス変数とインスタンスメソッド

インスタンス変数はハッシュのキー・バリューのようなもの。セットして初めて存在する。
インスタンス変数はオブジェクトに、インスタンスメソッドはクラスに住んでいる。

<pre><code data-language="ruby"># 
class MyClass
  def my_method
    @v = 1
  end
end
obj = MyClass.new
obj.instance_variables # [@v]
obj.methods            # ["my_method"]
</code></pre>


### クラスはオブジェクト

クラスは Class クラスのインスタンス。

<pre><code data-language="ruby"># classメソッド
"hello".class # => String
String.class  # => Class
Class.class   # => Class
</code></pre>

<pre><code data-language="ruby"># Classに定義されているインスタンスメソッド
inherited = false
Class.instance_methods(inherited) # => [:superclass, :allocate, :new]
</code></pre>

Classはnew, allocate, superclassを追加したモジュールに過ぎない。

<pre><code data-language="ruby"># Stringのクラス階層
String.superclass     # => Object
Object.superclass     # => BasicObject
BasicObjct.superclass # => nil
</code></pre>

<pre><code data-language="ruby"># Classのクラス階層
Class.superclass      # => Module
Module.superclass     # => Object
Object.superclass     # => BasicObject
BasicObjct.superclass # => nil
</code></pre>

クラス階層とインスタンスの関係をまとめてみる。

    Class <--(class)-- Object
                        |
                        |--> String   <--(class)-- "Hello"
                        |
                        |--> MyClass  <--(class)-- myObj
                        |
                        `--> Module
                             |
                             `--> Class



## 定数

大文字で始まる参照は、クラス名やモジュール名も含めて、すべて定数になる。
定数はモジュールで階層化することができる。名前が同じでもパスが違えば違う定数になる。この階層構造はファイルシステムと似ている。

<pre><code data-language="ruby"># 定数
module A
  B = 'external'
  class C
    B = 'internal'
  end
end

A::B    # => 'external'
A::C::B # => 'internal'
</code></pre>



<pre><code data-language="ruby"># 定数のパス
module A
  B = 'external'
  class C
    B = 'internal'
    # コロン2つで始めれば、絶対パスで指定できる
    ::A::B # => 'external'
  end
  # 内部に書けば相対パスで指定できる
  C::B  # => 'internal'
end
</code></pre>

<pre><code data-language="ruby"># 定数の一覧
A.constants         # => [:B, :C]
Module.constants    # => [:Object, :Module, ...]
</code></pre>

定数は警告が出るけど上書きできる。

<pre><code data-language="ruby"># 定数の上書き
module M
end
module N
end
M = N # warning: already initialized constant M
M     # => N
</code></pre>

### load

<pre><code data-language="ruby"># load
load('foo.rb')        # foo.rbで定義された定数が読み込まれる
load('foo.rb', true)  # 無名モジュールを作成して、foo.rbを取り込むので汚染しない
</code></pre>

load はコードを実行するために使う。
require はライブラリを読み込むために使う。


## その他クラスに関して

Rubyのクラスは慣習としてキャメルケースを使う。

- NG => TEXT
- OK => Text

先にmoduleが定義されてあればclassは定義できない。クラスだったらオープンクラスで上書きできたけど

<pre><code data-language="ruby"># TypeError
module Text
end
class Text # Text is not a class
end
</code></pre>

例えばActionMailerをロードしたら Text モジュールが定義されてしまう。
これを避けるには、自分のネームスペースを作る。

<pre><code data-language="ruby"># 
module Bookworm
  class Text
    # ...
  end
end
</code></pre>

