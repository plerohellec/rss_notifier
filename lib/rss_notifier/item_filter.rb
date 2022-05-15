module RssNotifier
  class ItemFilter
    def initialize(keywords)
      terms = keywords.split(',').map(&:strip)
      @regex = /(?:#{terms.join('|')})/i
    end

    def keep?(item)
      if res = @regex.match(item[:title])
        return res[0]
      end
    end

    def skip?(item)
      !keep?(item)
    end
  end
end