source "https://rubygems.org"
# gem "jekyll", "~> 3.8.5"
gem "jekyll", "~> 4.0.0", group: :jekyll_plugins

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-gist", "~> 1.5.0"
  gem "jekyll-paginate", "~> 1.1.0"
end

install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :install_if => Gem.win_platform?

