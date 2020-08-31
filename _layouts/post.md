---
layout: default
---

{% assign category = page.categories[0] %}
{% assign post = page %}

<div class="post">
  <h1 class="post-title">{{ page.title }}</h1>
  {% include post-date.md %}

  {{ content }}

  <div class="tweet">
    <p>
      Found this article useful and worthy? Please <a rel="me" href="https://twitter.com/intent/tweet?url={{ site.url }}{{ page.url }}&text={{ page.title | uri_escape}}" onclick="window.open(this.href);return false;">tweet</a> about it.
    </p>
  </div>
</div>

<div class="pagination">
  {% if page.previous.url %}
    <a class="pagination-item older" href="{{page.previous.url}}">&laquo; {{page.previous.title}}</a>
  {% endif %}
  {% if page.next.url %}
    <a class="pagination-item newer" href="{{page.next.url}}">{{page.next.title}} &raquo;</a>
  {% endif %}
</div>

<div id="disqus_thread"></div>
<script>
(function() { // DON'T EDIT BELOW THIS LINE
var d = document, s = d.createElement('script');
s.src = 'https://unixslayer.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
