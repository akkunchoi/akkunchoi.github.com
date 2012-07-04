---
layout: default
title: Index
---

# Flows

<ul>
{% for post in site.posts limit:5 %}
    <li>
    <a href="{{ post.url }}">
    {{ post.date | date: "%Y-%m-%d" }}
    {{ post.title }}
    </a>
    </li>
{% endfor %}
</ul>

# Stocks
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

# Coming soon
- kramdown
- rbenv/ruby-build

