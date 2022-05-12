module RssNotifier
  class Worker
    def initialize(parser, store, pusher, item_filter, feeds)
      @parser = parser
      @feeds = feeds
      @store = store
      @pusher = pusher
      @item_filter = item_filter
      @skipped = {}
    end

    def run
      max = 2
      pushed = 0
      while (true) do
        puts "working..."
        pushed = 0
        @feeds.each do |name, url|
          puts "\033[4mProcessing #{name}\033[0m"
          @parser.run(name, url) do |item|
            break if pushed > max
            next if @store.exists?(item)
            next unless item[:pubdate] > Time.now - 7200
            next if @skipped[item[:guid]]

            if @item_filter.skip?(item)
              puts "Skipping #{item[:pubdate].localtime.strftime("%B %d %H:%M")} \"#{item[:title]}\" (whitelist)"
              @skipped[item[:guid]] = item[:pubdate]
              next
            end

            @store.add(item)
            puts "\033[1mPushing\033[0m #{item[:pubdate].localtime.strftime("%B %d %H:%M")} \"#{item[:title]}\""
            @pusher.push(item)
            pushed += 1
          end
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
