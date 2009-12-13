class Randypot #:nodoc:
  class VERSION #:nodoc:
    MAJOR = 0
    MINOR = 0
    TINY  = 1
    PATCH = 0 # Set to nil for official release

    STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
