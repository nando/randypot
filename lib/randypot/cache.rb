require 'tmpdir'
require 'digest/md5'

class Randypot
  class Cache
    class << self
      def get(key)
        if File.file?(filepath(key))
        end
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
