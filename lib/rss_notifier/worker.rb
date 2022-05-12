module RssNotifier
  class Worker
    def initialize(feed_name, feed_url, store, pusher, item_filter, skipped, pushed)
      @feed_name = feed_name
      @feed_url = feed_url
      @store = store
      @pusher = pusher
      @item_filter = item_filter
      @skipped = skipped
      @pushed = pushed
    end

    def run
      max = 2

      Parser.new.run(@feed_name, @feed_url) do |item|
        break if @pushed.size > max
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
        @pushed << item
      end
    end
  end
end
