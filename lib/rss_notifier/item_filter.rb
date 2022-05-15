module RssNotifier
  class ItemFilter
    def initialize(whitelist)
      whitelist_terms = whitelist.split(',').map(&:strip)
      @regex = /(?:#{whitelist_terms.join('|')})/i
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