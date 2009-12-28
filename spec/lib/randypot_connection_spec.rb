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
      @client_response = mock('HTTPClient', :status => 201,
        :contenttype => "application/json; charset=utf-8",
        :content => "{\"activity\":{\"content_type\":\"item\"}}",
        :header => {'etag' => ['254ce7c5']})
    end

    it '#post should do the post and return a Randypot Response' do
      @client.should_receive(:post).with(@url, @params).and_return(@client_response)
      res = @connection.post(@url, @params)
      res.should be_kind_of(Randypot::Response)
      res.status.should == @client_response.status
      res.body.should == @client_response.content
      res.content_type.should == @client_response.contenttype
    end

    it '#get should do the get and return a Randypot Response' do
      @client.should_receive(:get).with(@url, nil, {}).and_return(@client_response)
      res = @connection.get(@url)
      res.should be_kind_of(Randypot::Response)
      res.status.should == @client_response.status
      res.body.should == @client_response.content
      res.content_type.should == @client_response.contenttype
      res.etag.should == @client_response.header['etag'][0]
    end

    it '#get should do the get with the If-None-Match header if cache is not nil' do
      cache = mock('cache', :etag => 'd543fa38f')
      @client.should_receive(:get).with(
        @url, nil, {'If-None-Match' => cache.etag}).and_return(@client_response)
      res = @connection.get(@url, cache)
      res.should be_kind_of(Randypot::Response)
      res.status.should == @client_response.status
      res.body.should == @client_response.content
      res.content_type.should == @client_response.contenttype
      res.etag.should == @client_response.header['etag'][0]
    end
  end
end
