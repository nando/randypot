require 'rubygems'
require 'httpclient'

class Randypot
  class Connection
    def initialize(url, user, password)
      @client = HTTPClient.new
      @client.set_auth url, user, password
    end

    def post(url, params)
      @client.post url, params
    end

    def get(url)
      @client.get url
    end
  end
end
