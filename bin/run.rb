#!/usr/bin/env ruby

require 'optparse'
require 'dotenv/load'
require 'rss_notifier'

options = {}
parser = OptionParser.new do |parser|
  parser.banner = "Usage: run.rb [options]"
  parser.on("-h", "--help", "Prints this help") { puts parser; exit 1 }
  parser.on("-c", "--config PATH", String,  "Path to config file") { |cfg|  options[:cfg] = cfg  }
end
parser.parse!

unless options[:cfg]
  puts parser
  exit 1
end

config = YAML.load(File.read(options[:cfg]))
log_dir = config['log_dir']
cache_dir = config['cache_dir']
testing = config['testing']
puts "#{testing ? "TESTING" : "PRODUCTION"} mode is ON"

logger = Logger.new("#{log_dir}/rssn.log")
logger.level = :debug
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.strftime('%H:%M:%S')} #{severity[0]}: #{msg}\n"
end
RssNotifier::Manager.init_logger(logger)

pusher = RssNotifier::Pusher.new(testing)
store = RssNotifier::Store.new(testing ? "#{cache_dir}/test_store.dump" : "#{cache_dir}/store.dump")
hit_counter = RssNotifier::HitCounter.new(testing ? "#{cache_dir}/test_hit_counters.dump" : "#{cache_dir}/hit_counters.dump")

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

