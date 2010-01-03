class Randypot
  class MagicParams
    def self.abracadabra(keys, params = nil, &block)
      keys_array = keys.is_a?(Array) ? keys : [keys] # to_a seems to be deprecated :(
      if params or keys_array.empty?
        yield params
      else
        new(keys_array, &block)
      end
    end

    private
      def initialize(keys, &block)
        @keys, @block = keys, block
      end
      
      def method_missing(method, *args, &block)
        magic_param = {@keys.shift => method.to_s}
        if (params = args.first) or @keys.empty?
          unless params.is_a?(Hash)
            params = (@keys.any? ? {@keys.shift => params} : {})
          end
          @block.call magic_param.merge(params||{})
        else
          MagicParams.new(@keys) do |coming_back_params|
            @block.call magic_param.merge(coming_back_params)
          end
        end
      end
  end
end
