module RssNotifier
  module Logging
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def init_logger(logger)
        @@logger = logger
      end

      def logger
        raise "You must set the logger instance first." unless defined?(@@logger)
        @@logger
      end
    end

    def logger
      self.class.logger
    end
  end
end
