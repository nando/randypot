require 'randypot/version'
require 'randypot/config'
require 'randypot/connection'
require 'randypot/magic_params'
require 'randypot/params_transformer'

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

    def activities_url
      config.service_url + '/activities/'
    end

    def creation(base_params = nil)
      MagicParams.abracadabra(
       [:content_type, :content_source], 
       base_params) do |params|
        params[:activity_type] = 'creation'
        params[:activity_at] = Time.now
        connection.post activities_url, ParamsTransformer.transform(params)
      end
    end

    private
    def connection
      @connection ||= Connection.new(
        config.service_url, config.app_key, config.app_token)
    end
  end
end
