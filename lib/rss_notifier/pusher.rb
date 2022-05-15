module RssNotifier
  class Pusher
    API_URL = 'https://api.pushover.net/1/messages.json'

    def push(item, feed)
      params = {
        token: ENV['PUSHOVER_API_TOKEN'],
        user: ENV['PUSHOVER_API_USER'],
        title: "#{item[:feed_name]} - #{item[:title]}",
        url: url(item, feed),
        message: "#{item[:message]} <p><em>#{item[:pubdate].localtime.strftime("%B %d %H:%M")}</em></p>",
        html: 1,
        priority: 0,
        # timestamp: item[:pubdate].to_i,
      }
      res = Curl.post(API_URL, params.to_json) do |req|
        req.headers['content-type'] = 'application/json'
      end
      raise "Failed pushover push: #{res.response_code} - #{res.body}" unless res.response_code == 200
    end

    def url(item, feed)
      if feed['render_with'] == '68k.news'
        url = item[:url].gsub(/\?.*$/, '')
        url << "?oc=5"
        "http://68k.news/article.php?loc=US&a=#{url}"
      else
        item[:url]
      end
    end
  end
end
