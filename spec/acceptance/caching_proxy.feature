Feature: Caching Proxy Pages
  In order to avoid regenerating everything

  Scenario: A fresh proxy
    Given a successfully built app at "uncached-project"
    When I cd to "build"
    Then the file "proxied.html" should contain "I've got the right content"

  Scenario: A cached proxy
    Given a successfully built app at "cached-project"
    When I cd to "build"
    Then the file "proxied.html" should contain "I've got the right content"

  Scenario: A cached proxy with existing build
    Given a successfully built app at "built-cached-project"
    When I cd to "build"
    Then the file "proxied.html" should contain "I've got the right content"

  Scenario: Updated data
    Given a successfully built app at "outdated-data"
    When I cd to "build"
    Then the file "proxied.html" should contain "I've got updated content"

  Scenario: Updated cache key
    Given a successfully built app at "outdated-key"
    When I cd to "build"
    Then the file "proxied.html" should contain "This is the new layout"
