<span class="post-date">
    {{ post.date | date_to_string }}@<a href="/c/{{ category }}">{{ category }}</a>
    {% for tag in post.tags %}<span class="tag">#{{ tag }}</span>{% endfor %}
</span>