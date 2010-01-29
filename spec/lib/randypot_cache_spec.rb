require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Cache do
    before do
      @key = 'members'
      Dir.stub!(:tmpdir).and_return('/tmp')
      @dirpath = '/tmp/randypot/'
      @filepath = @dirpath + Digest::MD5.hexdigest('members')
    end

    it '.get should return nil if cache file does not exist' do
      File.should_receive(:file?).with(@filepath).and_return(false)
      Randypot::Cache.get(@key).should be_nil
    end

    it '.get should return Response if cache file does exist' do
      response, file = mock('response'), mock('cache-file', :read => 'foo')
      File.should_receive(:file?).with(@filepath).and_return(true)
      File.should_receive(:open).with(@filepath).and_return(file)
      Marshal.should_receive(:load).with('foo').and_return(response)
      Randypot::Cache.get(@key).should == response
    end
    
    describe '.put' do
      it 'should create randypots tmp directory if it does not exists and return stored response' do
        File.should_receive(:directory?).with(@dirpath).and_return(false)
        Dir.should_receive(:mkdir).with(@dirpath)
        file, response, dumped_res = mock('file'), mock('response'), mock('dumped_res')
        File.should_receive(:open).with(@filepath, 'w').and_yield(file)
        Marshal.should_receive(:dump).with(response).and_return(dumped_res)
        file.should_receive(:write).with(dumped_res)
        Randypot::Cache.put(@key, response).should == response
      end
    end
end
