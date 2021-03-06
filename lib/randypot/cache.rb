require 'tmpdir'
require 'yaml'
require 'digest/md5'
require 'fileutils'

class Randypot
  class Cache
    class << self
      def get(key)
        if File.file?(file = filepath(key))
          Marshal.load(File.open(file).read)
        end
      end

      def put(key, object)
        Dir.mkdir(cache_dir) unless File.directory?(cache_dir)
        File.open(filepath(key), 'w') {|f| f.write(Marshal.dump(object))}
        object
      end

      def clean
        FileUtils.rm_rf cache_dir
      end
  
      private
      def cache_dir
        @cache_dir ||= Dir.tmpdir + '/randypot/'
      end
  
      def filepath(key)
        cache_dir + Digest::MD5.hexdigest(key)
      end
    end
  end
end
