module RssNotifier
  class Worker
    include Logging

    def initialize(feed, store, pusher, item_filter, skipped, pushed, hit_counter, throttle_config)
      @feed = feed
      @store = store
      @pusher = pusher
      @item_filter = item_filter
      @skipped = skipped
      @pushed = pushed
      @hit_counter = hit_counter
      @throttle_config = throttle_config
    end

    def run
      max = 2

      Parser.new.run(@feed['name'], @feed['url']) do |item|
        break if @pushed.size > max
        next if @store.exists?(item)
        next unless item[:pubdate] > Time.now - 7200
        next if @skipped.exists?(item)

        label = "#{item[:pubdate].localtime.strftime("%H:%M")} \"#{item[:title]}\""

        hit, throttle = @item_filter.keep?(item)
        unless hit
          logger.debug "Skip #{label}"
          @skipped.add(item)
          next
        end
        if @hit_counter.too_many?(hit, throttle, @throttle_config)
          logger.debug "Throttling keyword \"#{hit}\" (t=#{throttle}) - #{label}"
          next
        end

        @store.add(item)
        logger.info "\033[1mPushing\033[0m #{label}"
        @pusher.push(item, @feed)
        @pushed << item
      end
    end
  end
end
