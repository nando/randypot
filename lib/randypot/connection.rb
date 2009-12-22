require 'rubygems'
require 'httpclient'

class Randypot
  # HTTPClient wrapper
  class Connection
    class Response
      attr_reader :status, :content_type, :body
      def initialize(status, content_type, body)
        @status, @content_type, @body = status, content_type, body
      end
    end

    def initialize(url, user, password)
      @client = HTTPClient.new
      @client.set_auth url, user, password
    end

    def post(url, params)
      response @client.post(url, params)
    end

    def get(url)
      response @client.get(url)
    end

    private
    def response(r)
      Response.new r.status, r.contenttype, r.content
    end
  end
end
