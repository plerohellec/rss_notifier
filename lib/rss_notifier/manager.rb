module RssNotifier
  class Manager
    include Logging

    def initialize(config_file, store, pusher, hit_counter)
      @config_file = config_file
      @store = store
      @pusher = pusher
      @hit_counter = hit_counter
      @skipped = Store.new
    end

    def run
      while (true) do
        logger.info "working... (#{Time.now.strftime("%B %d %H:%M")})"
        File.open('storage/log/foo.log', 'a') { |f| f.write "working... (#{Time.now.strftime("%B %d %H:%M")})\n" }

        config = YAML.load(File.read(@config_file))
        pushed = []
        item_filter = ItemFilter.new(config['keywords'])
        config['feeds'].each do |feed|
          logger.info "\033[4mProcessing #{feed['name']}\033[0m"
          worker = Worker.new(feed, @store, @pusher, item_filter, @skipped, pushed,
                              @hit_counter, config['throttles'])
          worker.run
        end
        logger.info ""
        @skipped.age
        sleep config['poll_period_seconds']
      end
    end
  end
end
