module RssNotifier
  class Store
    include Logging

    def initialize(dump_filename=nil)
      @dump_filename = dump_filename
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
      unless @dump_filename
        puts "Not dumping store since filename is nil"
        return
      end

      File.write(@dump_filename, Marshal.dump(@store))
      puts "Dumped store to #{@dump_filename} (#{@store[:guids].size} items)"
    end

    def age
      @store[:guids].delete_if { |guid, date| date < Time.now - 3600*24 }
      @store[:titles].delete_if { |title, date| date < Time.now - 3600*24 }
    end

    def load
      return unless File.exists?(@dump_filename)
      @store = Marshal.load(File.read(@dump_filename))
      unless @store[:guids]
        @orig = @store.dup
        @store = { guids: {}, titles: {} }
        @store[:guids] = @orig
      end
      logger.info "Loaded store from #{@dump_filename} (#{@store[:guids].size} items)"
    end
  end
end
