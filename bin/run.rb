#!/usr/bin/env ruby

require 'dotenv/load'
require 'rss_notifier'

config = YAML.load(File.read('config.yml'))

store = RssNotifier::Store.new
pusher = RssNotifier::Pusher.new
hit_counter = RssNotifier::HitCounter.new(config['throttle']['max_hits'], config['throttle']['period_hours'])

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

