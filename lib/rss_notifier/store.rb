module RssNotifier
  class Store
    def initialize
      @store = { guids: {}, titles: {} }
    end

    def add(item)
      @store[:guids][item[:guid]] = item[:pubdate]
      @store[:titles][item[:title]] = item[:pubdate]
    end

    def exists?(item)
      @store[:guids][item[:guid]] || @store[:titles][item[:title]]
    end

    def dump
      File.write('store.dump', Marshal.dump(@store))
      puts "Dumped store to store.dump (#{@store[:guids].size} items)"
    end

    def age
      @store[:guids].delete_if { |guid, date| date < Time.now - 3600*6 }
      @store[:titles].delete_if { |title, date| date < Time.now - 3600*6 }
    end

    def load
      return unless File.exists?('store.dump')
      @store = Marshal.load(File.read('store.dump'))
      unless @store[:guids]
        @orig = @store.dup
        @store = { guids: {}, titles: {} }
        @store[:guids] = @orig
      end
      puts "Loaded store from store.dump (#{@store[:guids].size} items)"
    end
  end
end
