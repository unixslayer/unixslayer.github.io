{% assign category = post.categories | first %}

<div class="post">
    <h1 class="post-title">
      <a href="{{ post.url }}">
        {{ post.title }}
      </a>
    </h1>
    {% include post-date.md %}
    {{ post.excerpt }}
</div>