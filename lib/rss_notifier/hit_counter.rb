module RssNotifier
  class HitCounter
    def initialize(dump_filename, max_hits, period_hours)
      @dump_filename = dump_filename
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
      puts "Added hit to #{@keyword} bucket (size=#{@bucket.size})"
      false
    end

    def age
      @bucket.delete_if { |t| t < Time.now - @period_hours * 3600 }
    end
  end
end