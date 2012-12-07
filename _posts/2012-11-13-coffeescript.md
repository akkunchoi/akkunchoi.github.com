---
layout: posts
title: Coffeescript
tags: coffeescript javascript
---

JavaScripter が [CoffeeScript] に移行する際の要点をまとめ。

## 関数定義は ->

`function` と `{` と `}` は消します。代わりに `->` を入れます。

<pre><code data-language="javascript"> // javascript
var square;
square = function(x) {
      return x * x;
};
</code></pre>

<pre><code data-language="coffeescript"> # coffeescript
square = (x) -> x * x
</code></pre>

タイプ数減りますね。

## クラス定義

<pre><code data-language="javascript"> // javascript
var Animal;
Animal = (function() {

  function Animal(name) {
    this.name = name;
  }

  Animal.prototype.move = function(meters) {
    return alert(this.name + (" moved " + meters + "m."));
  };

  return Animal;

})();
</code></pre>

<pre><code data-language="coffeescript"> # coffeescript
class Animal
  constructor: (@name) ->

  move: (meters) ->
    alert @name + " moved #{meters}m."
</code></pre>

クラスの定義方法を統一させることができるのは良いかも。

`@name` は ruby の インスタンス変数のような感じです。
しかし、`constructor: (@name) ->` この一行で `this.name` にセットされるのはなんだかキモいです。

継承もできます。

## thisの束縛は =>

<pre><code data-language="javascript"> // javascript
var _this = this;
$.each([1, 2, 3, 4, 5], function(k, v) {
  _this.moge(v);
});
</code></pre>

<pre><code data-language="coffeescript"> # coffeescript
$.each [1,2,3,4,5], (k,v) =>
  this.moge(v)
</code></pre>

もう `var self = this;` なんて書かなくて良い！

## 関数呼び出しは、引数がある場合は（）を省略可能

Rubyのノリです。

ただし、引数がない関数の場合は `()` が必要（プロパティ呼び出しと区別がつかないからだろう）。

## 最後の式はreturnする

Rubyのノリです。

## インデント重要

Pythonのノリです。

## その他

- セミコロンは不要。あってもエラーにはならない

[CoffeeScript]: <http://coffeescript.org/>

