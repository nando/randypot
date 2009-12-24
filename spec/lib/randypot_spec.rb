require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Randypot do
  it '.config should be the same object for every call' do
    Randypot.config.should == Randypot.config
  end

  it 'should build the url for posting new activities using config.service_url' do
    Randypot.should_receive(:config).and_return(
      mock('config', :service_url => 'http://...'))
    Randypot.activities_url.should == 'http://.../activities/'
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
end
