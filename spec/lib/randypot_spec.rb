require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot do
  it '.config should be the same object for every call' do
    Randypot.config.should == Randypot.config
  end

  # Randypot.activities_url
  it 'should build the url for posting new activities using config.service_url' do
    Randypot.should_receive(:config).and_return(mock('cfg', :service_url => ''))
    Randypot.activities_url.should == '/activities/'
  end

  # Randypot.members_url
  it 'should build the url to get member kandies using config.service_url' do
    Randypot.should_receive(:config).and_return(mock('cfg', :service_url => ''))
    Randypot.members_url.should == '/members/'
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
        Randypot.new 'myconf.yml'
      end
    end

    describe '.new' do
      it 'should configure the .config object' do
        Randypot.config.should_receive(:foo).with(:bar)
        Randypot.new do |c|
          c.foo :bar
        end
      end
    
      it 'should use the given YAML' do
        Randypot.config.should_receive(:configure).with('myconf.yml')
        Randypot.new 'myconf.yml'
      end
   end
  end

  describe 'new activity' do
    def set_expectations_for(activity_type, base_params)
      @base_params = base_params
      conn, now, transformed_params = mock('Connection'), Time.now, {}
      Time.stub!(:now).and_return(now)
      Randypot.should_receive(:connection).and_return(conn)
      Randypot::ParamsTransformer.should_receive(:transform).with(
        base_params.merge({
        :activity_type => activity_type,
        :activity_at => now
      })).and_return(transformed_params)
      conn.should_receive(:post).with(Randypot.activities_url, transformed_params)
    end

    describe '.creation' do
      before do
        set_expectations_for 'creation', {
          :content_type => 'wadus',
          :content_source => 'ugc',
          :content => 'http://example.com/wadus.png'
        }
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
  
    describe '.reaction' do
      before do
        set_expectations_for 'reaction', {
          :category => 'comment',
          :content_type => 'wadus',
          :content_source => 'ugc',
          :content => 'http://example.com/wadus.png'
        }
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
  
    describe '.relationship' do
      before do
        set_expectations_for 'relationship', {
          :category => 'love',
          :member_b => 'example@example.org'
        }
      end
  
      it 'should create from passed params' do
        Randypot.relationship(@base_params)
      end
  
      it 'should pass its first nested method as :category' do
        Randypot.relationship.love(:member_b => @base_params[:member_b])
      end
    end
  end

  describe '.members' do
    before do
      @response_body = <<MEMBERS_RESPONSE
0318254ce7c576c583e8a63558e7f98877e6ec49,12,2009-08-03 20:46:40 UTC
059fc5c60729cad3bfe07e1a5edaa51104c14518,12,2009-08-03 20:46:40 UTC
0699d11f05594b85c6004ebba26712a5f9940090,12,2009-08-03 20:46:40 UTC
0f4d89c1a93ea1b314ec6cad9a07cb743e41953c,13,2009-08-03 20:46:40 UTC
MEMBERS_RESPONSE
    end

    it 'should request members_url w/o "If-None-Match" header if no cache is present' do
      File.should_receive(:file?).with(Dir.tmpdir + '/randypot/members_cache').and_return(false)
      conn, response, file = mock('connection'), mock('file')
      Randypot.should_receive(:connection).and_return(conn)
      conn.should_receive(:get).with(Randypot.members_url, nil, {}).and_return(response)
#      File.should_receive(:open).with(Dir.tmpdir + '/randypot/members_cache', 'w').and_yield(file)
#      file.should_receive(:write).with(
      Randypot.members
    end
  end
end
