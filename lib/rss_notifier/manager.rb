module RssNotifier
  class Manager
    def initialize(config_file, store, pusher)
      @config_file = config_file
      @store = store
      @pusher = pusher
      @skipped = Store.new
    end

    def run
      while (true) do
        puts "working... (#{Time.now.strftime("%B %d %H:%M")})"
        config = YAML.load(File.read(@config_file))
        pushed = []
        item_filter = ItemFilter.new(config['whitelist'])
        config['feeds'].each do |feed|
          puts "\033[4mProcessing #{feed['name']}\033[0m"
          worker = Worker.new(feed['name'], feed['url'], @store, @pusher, item_filter, @skipped, pushed)
          worker.run
        end
        puts
        @skipped.age
        sleep 600
      end
    end
  end
end
