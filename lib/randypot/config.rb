class Randypot
  class Config
    attr_accessor :service_url, :app_key, :app_token
    
    def initialize
      @service_url = "http://garden.kandypot.com/api"
    end
    
    def configure(&block)
      yield(self)
    end
  end
end
