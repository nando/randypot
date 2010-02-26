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
      headers = cache ? {'If-None-Match' => cache.etag} : {}
      response @client.get(url, nil, headers)
    end

    private
    def response(r)
      Response.new :status => r.status,
        :content_type => r.contenttype,
        :body => r.content,
        :etag => etag(r.header)
    end

    def etag(headers)
      if headers['etag'] && raw = headers['etag'].first
        # ETag quotes cleaning:
        # "\"5d42b5fbf5aa3064d\"" => "5d42b5fbf5aa3064d"
        raw[1..-2]
      end
    end
  end
end
