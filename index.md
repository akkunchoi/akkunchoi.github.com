---
layout: default
title: Index
---

- [Profile](/profile.html)

## おすすめ

わりと気合入れて書きました

- [rails3-routes](/rails3-routes.html)
- [Gitリファレンス](/git-ref.html)
- [Composer](/composer.html)

## 最新

{% for post in site.posts limit:5 %}
- [{{ post.title }}]({{ post.url }}){% endfor %}


## タグ

<ul>
{% for tag in site.tags limit: 10 %} 
  <li><a href="/tag/{{ tag[0] }}/index.html">{{ tag[0] }} <span>{{ tag[1].size }}</span></a></li>
{% endfor %}
  <li><a href="/tag/index.html" class="more">more..</a></li>
</ul>


