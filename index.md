---
layout: default
title: Index
---

<ul>
{% for post in site.posts limit:20 %}
    <li>
    <a href="{{ post.url }}">
    {{ post.date | date: "%Y-%m-%d" }}
    {{ post.title }}
    </a>
    </li>
{% endfor %}
</ul>

<ul>
{% for p in site.pages %}
    {% if p.title and p.url != '/index.html' %}
    <li>
    <a href="{{ p.url }}">
      {{ p.title }}
    </a>
    </li>
    {% endif %}
{% endfor %}
</ul>

# 書く予定
- kramdown
- rails3

