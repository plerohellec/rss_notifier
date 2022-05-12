module RssNotifier
  class Manager
    def initialize(config_file, store, pusher)
      @config_file = config_file
      @store = store
      @pusher = pusher
      @skipped = {}
    end

    def run
      while (true) do
        puts "working..."
        config = YAML.load(File.read(@config_file))
        pushed = []
        item_filter = ItemFilter.new(config['whitelist'])
        config['feeds'].each do |feed|
          puts "\033[4mProcessing #{feed['name']}\033[0m"
          worker = Worker.new(feed['name'], feed['url'], @store, @pusher, item_filter, @skipped, pushed)
          worker.run
        end
        puts
        age_skipped
        sleep 300
      end
    end

    def age_skipped
      @skipped.delete_if { |guid, date| date < Time.now - 86400 }
    end
  end
end
