require File.dirname(__FILE__) + '/../spec_helper'

describe CommentController do

  data = [
    [:index,   [{:action => :list, :resource => :comment}]],
    [:show,    [{:action => :show, :resource => :comment, :source => :id}]],
    [:edit,    [{:action => :edit, :resource => :comment},
                {:action => :show, :resource => :comment}]],
    [:update,  [{:action => :edit, :resource => :comment},
                {:action => :show, :resource => :comment, :source => '@comment'}]],
    [:destroy, [{:action => :delete},
                {:action => :delete, :source => '@comments'}]],
  ]

  data.each do |test|
    it "should have valid description for #{test.first}" do
      desc = CommentController.descriptions_of(test.first)
      desc.should == test.second
    end
  end

  it "should raise an error on :describe!" do
    lambda {
      CommentController.describe! :update, "foo"
    }.should raise_error(ArgumentError)
  end

  it "should raise an error on an invalid description" do
    lambda {
      CommentController.describe :foo, "show comment using @foo"
      CommentController.descriptions_of(:foo)
    }.should raise_error(ArgumentError)
  end

end