require 'randypot/version'
require 'randypot/config'

class Randypot
  def initialize(&block)
    Randypot.configure &block
  end

  class << self
    def config
      @config ||= Config.new
    end
    
    def configure(&block)
      config.configure &block
    end
  end
end
