<!DOCTYPE html>
<html lang="en-us">
  {% include head.html %}
  <body>
    {% include sidebar.md %}
    <div class="content container">
      {{ content }}
    </div>
  </body>
  <script>
    (function() {
      function strikethrough(){
        document.body.innerHTML = document.body.innerHTML.replace(
          /\~\~(.+?)\~\~/gim,
          '<del>$1</del>'
        );
      }
      strikethrough();
    })();
  </script>
  <script async src="https://www.googletagmanager.com/gtag/js?id=UA-10997184-11"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());

    gtag('config', 'UA-10997184-11');
  </script>
</html>
