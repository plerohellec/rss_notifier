#!/usr/bin/env ruby

require 'optparse'
require 'dotenv/load'
require 'rss_notifier'

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: run.rb [options]"
  parser.on("-c", "--config [PATH]", String,  "Path to config file") { |cfg|  options[:cfg] = cfg  }
end.parse!

config = YAML.load(File.read(options[:cfg]))

testing = config['testing']
puts "#{testing ? "TESTING" : "PRODUCTION"} mode is ON"

logger = Logger.new('rssn.log')
logger.level = :debug
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.strftime('%H:%M:%S')} #{severity[0]}: #{msg}\n"
end
RssNotifier::Manager.init_logger(logger)

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
manager = RssNotifier::Manager.new(options[:cfg], store, pusher, hit_counter)
manager.run

