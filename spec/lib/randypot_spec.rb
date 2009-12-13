require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot do
  it ".config should be the same object for every call" do
    Randypot.config.should == Randypot.config
  end

  it ".configure should configure the .config object" do
    Randypot.config.should_receive(:foo).with(:bar)
    Randypot.configure do |c|
      c.foo :bar
    end
  end
  
  it ".new should let us configure de .config object as well" do
    Randypot.config.should_receive(:foo).with(:bar)
    Randypot.new do |c|
      c.foo :bar
    end
  end
end
