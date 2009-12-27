require 'rubygems'
require 'httpclient'

class Randypot
  # HTTPClient wrapper
  class Connection
    def initialize(url, user, password)
      @client = HTTPClient.new
      @client.set_auth url, user, password
    end

    def post(url, params)
      response @client.post(url, params)
    end

    def get(url, cache = nil)
      response @client.get(url, nil, cache && {'If-None-Match' => cache.etag})
    end

    private
    def response(r)
      Response.new :status => r.status,
        :content_type => r.contenttype,
        :body => r.content,
        :etag => etag(r.header)
    end

    def etag(headers)
      headers['etag'] && headers['etag'].first
    end
  end
end
