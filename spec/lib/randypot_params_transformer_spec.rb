require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot::ParamsTransformer do
  describe '.transform' do
    it 'should not touch some params' do
      Randypot::ParamsTransformer.transform(:a => 'a').should == {:a => 'a'}
    end
    
    it 'should add "_token" to the keys and MDFive values of some params' do
      params = {
        :member => 'this should be an email',
        :member_b => 'this should be another email',
        :content => 'this should be a URL'
      }
      Randypot::ParamsTransformer.transform(params).should == {
        :member_token   => Digest::MD5.hexdigest(params[:member]),
        :member_b_token => Digest::MD5.hexdigest(params[:member_b]),
        :content_token  => Digest::MD5.hexdigest(params[:content])
      }
    end
  
    it 'should translate "creator" to "member_b_token" and MDFive its value' do
      params = { :creator => 'this should be an email' }
      Randypot::ParamsTransformer.transform(params).should == {
        :member_b_token => Digest::MD5.hexdigest(params[:creator])}
    end
  
    it 'should translate "permalink" to "content_token" and MDFive its value' do
      params = { :permalink => 'this should be a URL' }
      Randypot::ParamsTransformer.transform(params).should == {
        :content_token => Digest::MD5.hexdigest(params[:permalink])}
    end
  
    it 'should replace :ugc => true for :content_source => "ugc"' do
      Randypot::ParamsTransformer.transform(:ugc => true).should == {
        :content_source => 'ugc'}
    end
  
    it 'should replace :ugc => false for :content_source => "editorial"' do
      Randypot::ParamsTransformer.transform(:ugc => false).should == {
        :content_source => 'editorial'}
    end
  
    it 'should replace :editorial => true for :content_source => "editorial"' do
      Randypot::ParamsTransformer.transform(:editorial => true).should == {
        :content_source => 'editorial'}
    end
  
    it 'should replace :editorial => false for :content_source => "ugc"' do
      Randypot::ParamsTransformer.transform(:editorial => false).should == {
        :content_source => 'ugc'}
    end
  end

  describe '.hash_for' do
    str = 'hash_for@string.;)'
    Randypot::ParamsTransformer.hash_for(str).should == Digest::MD5.hexdigest(str)
  end
end
