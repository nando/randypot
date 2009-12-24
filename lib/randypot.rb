$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))
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
      activity 'creation', base_params, [:content_type, :content_source]
    end

    def reaction(base_params = nil)
      activity 'reaction', base_params, [:category, :content_type, :content_source]
    end

    def relationship(base_params = nil)
      activity 'relationship', base_params, :category
    end

    private
    def connection
      @connection ||= Connection.new(
        config.service_url, config.app_key, config.app_token)
    end

    def activity(type, base_params, magic_keys)
      MagicParams.abracadabra(magic_keys, base_params) do |params|
        params[:activity_type] = type
        params[:activity_at] = Time.now
        connection.post activities_url, ParamsTransformer.transform(params)
      end
    end
  end
end
