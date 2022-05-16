module RssNotifier
  class HitCounter
    def initialize(dump_filename = nil)
      @dump_filename = dump_filename
      @buckets = {}
    end

    def too_many?(keyword, throttle_type, throttle_config)
      raise "Unknow throttle_type #{throttle_type}" unless throttle_config[throttle_type]
      k = keyword.downcase
      @buckets[k] ||= LeakyBucket.new(k)
      @buckets[k].too_many?(throttle_config[throttle_type]['max_hits'],
                            throttle_config[throttle_type]['period_hours'])
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
    def initialize(keyword)
      @keyword = keyword
      @bucket = []
    end

    def too_many?(max_hits, period_hours)
      age(period_hours)

      return true if @bucket.size >= max_hits
      @bucket << Time.now
      puts "Added hit to \"#{@keyword}\" [#{max_hits}/#{period_hours}] bucket (size=#{@bucket.size})"
      false
    end

    def age(period_hours)
      @bucket.delete_if { |t| t < Time.now - period_hours * 3600 }
    end
  end
end