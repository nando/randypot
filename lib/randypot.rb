$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'randypot/version'
require 'randypot/config'
require 'randypot/response'
require 'randypot/connection'
require 'randypot/magic_params'
require 'randypot/params_transformer'
require 'randypot/cache'

class Randypot
  attr_accessor :member

  def initialize(params = nil, &block)
    options = if params.is_a?(Hash)
      params
    else
      {:member => params}
    end
    if options[:config] or block_given?
      Randypot.configure(options[:config], &block)
    end
    @member = options[:member]
  end

  def creates(params = nil)
    Randypot.send :activity, 'creation', params,
      [:content_type, :content_source, :content], :member => member
  end

  def reacts(params = nil)
    Randypot.send :activity, 'reaction', params,
      [:category, :content_type, :content_source, :content], :member => member
  end

  def relationships(params = nil)
    Randypot.send :activity, 'relationship', params,
      [:category, :member_b], :member => member
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

    def members_url
      config.service_url + '/members/'
    end

    def member_url(id)
      members_url + Digest::MD5.hexdigest(id)
    end

    def creation(base_params = nil)
      activity 'creation', base_params, [:content_type, :content_source]
    end

    def reaction(base_params = nil)
      activity 'reaction', base_params,
        [:category, :content_type, :content_source]
    end

    def relationship(base_params = nil)
      activity 'relationship', base_params, :category
    end

    def members
      cached_request(members_url) do |response|
        response.parse do |body|
          body.split("\n").map do |line|
            hash, candies, updated_at = line.split(',')
            Struct.new(:hash, :candies, :updated_at).new(
              hash, candies.to_i, Time.parse(updated_at))
          end
        end
      end
    end
 
    def member(id)
      cached_request member_url(id)
    end

    def hash_for(str)
      ParamsTransformer.hash_for str
    end

    private
    def connection
      @connection ||= Connection.new(
        config.service_url, config.app_key, config.app_token)
    end

    def activity(type, explicit_params, magic_keys, params ={})
      MagicParams.abracadabra(magic_keys, explicit_params) do |magic_params|
        params[:activity_type] = type
        params[:activity_at] = Time.now.iso8601
        connection.post activities_url,
          ParamsTransformer.transform(params.merge(magic_params))
      end
    end

    def cached_request(url, &block)
      cache = Randypot::Cache.get(url)
      response = connection.get(url, cache)
      if response.not_modified?
        cache
      else
        yield response if block_given?
        Randypot::Cache.put(url, response)
      end
    end
  end
end
