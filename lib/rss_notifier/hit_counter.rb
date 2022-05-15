module RssNotifier
  class HitCounter
    def initialize(throttle_config, dump_filename = nil)
      @dump_filename = dump_filename
      @throttle_config = throttle_config

      @buckets = {}
    end

    def too_many?(keyword, throttle_type)
      raise "Unknow throttle_type #{throttle_type}" unless @throttle_config[throttle_type]
      k = keyword.downcase
      @buckets[k] ||= LeakyBucket.new(k, @throttle_config[throttle_type]['max_hits'],
                                         @throttle_config[throttle_type]['period_hours'])
      @buckets[k].too_many?
    end

    def dump
      unless @dump_filename
        puts "Not dumping hit counters since filename is nil"
        return
      end

      File.write(@dump_filename, Marshal.dump(@buckets))
      puts "Dumped hit counters to #{@dump_filename} (#{@buckets.size} items)"
    end

    def load
      return unless File.exists?(@dump_filename)
      @buckets = Marshal.load(File.read(@dump_filename))
      puts "Loaded hit counters from #{@dump_filename} (#{@buckets.size} items)"
    end
  end

  class LeakyBucket
    def initialize(keyword, max_hits, period_hours)
      @keyword = keyword
      @max_hits = max_hits
      @period_hours = period_hours
      @bucket = []
    end

    def too_many?
      age
      return true if @bucket.size >= @max_hits
      @bucket << Time.now
      puts "Added hit to \"#{@keyword}\" [#{@max_hits}/#{@period_hours}] bucket (size=#{@bucket.size})"
      false
    end

    def age
      @bucket.delete_if { |t| t < Time.now - @period_hours * 3600 }
    end
  end
end