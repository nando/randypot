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
  describe 'activities' do
    after do
      @res.status.should be(201)
    end
    it '.creation' do
      @res = Randypot.creation(
          :content_source => 'ugc',
          :content_type => 'default',
          :content => 'http://example.com/foo.html',
          :member => 'randy@example.com')
    end
    it '.creation.default' do
      @res = Randypot.creation.default(
          :content_source => 'ugc',
          :content => 'http://example.com/foo.html',
          :member => 'randy@example.com')
    end
    it '.creation.default.ugc' do
      @res = Randypot.creation.default.ugc(
          :content => 'http://example.com/foo.html',
          :member => 'randy@example.com')
    end
    it '.creation.default.editorial' do
      @res = Randypot.creation.default.editorial(
          :content => 'http://example.com/foo.html',
          :member => 'randy@example.com')
    end
    it '.reaction' do
      @res = Randypot.reaction(
          :member => 'friend@example.com',
          :category => 'default',
          :content_source => 'ugc',
          :content_type => 'default',
          :content => 'http://example.com/foo.html',
          :member_b => 'randy@example.com')
    end
    it '.reaction.default' do
      @res = Randypot.reaction.default(
          :member => 'friend@example.com',
          :content_source => 'ugc',
          :content_type => 'default',
          :content => 'http://example.com/foo.html',
          :member_b => 'randy@example.com')
    end
    it '.reaction.default.default' do
      @res = Randypot.reaction.default.default(
          :member => 'friend@example.com',
          :content_source => 'ugc',
          :content => 'http://example.com/foo.html',
          :member_b => 'randy@example.com')
    end
    it '.reaction.default.default.editorial' do
      @res = Randypot.reaction.default.default.editorial(
          :member => 'friend@example.com',
          :content => 'http://example.com/foo.html',
          :member_b => 'randy@example.com')
    end
    it '.reaction.default.default.ugc' do
      @res = Randypot.reaction.default.default.ugc(
          :member => 'friend@example.com',
          :content => 'http://example.com/foo.html',
          :member_b => 'randy@example.com')
    end
    it '.relationship' do
      @res = Randypot.relationship(
          :member => 'friend@example.com',
          :category => 'default',
          :member_b => 'randy@example.com')
    end
    it '.relationship.default' do
      @res = Randypot.relationship.default(
          :member => 'friend@example.com',
          :member_b => 'randy@example.com')
    end
  end
  it '.members' do
    Randypot.members.status.should be(200)
  end
  it '.members from cache' do
    Randypot.members.status.should be(200)
  end
  #it '.member(id)' do      
  #  should_return_status(200) do 
  #    Randypot.member('randy@example.com')
  #  end
  #end
end
