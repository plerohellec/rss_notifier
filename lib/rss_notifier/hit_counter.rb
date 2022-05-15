module RssNotifier
  class HitCounter
    DUMP_FILENAME = 'hit_counters.dump'

    def initialize(max_hits, period_hours)
      @max_hits = max_hits
      @period_hours = period_hours
      @buckets = {}
    end

    def too_many?(keyword)
      k = keyword.downcase
      @buckets[k] ||= LeakyBucket.new(k, @max_hits, @period_hours)
      @buckets[k].too_many?
    end

    def dump
      File.write(DUMP_FILENAME, Marshal.dump(@buckets))
      puts "Dumped hit counters to #{DUMP_FILENAME} (#{@buckets.size} items)"
    end

    def load
      return unless File.exists?(DUMP_FILENAME)
      @buckets = Marshal.load(File.read(DUMP_FILENAME))
      puts "Loaded hit counters from #{DUMP_FILENAME} (#{@buckets.size} items)"
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
      puts "Added hit to #{@keyword} bucket (size=#{@bucket.size})"
      false
    end

    def age
      @bucket.delete_if { |t| t < Time.now - @period_hours * 3600 }
    end
  end
end