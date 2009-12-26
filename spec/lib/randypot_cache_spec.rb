require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Cache do
    before do
      @key = 'güadus'
      @digest = Digest::MD5.hexdigest('güadus')
      @response_body = <<MEMBERS_RESPONSE
0318254ce7c576c583e8a63558e7f98877e6ec49,12,2009-08-03 20:46:40 UTC
059fc5c60729cad3bfe07e1a5edaa51104c14518,12,2009-08-03 20:46:40 UTC
0699d11f05594b85c6004ebba26712a5f9940090,12,2009-08-03 20:46:40 UTC
0f4d89c1a93ea1b314ec6cad9a07cb743e41953c,13,2009-08-03 20:46:40 UTC
MEMBERS_RESPONSE
    end

    it '.get should return nil if cache file does not exist' do
      Digest::MD5.should_receive(:hexdigest).with(@key).and_return(@digest)
      Dir.should_receive(:tmpdir).and_return('')
      File.should_receive(:file?).with('/randypot/' + @digest).and_return(false)
      Randypot::Cache.get(@key).should be_nil
    end

#    it '.put' do
#      File.should_receive(:open).with(Dir.tmpdir + '/randypot/members_cache', 'w').and_yield(file)
#
#      Randypot::Cache.get @key
#    end
end
