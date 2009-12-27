require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Response do
  before do
    @params = {
      :status => 200,
      :content_type => 'application/json; charset=utf-8',
      :body => '{"updated_at":"2009-08-03T20:46:40Z","member_token":"1f1741c3d08c5d1c6a683cd21defac894b368414","kandies_count":12}',
      :etag => 'a4562eb01'}
    @response = Randypot::Response.new(@params)
  end
  
  it 'should return values received as params' do
    @response.status.should == @params[:status]
    @response.content_type.should == @params[:content_type]
    @response.body.should == @params[:body]
    @response.etag.should == @params[:etag]
  end

  describe '#not_modified?' do
    it 'should return false if status is not 304' do
      @response.not_modified?.should be_false
    end

    it 'should return true if status is 304' do
      Randypot::Response.new(:status => 304).not_modified?.should be_true
    end
  end
end
