module RssNotifier
  class Parser
    def run(feed_name, url, &block)
      URI.open(url) do |rss|
        feed = RSS::Parser.parse(rss)
        items = feed.items.reject { |i| i.pubDate.nil? }
        items.sort_by(&:pubDate).reverse.each do |item|
          info = {
            feed_name: feed_name,
            title: item.title,
            message: item.description,
            url: item.link,
            guid: item.guid.content,
            pubdate: item.pubDate
          }
          yield info
        end
      end
    rescue OpenURI::HTTPError => e
      puts "Failed to open #{url} - #{e.to_s}"
    end
  end
end
