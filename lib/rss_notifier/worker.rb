module RssNotifier
  class Worker
    def initialize(feed, store, pusher, item_filter, skipped, pushed)
      @feed = feed
      @store = store
      @pusher = pusher
      @item_filter = item_filter
      @skipped = skipped
      @pushed = pushed
    end

    def run
      max = 2

      Parser.new.run(@feed['name'], @feed['url']) do |item|
        break if @pushed.size > max
        next if @store.exists?(item)
        next unless item[:pubdate] > Time.now - 7200
        next if @skipped.exists?(item)

        if @item_filter.skip?(item)
          puts "Skipping #{item[:pubdate].localtime.strftime("%B %d %H:%M")} \"#{item[:title]}\""
          @skipped.add(item)
          next
        end

        @store.add(item)
        puts "\033[1mPushing\033[0m #{item[:pubdate].localtime.strftime("%B %d %H:%M")} \"#{item[:title]}\""
        @pusher.push(item, @feed)
        @pushed << item
      end
    end
  end
end
