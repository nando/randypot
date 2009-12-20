require 'digest/md5'

class Randypot
  class ParamsTransformer
    TRANSFORMATIONS_TABLE = {
      :creator                      => :member_b,
      :permalink                    => :content,
      {:ugc => true}.inspect        => {:content_source => 'ugc'},
      {:ugc => false}.inspect       => {:content_source => 'editorial'},
      {:editorial => true}.inspect  => {:content_source => 'editorial'},
      {:editorial => false}.inspect => {:content_source => 'ugc'}
    }
    TOKEN_KEYS = %w{member content member_b}

    class << self
      def transform(params)
        params.inject({}) do |hash, arr|
          hash.merge(transform_key_and_value(arr[0], arr[1]))
        end
      end

      private

      def translate_key_and_value(key, value)
        if TRANSFORMATIONS_TABLE[key]
          [TRANSFORMATIONS_TABLE[key], value]
        elsif kv = TRANSFORMATIONS_TABLE[{key.to_sym => value}.inspect]
          [kv.keys.first, kv.values.first]
        else
          [key, value]
        end
      end

      def transform_key_and_value(raw_key, raw_value)
        key, value = translate_key_and_value(raw_key, raw_value)
        if TOKEN_KEYS.include?(key.to_s)
          {"#{key}_token".to_sym => Digest::MD5.hexdigest(value)}
        else
          {key => value}
        end
      end
    end
  end
end
