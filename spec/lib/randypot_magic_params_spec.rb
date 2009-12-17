require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::MagicParams do
  it 'should give us back the passed params hash if it is not nil' do
    # Not too much magic in this case...
    params_hash = {:a => :b}
    Randypot::MagicParams.abracadabra(:key, params_hash) do |params|
      params.should == params_hash
    end
  end

  it 'should give us the method called in the returned instance as value of the passed key' do
    # a.k.a the magic thing...
    Randypot::MagicParams.abracadabra(:passed_key) do |params|
      params.should == {:passed_key => 'wadus'}
    end.wadus
  end

  it 'should give us the magic key/value merged with any hash passed to the method called' do
    Randypot::MagicParams.abracadabra(:passed_key) do |params|
      params.should == {:passed_key => 'wadus', :other_key => 'other value'}
    end.wadus(:other_key => 'other value')
  end

  it 'should allow two nested calls' do
    Randypot::MagicParams.abracadabra([:a, :b]) do |params|
      params.should == {:a => 'foo', :b => 'bar'}
    end.foo.bar
  end

  it 'should allow two nested calls and merge the passed hash' do
    Randypot::MagicParams.abracadabra([:a, :b]) do |params|
      params.should == {:a => 'foo', :b => 'bar', :c => 'the', :d => 'car'}
    end.foo.bar(:c => 'the', :d => 'car')
  end

  it 'should allow more than two nested calls' do
    Randypot::MagicParams.abracadabra([:a, :b, :c, :d]) do |params|
      params.should == {:a => 'foo', :b => 'bar', :c => 'the', :d => 'car'}
    end.foo.bar.the.car
  end

  it 'should allow more than two nested calls and merge the passed hash' do
    Randypot::MagicParams.abracadabra([:a, :b, :c, :d]) do |params|
      params.should == {:a => 'foo', :b => 'bar', :c => 'the', :d => 'car', :e => 'tachaaan!!!'}
    end.foo.bar.the.car(:e => 'tachaaan!!!')
  end

  it 'should let us override our own magic with the passed hash' do
    # Not very useful, but IMO better than the opposite
    Randypot::MagicParams.abracadabra([:a, :b, :c, :d]) do |params|
      params.should == {:a => 'foo', :b => 'fixes', :c => 'the', :d => 'car'}
    end.foo.bar.the.car(:b => 'fixes')
  end

  it 'should let us break the magic anywhere' do
    Randypot::MagicParams.abracadabra([:a, :b, :c, :d, :e, :f]) do |params|
      params.should == {:a => 'foo', :b => 'bar', :c => 'the', :d => 'end'}
    end.foo.bar(:c => 'the', :d => 'end')
  end
end
