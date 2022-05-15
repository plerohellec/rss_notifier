module RssNotifier
  class Manager
    def initialize(config_file, store, pusher, hit_counter)
      @config_file = config_file
      @store = store
      @pusher = pusher
      @hit_counter = hit_counter
      @skipped = Store.new
    end

    def run
      while (true) do
        puts "working... (#{Time.now.strftime("%B %d %H:%M")})"
        config = YAML.load(File.read(@config_file))
        pushed = []
        item_filter = ItemFilter.new(config['keywords'])
        config['feeds'].each do |feed|
          puts "\033[4mProcessing #{feed['name']}\033[0m"
          worker = Worker.new(feed, @store, @pusher, item_filter, @skipped, pushed, @hit_counter)
          worker.run
        end
        puts
        @skipped.age
        sleep config['poll_period_seconds']
      end
    end
  end
end
