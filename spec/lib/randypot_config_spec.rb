require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Config do
  before do
    @config = Randypot::Config.new
  end
  
  it "#service_url should default to 'http://garden.kandypot.com/api'" do
    @config.service_url.should == 'http://garden.kandypot.com/api'
  end

  describe "setting through accesors" do
    before  do
      @config.service_url = 'bad urls should raise an exception'
      @config.app_key = 'KEY'
      @config.app_token = 'TOKEN'
    end

    it "should be posible" do
      @config.service_url.should == 'bad urls should raise an exception'
      @config.app_key.should == 'KEY'
      @config.app_token.should == 'TOKEN'
    end
  end

  describe "setting through #configure" do
    before  do
      @config.configure do |c|
        c.service_url = 'bad urls should raise an exception'
        c.app_key = 'KEY'
        c.app_token = 'TOKEN'
      end
    end

    it "should be posible" do
      @config.service_url.should == 'bad urls should raise an exception'
      @config.app_key.should == 'KEY'
      @config.app_token.should == 'TOKEN'
    end
  end
  
end
