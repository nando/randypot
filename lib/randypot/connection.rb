require 'rubygems'
require 'httpclient'

class Randypot
  # HTTPClient wrapper
  class Connection
    class Response
      attr_reader :status, :content_type, :body, :etag
      def initialize(status, content_type, body, etag)
        @status, @content_type, @body, @etag = status, content_type, body, etag
      end
      def not_modified?
        status == 304
      end
    end

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
      Response.new r.status, r.contenttype, r.content, etag(r.header)
    end

    def etag(headers)
      headers['etag'] && headers['etag'].first
    end
  end
end
