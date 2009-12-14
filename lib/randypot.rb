require 'randypot/version'
require 'randypot/config'

class Randypot
  def initialize(config_file = nil, &block)
    Randypot.configure config_file, &block
  end

  class << self
    def config
      @config ||= Config.new
    end
    
    def configure(config_file = nil, &block)
      config.configure config_file, &block
    end
  end
end
