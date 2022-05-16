#!/usr/bin/env ruby

require 'dotenv/load'
require 'rss_notifier'

config = YAML.load(File.read('config.yml'))

testing = false
puts "#{testing ? "TESTING" : "PRODUCTION"} mode is ON"

pusher = RssNotifier::Pusher.new(testing)
store = RssNotifier::Store.new(testing ? 'test_store.dump' : 'store.dump')
hit_counter = RssNotifier::HitCounter.new(testing ? 'test_hit_counters.dump' : 'hit_counters.dump')

Signal.trap("INT") {
  store.age
  store.dump
  hit_counter.dump
  puts "All done."
  exit
}

store.load
hit_counter.load
manager = RssNotifier::Manager.new('config.yml', store, pusher, hit_counter)
manager.run

