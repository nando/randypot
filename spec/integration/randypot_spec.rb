require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

Randypot::Cache.clean

Randypot.configure do |config|
  config.service_url = 'http://localhost.localdomain.lan:3000/api'
  config.app_key = '1' 
  config.app_token = '1' 
end

def should_return_status(status)
  yield.status.should be(status)
end

describe Randypot do
  it '.creation' do
    should_return_status(201) do 
      Randypot.creation(
        :content_source => 'ugc',
        :content_type => 'default',
        :content => 'http://example.com/foo.html',
        :member => 'randy@example.com')
    end
  end
  it '.creation.default' do
    should_return_status(201) do 
      Randypot.creation.default(
        :content_source => 'ugc',
        :content => 'http://example.com/foo.html',
        :member => 'randy@example.com')
    end
  end
  it '.creation.default.ugc' do
    should_return_status(201) do 
      Randypot.creation.default.ugc(
        :content => 'http://example.com/foo.html',
        :member => 'randy@example.com')
    end
  end
  it '.creation.default.editorial' do
    should_return_status(201) do 
      Randypot.creation.default.editorial(
        :content => 'http://example.com/foo.html',
        :member => 'randy@example.com')
    end
  end
  it '.members' do
    should_return_status(200) do 
      Randypot.members
    end
  end
  it '.members from cache' do
    should_return_status(200) do 
      Randypot.members
    end
  end
  #it '.member(id)' do      
  #  should_return_status(200) do 
  #    Randypot.member('randy@example.com')
  #  end
  #end
end
