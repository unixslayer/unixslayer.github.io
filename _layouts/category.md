---
layout: default
---

{% if page.description != "" %}
<blockquote>
  <p>{{ page.description }}</p>
</blockquote>
{% endif %}

<div class="posts">
    {% for post in site.categories[page.tag] %}
        {% include post-excerpt.md %}
    {% endfor %}
</div>