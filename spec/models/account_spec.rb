# == Schema Information
# Schema version: 27
#
# Table name: accounts
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  assigned_to     :integer(4)
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Private")
#  website         :string(64)
#  toll_free_phone :string(32)
#  phone           :string(32)
#  fax             :string(32)
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  email           :string(64)
#  background_info :string(255)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Account.create!(:name => "Test Account", :user => Factory(:user))
  end

  describe "Attach" do
    before do
      @account = Factory(:account)
    end

    it "should return nil when attaching existing asset" do
      @task = Factory(:task, :asset => @account, :user => @current_user)
      @contact = Factory(:contact)
      @account.contacts << @contact
      @opportunity = Factory(:opportunity)
      @account.opportunities << @opportunity

      @account.attach!(@task).should == nil
      @account.attach!(@contact).should == nil
      @account.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = Factory(:task, :user => @current_user)
      @contact = Factory(:contact)
      @opportunity = Factory(:opportunity)

      @account.attach!(@task).should == [ @task ]
      @account.attach!(@contact).should == [ @contact ]
      @account.attach!(@opportunity).should == [ @opportunity ]
    end

    it "should not attach a contact to more than one account" do
      @another_account = Factory(:account)
      @contact = Factory(:contact)
      @account.attach!(@contact).should == [ @contact ]
      @contact.account.should == @account

      @another_account.attach!(@contact).should == [ @contact ]
      @contact.account.should == @another_account
      @another_account.contacts.should include(@contact)
      @account.contacts.should_not include(@contact)
    end
  end

  describe "Discard" do
    before do
      @account = Factory(:account)
    end

    it "should discard a task" do
      @task = Factory(:task, :asset => @account, :user => @current_user)
      @account.tasks.count.should == 1

      @account.discard!(@task)
      @account.reload.tasks.should == []
      @account.tasks.count.should == 0
    end

    it "should discard a contact" do
      @contact = Factory(:contact)
      @account.contacts << @contact
      @account.contacts.count.should == 1

      @account.discard!(@contact)
      @account.contacts.should == []
      @account.contacts.count.should == 0
    end

    it "should discard an opportunity" do
      @opportunity = Factory(:opportunity)
      @account.opportunities << @opportunity
      @account.opportunities.count.should == 1

      @account.discard!(@opportunity)
      @account.opportunities.should == []
      @account.opportunities.count.should == 0
    end
  end

  describe "tags" do
    before do
      @account = Factory(:account)
    end

    it "has no tags by default" do
      @account.tags.should be_empty
    end

    it "can have tags assigned" do
      @account.tag_list = "foo, bar, example"
      @account.save
      tags = @account.tag_list
      tags.size.should == 3
      tags.should include('foo', 'bar', 'example')
    end

    describe 'adding' do
      it "handles appending 0 tags" do
        @account.add_tag("")
        @account.tag_list.should be_empty
      end

      it "handles appending nil" do
        @account.add_tag(nil)
        @account.tag_list.should be_empty
      end

      it "can add 1 tag" do
        @account.add_tag("moo")
        @account.tag_list.should == %w(moo)
      end

      it "can add more than 1 tag" do
        @account.add_tag("moo, foo, bar")
        @account.tag_list.should == %w(moo foo bar)
      end
    end

    describe 'deleting' do
      it 'handles deleting nil' do
        @account.delete_tag(nil)
        @account.tag_list.should be_empty
      end

      it 'handles deleting an unexisting tag' do
        @account.add_tag('foo')
        @account.delete_tag('moo')
        @account.tag_list.should == ['foo']
      end


      it 'handles deleting an existing tag' do
        @account.add_tag('foo')
        @account.delete_tag('foo')
        @account.tag_list.should be_empty
      end
    end
  end
end
