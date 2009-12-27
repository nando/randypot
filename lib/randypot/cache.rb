require 'tmpdir'
require 'yaml'
require 'digest/md5'

class Randypot
  class Cache
    class << self
      def get(key)
        if File.file?(file = filepath(key))
          YAML.load(file)
        end
      end

      def put(key, object)
        File.open(filepath(key), 'w').write(object.to_yaml)
      end
  
      private
      def cache_dir
        Dir.tmpdir + '/randypot/'
      end
  
      def filepath(key)
        cache_dir + Digest::MD5.hexdigest(key)
      end
    end
  end
end
