require 'yaml'

class Randypot
  class Config
    CONFIG_YAMLS = [ # IN ORDER OF RELEVANCE
      'randypot.yml',
      '~/.randypot/configuration.yml',
      '/etc/randypot/configuration.yml'
    ].reverse.map {|f| File.expand_path(f)}
    attr_accessor :service_url, :app_key, :app_token
    
    def initialize
      @service_url = "http://garden.kandypot.com/api"
      CONFIG_YAMLS.find_all{|f| File.file? f}.each do |yaml|
        load_from_yaml yaml
      end
    end
    
    def configure(config_file = nil, &block)
      if config_file
        load_from_yaml config_file
      else
        yield(self)
      end
    end

    private
      def load_from_yaml(file)
        cfg = YAML.load(File.read(file))["kandypot_server"]
        @service_url = cfg["service_url"] if cfg["service_url"]
        @app_key = cfg["app_key"] if cfg["app_key"]
        @app_token = cfg["app_token"] if cfg["app_token"]
      end
  end
end
