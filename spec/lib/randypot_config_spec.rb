require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::Config do
  EXPECTED_VALUES = {
    :service_url => 'bad urls should raise an exception',
    :app_key =>   'MY_KEY',
    :app_token => 'MY_TOKEN'
  }
  YAMLS = {
    :current_directory => 'randypot.yml',
    :home_directory => '~/.randypot/configuration.yml',
    :etc_directory => '/etc/randypot/configuration.yml'
  }.inject({}) {|h, kv| h.merge(kv[0] => File.expand_path(kv[1]))}

  Spec::Matchers.define :have_the_expected_values do
    match do |config|
      config.service_url.should == EXPECTED_VALUES[:service_url]
      config.app_key.should == EXPECTED_VALUES[:app_key]
      config.app_token.should == EXPECTED_VALUES[:app_token]
    end
  end

  it "#service_url should default to 'http://garden.kandypot.com/api'" do
    config = Randypot::Config.new
    config.service_url.should == 'http://garden.kandypot.com/api'
  end

  it "should be possible to set it through accesors" do
    config = Randypot::Config.new
    config.service_url = EXPECTED_VALUES[:service_url]
    config.app_key = EXPECTED_VALUES[:app_key]
    config.app_token = EXPECTED_VALUES[:app_token]
    config.should have_the_expected_values
  end

  it "should be possible to set it through #configure" do
    config = Randypot::Config.new
    config.configure do |c|
      c.service_url = EXPECTED_VALUES[:service_url]
      c.app_key = EXPECTED_VALUES[:app_key]
      c.app_token = EXPECTED_VALUES[:app_token]
    end
    config.should have_the_expected_values
  end
  
  describe "setting through a YAML" do
    before  do
      @yaml_content = <<CONFIG_YAML
  kandypot_server:
    service_url: #{EXPECTED_VALUES[:service_url]}
    app_key: #{EXPECTED_VALUES[:app_key]}
    app_token: #{EXPECTED_VALUES[:app_token]}
CONFIG_YAML
    end

    it "should be loaded from a given file" do
      File.should_receive(:read).with('cfg.yml').and_return(@yaml_content)
      config = Randypot::Config.new
      config.configure 'cfg.yml'
      config.should have_the_expected_values
    end

    it "should be automagically loaded from /etc/randypot/configuration.yml" do
      mock_files(
        YAMLS[:etc_directory] => @yaml_content,
        YAMLS[:home_directory]   => nil,
        YAMLS[:current_directory]                    => nil)
      config = Randypot::Config.new
      config.should have_the_expected_values
    end

    it "should be automagically loaded from ~/.randypot/configuration.yml" do
      mock_files(
        YAMLS[:etc_directory] => nil,
        YAMLS[:home_directory] => @yaml_content,
        YAMLS[:current_directory] => nil)
      config = Randypot::Config.new
      config.should have_the_expected_values
    end

    it "should be automagically loaded from randypot.yml" do
      mock_files(
        YAMLS[:etc_directory] => nil,
        YAMLS[:home_directory] => nil,
        YAMLS[:current_directory] => @yaml_content)
      config = Randypot::Config.new
      config.should have_the_expected_values
    end
  end

  describe "priority of the different setting methods:" do
    before  do
      @yaml_overriden = <<CONFIG_YAML
  kandypot_server:
    service_url: overriden-setting
    app_key: #{EXPECTED_VALUES[:app_key]}
    app_token: #{EXPECTED_VALUES[:app_token]}
CONFIG_YAML
      @yaml_overrider = <<CONFIG_YAML
  kandypot_server:
    service_url: #{EXPECTED_VALUES[:service_url]}
CONFIG_YAML
    end

    it "~/.randypot should override /etc/randypot" do
      mock_files(
        YAMLS[:etc_directory] => @yaml_overriden,
        YAMLS[:home_directory] => @yaml_overrider,
        YAMLS[:current_directory] => nil)
      config = Randypot::Config.new
      config.should have_the_expected_values
    end

    it "randypot.yml should override ~/.randypot/configuration.yml" do
      mock_files(
        YAMLS[:etc_directory] => nil,
        YAMLS[:home_directory] => @yaml_overriden,
        YAMLS[:current_directory] => @yaml_overrider)
      config = Randypot::Config.new
      config.should have_the_expected_values
    end

    it "User YAML should override randypot.yml" do
      mock_files(
        YAMLS[:etc_directory] => nil,
        YAMLS[:home_directory] => nil,
        YAMLS[:current_directory] => @yaml_overriden)
      File.should_receive(:read).with('config.yml').and_return(@yaml_overrider)
      config = Randypot::Config.new
      config.configure 'config.yml'
      config.should have_the_expected_values
    end

    it "#configure should override randypot.yml" do
      mock_files(
        YAMLS[:etc_directory] => nil,
        YAMLS[:home_directory] => nil,
        YAMLS[:current_directory] => @yaml_overriden)
      config = Randypot::Config.new
      config.configure do |conf|
        conf.service_url = EXPECTED_VALUES[:service_url]
      end
      config.should have_the_expected_values
    end
  end

  def mock_files(files={})
    files.each do |file, content|
      File.should_receive(:file?).with(file).and_return(!content.nil?)
      File.should_receive(:read).with(file).and_return(content) if content
    end
  end
end
