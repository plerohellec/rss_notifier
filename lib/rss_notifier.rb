# frozen_string_literal: true

require 'rss'
require 'open-uri'
require 'awesome_print'
require 'curb'
require 'json'
require 'yaml'
# require 'logger'

require_relative "rss_notifier/version"
require_relative "rss_notifier/logging"
require_relative "rss_notifier/manager"
require_relative "rss_notifier/parser"
require_relative "rss_notifier/store"
require_relative "rss_notifier/worker"
require_relative "rss_notifier/pusher"
require_relative "rss_notifier/item_filter"
require_relative "rss_notifier/hit_counter"

module RssNotifier
  class Error < StandardError; end
  # Your code goes here...
end
