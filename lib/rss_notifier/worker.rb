module RssNotifier
  class Worker
    def initialize(feed, store, pusher, item_filter, skipped, pushed, hit_counter)
      @feed = feed
      @store = store
      @pusher = pusher
      @item_filter = item_filter
      @skipped = skipped
      @pushed = pushed
      @hit_counter = hit_counter
    end

    def run
      max = 2

      Parser.new.run(@feed['name'], @feed['url']) do |item|
        break if @pushed.size > max
        next if @store.exists?(item)
        next unless item[:pubdate] > Time.now - 7200
        next if @skipped.exists?(item)

        label = "#{item[:pubdate].localtime.strftime("%B %d %H:%M")} \"#{item[:title]}\""

        hit = @item_filter.keep?(item)
        unless hit
          puts "Skipping #{label}"
          @skipped.add(item)
          next
        end
        if @hit_counter.too_many?(hit)
          puts "Throttling keyword #{hit} - #{label}"
          next
        end

        @store.add(item)
        puts "\033[1mPushing\033[0m #{label}"
        @pusher.push(item, @feed)
        @pushed << item
      end
    end
  end
end
