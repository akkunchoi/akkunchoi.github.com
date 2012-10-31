---
layout: posts
title: jQuery Deferred and $(document).ready()
tags: jQuery
---

`$(document).ready()`の後にajaxリクエストすると、レンダリング中にムダに待機してしまいます。

<pre><code data-language="javascript">$(document).ready(function(){
  $.ajax('contents', function(response){
    // process
  });
});
</code></pre>

`ready()`内ではなく、外でajaxリクエストすれば真っ先にリクエストできます。

<pre><code data-language="javascript">$.ajax('contents', function(response){
  // process?
});
$(document).ready(function(){
  // process?
});
</code></pre>

しかしこれでは ajax リクエストの完了と ready になった後に実行するというのが難しくなります。無理やり実装するならばこんな感じでしょうか。

<pre><code data-language="javascript">var ajaxDone = false, ready = false;
$.ajax('contents', function(response){
  if (ready){
    // process
  }
  ajaxDone = true;
});
$(document).ready(function(){
  if (ajaxDone){
    // process
  }
  ready = true;
});
</code></pre>

カッコ悪いですし、ajaxリクエストが増えた場合に面倒ですね。

このようなコールバックのフローを上手く扱うには [jQuery.Deferred] を使います。この場合、次のように記述することができます。

<pre><code data-language="javascript">var ready = $.Deferred();
$(document).ready(ready.resolve);
$.when(ready, $.ajax('contents')).then(function($, response) {
  // process
});
</code></pre>


参考: <http://stackoverflow.com/questions/6177187/can-i-get-a-jquery-deferred-on-document-ready>

[jQuery.Deferred]: http://api.jquery.com/category/deferred-object/
