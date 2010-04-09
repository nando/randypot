require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot do
  it '.config should be the same object for every call' do
    Randypot.config.should == Randypot.config
  end

  describe '.*_url methods' do
    before do
      Randypot.should_receive(:config).and_return(mock('cfg', :service_url => ''))
    end
    # Randypot.activities_url
    it 'should build the url for posting new activities using config.service_url' do
      Randypot.activities_url.should == '/activities/'
    end
  
    # Randypot.members_url
    it 'should build the url to get members kandies using config.service_url' do
      Randypot.members_url.should == '/members/'
    end
  
    # Randypot.member_url(member)
    it 'should build the url to get a member info from his/her email/id' do
      Digest::MD5.should_receive(:hexdigest).with('member').and_return('digest')
      Randypot.member_url('member').should == '/members/digest'
    end
  end
    
  describe 'configuration methods' do
    describe '.configure' do
      it 'should configure the .config object' do
        Randypot.config.should_receive(:foo).with(:bar)
        Randypot.configure do |c|
          c.foo :bar
        end
      end
      
      it 'should use the given YAML' do
        Randypot.config.should_receive(:configure).with('myconf.yml')
        Randypot.configure 'myconf.yml'
      end
    end

    describe '.new' do
      it 'should configure the .config object' do
        Randypot.config.should_receive(:foo).with(:bar)
        Randypot.new do |c|
          c.foo :bar
        end
      end
    
      it 'should configure using the YAML passed in :config' do
        Randypot.config.should_receive(:configure).with('myconf.yml')
        Randypot.new :config => 'myconf.yml'
      end

      it 'should keep the param value as member' do
        member = 'member@example.com'
        Randypot.new(member).member.should == member
      end

      it 'should keep member and configure with a given block' do
        member = 'randy@example.com'
        Randypot.config.should_receive(:foo).with(:bar)
        Randypot.new(member) do |c|
          c.foo :bar
        end.member.should == member
      end

      it 'should keep member and configure through a YAML' do
        member = 'randy@example.com'
        Randypot.config.should_receive(:configure).with('myconf.yml')
        Randypot.new(:member => member, :config => 'myconf.yml').member.should == member
      end
    end
  end

  describe 'new activity' do
    def set_expectations_for(activity_type, base_params)
      conn, now, transformed_params = mock('Connection'), Time.now, {}
      Time.stub!(:now).and_return(now)
      Randypot.should_receive(:connection).and_return(conn)
      Randypot::ParamsTransformer.should_receive(:transform).with(
        base_params.merge({
        :activity_type => activity_type,
        :activity_at => now.iso8601
      })).and_return(transformed_params)
      conn.should_receive(:post).with(Randypot.activities_url, transformed_params)
    end

    describe '.creation' do
      before do
        @base_params = {
          :content_type => 'wadus',
          :content_source => 'ugc',
          :content => 'http://example.com/wadus.png'
        }
        set_expectations_for 'creation', @base_params
      end
  
      it 'should create from passed params' do
        Randypot.creation(@base_params)
      end
  
      it 'should pass its first nested method as :content_type' do
        Randypot.creation.wadus(@base_params.reject{|k,v| k == :content_type})
      end
  
      it 'should pass its second nested method as :content_source' do
        Randypot.creation.wadus.ugc(:content => @base_params[:content])
      end
    end
  
    describe '#creates' do
      before do
        @base_params = {
          :member => 'randy@example.com',
          :content_type => 'wadus',
          :content_source => 'ugc',
          :content => 'http://example.com'
        }
        set_expectations_for 'creation', @base_params
      end

      it "should use params' member if present" do
        randy = Randypot.new('this-will-be-overridden@example.com')
        randy.creates(@base_params)
      end

      it "should use instance's member" do
        randy = Randypot.new(@base_params[:member])
        randy.creates(@base_params.reject{|k,v| k == :member})
      end

      it "should use its first nested method as content_type" do
        Randypot.new.creates.wadus(@base_params.reject{|k,v| k == :content_type})
      end

      it "should use its second nested method as content_source" do
        params = @base_params.reject do |key, v|
          [:content_type, :content_source].include? key
        end
        Randypot.new.creates.wadus.ugc params
      end

      it "should use nested methods and instance's member" do
        randy = Randypot.new(@base_params[:member])
        randy.creates.wadus.ugc :content => 'http://example.com' 
      end

      it "should use param as value of :content if it's not a Hash" do
        randy = Randypot.new(@base_params[:member])
        randy.creates.wadus.ugc 'http://example.com' 
      end
    end

    describe '.reaction' do
      before do
        @base_params = {
          :category => 'comment',
          :content_type => 'wadus',
          :content_source => 'ugc',
          :content => 'http://example.com'
        }
        set_expectations_for 'reaction', @base_params
      end
  
      it 'should create from passed params' do
        Randypot.reaction(@base_params)
      end
  
      it 'should pass its first nested method as :category' do
        Randypot.reaction.comment(@base_params.reject{|k,v| k == :category})
      end
  
      it 'should pass its second nested method as :content_type' do
        params = @base_params.reject{|k,v| 
          [:content_type, :category].include? k
        }
        Randypot.reaction.comment.wadus(params)
      end
  
      it 'should pass its third nested method as :content_source' do
        params = @base_params.reject{|k,v| 
          [:content_type, :category, :content_source].include? k
        }
        Randypot.reaction.comment.wadus.ugc(params)
      end
    end
  
    describe '#reacts' do
      before do
        @base_params = {
          :member => 'randy@example.com',
          :category => 'comment',
          :content_type => 'wadus',
          :content_source => 'ugc',
          :content => 'http://example.com'
        }
        set_expectations_for 'reaction', @base_params
      end

      it "should use params' member if present" do
        randy = Randypot.new('this-will-be-overridden@example.com')
        randy.reacts(@base_params)
      end

      it "should use instance's member" do
        randy = Randypot.new(@base_params[:member])
        randy.reacts(@base_params.reject{|k,v| k == :member})
      end

      it "should use its first nested method as category" do
        Randypot.new.reacts.comment(@base_params.reject{|k,v| k == :category})
      end

      it "should use its second nested method as content_type" do
        params = @base_params.reject do |key, v|
          [:content_type, :category].include? key
        end
        Randypot.new.reacts.comment.wadus params
      end

      it "should use its third nested method as content_source" do
        params = @base_params.reject do |key, v|
          [:category, :content_type, :content_source].include? key
        end
        Randypot.new.reacts.comment.wadus.ugc params
      end

      it "should use nested methods and instance's member" do
        randy = Randypot.new(@base_params[:member])
        randy.reacts.comment.wadus.ugc :content => 'http://example.com' 
      end

      it "should use param as value of :content if it's not a Hash" do
        randy = Randypot.new(@base_params[:member])
        randy.reacts.comment.wadus.ugc 'http://example.com' 
      end
    end

    describe '.relationship' do
      before do
        @base_params =  {
          :category => 'love',
          :member_b => 'example@example.org'
        }
        set_expectations_for 'relationship', @base_params
      end
  
      it 'should create from passed params' do
        Randypot.relationship(@base_params)
      end
  
      it 'should pass its first nested method as :category' do
        Randypot.relationship.love(:member_b => @base_params[:member_b])
      end
    end

    describe '#relationships' do
      before do
        @base_params =  {
          :member => 'randy@example.com',
          :category => 'love',
          :member_b => 'example@example.org'
        }
        set_expectations_for 'relationship', @base_params
      end
  
      it 'should create from passed params' do
        randy = Randypot.new('this-will-be-overridden@example.com')
        randy.relationships @base_params
      end

      it "should use instance's member" do
        randy = Randypot.new(@base_params[:member])
        randy.relationships(@base_params.reject{|k,v| k == :member})
      end
  
      it 'should pass its first nested method as :category' do
        randy = Randypot.new(@base_params[:member])
        randy.relationships.love(:member_b => @base_params[:member_b])
      end

      it "should use param as value of :member_b if it's not a Hash" do
        randy = Randypot.new(@base_params[:member])
        randy.relationships.love @base_params[:member_b]
      end
    end
  end

  describe '.members' do
    before do
      @response = Randypot::Response.new(:status => 200, :body => <<MEMBERS_BODY)
