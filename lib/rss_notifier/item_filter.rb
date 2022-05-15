module RssNotifier
  class ItemFilter
    def initialize(keywords_config)
      @filters = []
      keywords_config.each do |cfg|
        terms = cfg['list'].split(',').map(&:strip)
        regex = /(?:#{terms.join('|')})/i
        @filters << { regex: regex, throttle: cfg['throttle'] }
      end
    end

    def keep?(item)
      @filters.each do |filter|
        if res = filter[:regex].match(item[:title])
          return res[0], filter[:throttle]
        end
      end
      nil
    end

    def skip?(item)
      keep?(item).nil?
    end
  end
end