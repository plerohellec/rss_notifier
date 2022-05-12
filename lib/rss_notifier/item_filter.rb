module RssNotifier
  class ItemFilter
    def initialize(whitelist)
      whitelist_terms = whitelist.split(',').map(&:strip)
      @regex = /(?:#{whitelist_terms.join('|')})/i
    end

    def keep?(item)
      @regex.match(item[:title])
    end

    def skip?(item)
      !keep?(item)
    end
  end
end