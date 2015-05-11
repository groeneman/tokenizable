require "spec_helper"
require 'tokenizable/dummy_class'

# Used to test the backup duplicate check in save by disabling the before_create call to create_token
def without_callback(&block)
  Dummy.skip_callback(:create,:before,:create_token)
  yield
  Dummy.set_callback(:create,:before,:create_token)
end

describe Tokenizable::Base do

  before(:each) do
    Dummy.delete_all
    Dummy.create_indexes
    @d = Dummy.new
  end

  after(:each) do
    @d.destroy
    Dummy.remove_indexes rescue nil
  end

  it "adds the token field" do
    expect(@d).to respond_to("token")
  end

  it "allows find to pull things up by token" do
    @d.save
    token = @d.token
    expect(Dummy.find(token)).to eq(@d)
  end

  it "still allows you to pull things up by mongo ID" do
    @d.save
    id = @d.id
    expect(Dummy.find(id)).to eq(@d)
  end

  it "auto generates a token on save" do
    @d.save
    expect(@d.token).not_to be_nil
  end

  it "lets you set the token if not already set" do
    @d.send("token=","tree")
    expect(@d.token).to eq("tree")
  end

  it "doesn't let you set the token if it's already set" do
    @d.send("token=","goose")
    expect{ @d.send("token=","moose") }.to raise_error(Tokenizable::TokenizerError)
  end

  it "create_token generates a unique token" do
    @d.save
    d2 = Dummy.new
    d2.save
    expect(@d.token).not_to eq(d2.token)
  end

  it "seed tokens works properly" do
    Dummy.remove_indexes
    @d2 = Dummy.new
    @d.save
    @d2.save
    @d.write_attribute(:token,nil)
    @d2.write_attribute(:token,nil)
    @d.save
    @d2.save
    Dummy.seed_tokens
    [@d,@d2].each {|d| d.reload}
    expect(@d.token).not_to eq(@d2.token)
  end

  it "saving an existing record works normally" do
    @d.save
    expect(@d.save).to be true
  end

  it 'instantiating with a token works properly' do
    d = Dummy.create(token: '12354')
    expect(d.token).to eq('12354')
  end

  it "save method protects against duplicates if the before_hook doesn't work" do
    @d.save
    without_callback do
      @d2 = Dummy.new
      @d2.save
    end
    expect(@d.token).not_to eq(@d2.token)
  end

  it "save method protects against non-nil duplicates too" do
    # Tests for the problem experienced in https://scripted.airbrake.io/groups/66474076
    @d.save
    without_callback do
      t = @d.token
      @d2 = Dummy.new
      @d2.send("token=",t)
      @d2.save
    end
    expect(@d.token).not_to eq(@d2.token)
  end

  it "clear tokens works properly" do
    @d.save
    Dummy.remove_indexes
    Dummy.clear_tokens
    Dummy.each do |d|
      expect(d.token).to be_nil
    end
  end

  it "doesn't let you set length-24 tokens" do
    expect { @d.send("token=","a"*24) }.to raise_error(Tokenizable::TokenizerError)
  end

  it "doesn't generate length-24 tokens" do
    # Test assumes generate_token would normally return a length-24 ID
    @d.create_token
    expect(@d.token.length).not_to eq(24)
  end

  it "still allows you to search for arrays of BSON IDs" do
    @d.save
    @d2 = Dummy.new
    @d2.save
    result = Dummy.find([@d,@d2].map{|d|d.id.to_s})
    expect(result.length).to eq(2)
    expect(result[0]).to be_a_kind_of(Dummy)
  end

  it "doesn't let you make really short tokens" do
    class Dummy
      def generate_token offset
        return "3"
      end
    end
    @d = Dummy.new
    @d.save
    expect(@d.token.length).to eq(6)
  end

  it "works with single-collection inheritance" do
    class Dummy
      def generate_token offset
        "longenoughtoken-#{offset}"
      end
    end

    class Rummy < Dummy; end
    @d.save
    @r = Rummy.new
    @r.save
    expect(@d.token).not_to eq(@r.token)
  end

end
