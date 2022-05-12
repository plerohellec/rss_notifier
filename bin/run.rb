#!/usr/bin/env ruby

require 'dotenv/load'
require 'rss_notifier'

store = RssNotifier::Store.new
pusher = RssNotifier::Pusher.new

Signal.trap("INT") {
  store.age
  store.dump
  puts "All done."
  exit
}

store.load
manager = RssNotifier::Manager.new('config.yml', store, pusher)
manager.run

