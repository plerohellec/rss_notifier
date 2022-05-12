#!/usr/bin/env ruby

require 'dotenv/load'
require 'rss_notifier'

parser = RssNotifier::Parser.new
store = RssNotifier::Store.new
pusher = RssNotifier::Pusher.new

whitelist = "macron, inflation, interest rate, france, ukrain, oil price, rally, rebound, stock prices, bonds, unemployment, shanghai, airbus, economy, gdp, pixel 7, microsoft, iphone 14, cloudflare, supply chain, surge, federal reserve, android auto"
item_filter = RssNotifier::ItemFilter.new(whitelist)

Signal.trap("INT") {
  store.age
  store.dump
  puts "All done."
  exit
}

feeds = {
  # rubylang: 'https://www.ruby-lang.org/en/feeds/news.rss',
  'NYTimes' => 'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
  'Hacker News' => 'https://hnrss.org/newest?points=20',
  'CNN' => 'http://rss.cnn.com/rss/cnn_topstories.rss',
  'GN Business' => 'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGx6TVdZU0FtVnVHZ0pWVXlnQVAB',
  'GN All' => 'https://news.google.com/rss',
  'GN Tech' => 'https://news.google.com/rss/topics/CAAqJggKIiBDQkFTRWdvSUwyMHZNRGRqTVhZU0FtVnVHZ0pWVXlnQVAB',
  'GN Reuters' => 'https://news.google.com/rss/search?q=when:6h+allinurl:reuters.com&ceid=US:en&hl=en-US&gl=US',
}

store.load
worker = RssNotifier::Worker.new(parser, store, pusher, item_filter, feeds)
worker.run

