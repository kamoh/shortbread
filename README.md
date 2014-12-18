==

Shortbread

A delicious URL shortener. See it live at http://shrtb.red.
====

Setup

Set up the database

``` ruby
rake db:migrate
```

Set up your gems

``` ruby
bundle install
```

This app uses Postgres for database.

You'll need a domain to point shortened links to. In link.rb, replace `URL_BASE = "shrtb.red/"` with whatever domain you want to serve shortened URLs from.

Shortened URLs are case-sensitive, so bear that in mind.

The site tracks the top 100 most visited links. You can adjust this in the constant `MOST_VISITED_LIMIT` in link.rb.

