ignore "/templates/*"

activate :caching_proxy, cache_key: "my-cache-key"

content = "I've got the right content"

proxy_with_cache(
  path: "/proxied.html",
  template: "/templates/page_template.html",
  proxy_options: {locals: {content: content}, ignore: true},
  fingerprint: "fingerprint"
)

