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
      <a class="sidebar-nav-item" target="_blank" href="https://github.com/unixslayer">
        <img alt="GitHub followers" src="https://img.shields.io/github/followers/unixslayer?color=181717&label=github&style=for-the-badge&logo=github">
      </a>
      <a class="sidebar-nav-item" target="_blank" href="https://hub.docker.com/u/unixslayer">
        <img alt="DockerHub" src="https://img.shields.io/badge/docker-%23555555?style=for-the-badge&logo=docker" />
      </a>
      <a class="sidebar-nav-item" target="_blank" href="https://twitter.com/kicek_">
        <img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/kicek_?color=1DA1F2&label=twitter&style=for-the-badge&logo=twitter">
      </a>
      <a class="sidebar-nav-item" target="_blank" href="https://keybase.io/unixslayer">
        <img alt="Keybase PGP" src="https://img.shields.io/keybase/pgp/unixslayer?color=33A0FF&style=for-the-badge&logo=keybase">
      </a>
      <span class="copy">&copy; {{ site.time | date: '%Y' }}. All rights reserved.</span>
    </nav>
  </div>
</div>