0318254ce7c576c583e8a63558e7f98877e6ec49,12,2009-08-03 20:46:40 UTC
059fc5c60729cad3bfe07e1a5edaa51104c14518,12,2009-08-03 20:46:40 UTC
0699d11f05594b85c6004ebba26712a5f9940090,12,2009-08-03 20:46:40 UTC
0f4d89c1a93ea1b314ec6cad9a07cb743e41953c,13,2009-08-03 20:46:40 UTC
MEMBERS_BODY
      cache, conn = mock('cache', :status => 200), mock('connection')
      Randypot::Cache.should_receive(:get).with(Randypot.members_url).and_return(cache)
      Randypot.should_receive(:connection).and_return(conn)
      conn.should_receive(:get).with(Randypot.members_url, cache).and_return(@response)
    end

    it 'should request members_url and store in cache cache the parsed response (if response is new and good)' do
      @response.should_receive(:not_modified?).and_return(false) # new response
      Randypot::Cache.should_receive(:put).with(Randypot.members_url, @response).and_return(@response)
      members = Randypot.members
      members.parsed.size.should == 4
      first = members.parsed.first
      first.hash.should == '0318254ce7c576c583e8a63558e7f98877e6ec49'
      first.candies.should == 12
      first.updated_at.should == Time.parse('2009-08-03 20:46:40 UTC')
    end

    it 'should request members_url and do not cache response if cache is valid' do
      @response.should_receive(:not_modified?).and_return(true)
      Randypot::Cache.should_not_receive(:put)
      Randypot.members
    end

    it 'should not cache the response if is not valid' do
      @response.should_receive(:not_modified?).and_return(false)
      @response.should_receive(:success?).and_return(false)
      Randypot::Cache.should_not_receive(:put)
      Randypot.members
    end
  end

  describe '.member' do
    before do
      @response = Randypot::Response.new(:status => 200, :body => <<MEMBER_BODY)
{"member_token":"422ef9125be6bf8a733fba46e0d02892","updated_at":"2010-02-01T19:52:56Z","kandies_count":31}
MEMBER_BODY
      cache, conn = mock('cache'), mock('connection')
      @email = 'member@example.com'
      @url = Randypot.member_url(@email)
      Randypot::Cache.should_receive(:get).with(@url).and_return(cache)
      Randypot.should_receive(:connection).and_return(conn)
      conn.should_receive(:get).with(@url, cache).and_return(@response)
    end

    it 'should request members_url and cache response if response is good and no cache is present' do
      @response.should_receive(:not_modified?).and_return(false)
      @response.should_receive(:success?).and_return(true)
      Randypot::Cache.should_receive(:put).with(@url, @response).and_return(@response)
      member = Randypot.member(@email)
      member.parsed.candies.should == 31
    end

    it 'should request members_url and do not cache response if cache is valid' do
      @response.should_receive(:not_modified?).and_return(true)
      Randypot::Cache.should_not_receive(:put)
      Randypot.member(@email)
    end

  end

  describe '.hash_for' do
    it 'should be a wrapper of ParamsTransformer.hash_for' do
      str, hash = 'foo', 'bar'
      Randypot::ParamsTransformer.should_receive(:hash_for).with(str).and_return(hash)
      Randypot.hash_for(str).should == hash
    end
  end
end
