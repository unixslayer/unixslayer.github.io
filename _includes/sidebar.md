<div class="sidebar">
  <div class="container sidebar-sticky sidebar-sticky-top">
    <nav class="sidebar-nav">
      <a class="sidebar-nav-item{% if page.url == site.baseurl %} active{% endif %}" href="{{ site.baseurl }}/">Home</a>
      <br/>
      <a class="sidebar-nav-item{% if page.url == "articles" %} active{% endif %}" href="{{ site.baseurl }}/c/tech">Tech</a>
      <a class="sidebar-nav-item{% if page.url == "articles" %} active{% endif %}" href="{{ site.baseurl }}/c/diary">Diary</a>
      <br/>
      <a class="sidebar-nav-item{% if page.url == "articles" %} active{% endif %}" href="{{ site.baseurl }}/c/true-events">Based on true events</a>
      <br/>
      <a class="sidebar-nav-item{% if page.url == "articles" %} active{% endif %}" href="{{ site.baseurl }}/about">My work</a>
    </nav>
  </div>

  <div class="container sidebar-sticky sidebar-sticky-bottom">
    <nav class="sidebar-nav">
      <a class="sidebar-nav-item" target="_blank" href="https://github.com/unixslayer">github</a>
      <a class="sidebar-nav-item" target="_blank" href="https://hub.docker.com/u/unixslayer">docker</a>
      <a class="sidebar-nav-item" target="_blank" href="https://twitter.com/kicek_">twitter</a>
      <a class="sidebar-nav-item" target="_blank" href="https://keybase.io/unixslayer">keybase</a>
      <span class="copy">&copy; {{ site.time | date: '%Y' }}. All rights reserved.</span>
    </nav>
  </div>
</div>
