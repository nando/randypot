require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Connection do
  describe '.initilize' do
    it 'should prepare an HTTP client instance with its set_auth method invoked' do
      client, url, usr, pass = mock, 'http://example.com', 'u', 'p'
      HTTPClient.should_receive(:new).and_return(client)
      client.should_receive(:set_auth).with(url, usr, pass)
      Randypot::Connection.new(url, usr, pass)
    end
  end
  
  describe 'instance methods:' do
    before do
      @url = 'http://example.com/api/foo'
      @params = {:foo => 'foo', :bar => 'bar'}
      @client = mock('httpclient', :set_auth => nil)
      HTTPClient.stub!(:new).and_return(@client)
      @connection = Randypot::Connection.new('','','')
    end

    it '#post should post' do
      @client.should_receive(:post).with(@url, @params)
      @connection.post(@url, @params)
    end

    it '#get should get' do
      @client.should_receive(:get).with(@url)
      @connection.get(@url)
    end
  end
end
