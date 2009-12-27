require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Cache do
    before do
      @key = 'members'
      Dir.should_receive(:tmpdir).and_return('/tmp')
      @filepath = '/tmp/randypot/' + Digest::MD5.hexdigest('members')
    end

    it '.get should return nil if cache file does not exist' do
      File.should_receive(:file?).with(@filepath).and_return(false)
      Randypot::Cache.get(@key).should be_nil
    end

    it '.get should return Response if cache file does exist' do
      response = mock('response')
      File.should_receive(:file?).with(@filepath).and_return(true)
      YAML.should_receive(:load).with(@filepath).and_return(response)
      Randypot::Cache.get(@key).should == response
    end

    it '.put' do
      file, response, res_to_yaml = mock('file'), mock('response'), mock('res_to_yaml')
      File.should_receive(:open).with(@filepath, 'w').and_return(file)
      response.should_receive(:to_yaml).and_return(res_to_yaml)
      file.should_receive(:write).with(res_to_yaml)
      Randypot::Cache.put @key, response
    end
end
