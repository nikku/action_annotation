require File.dirname(__FILE__) + '/../spec_helper'

describe ActionAnnotation::Utils do

  it 'should parse descriptions without bindings correctly' do
    # Test result
    result = {:action => :show, :resource => :resource}
    # Test data
    ['show a resource', 'show with some text ignored a resource',
     'show pluralized resources', '(ignoring comments) show a resource',
     'show a resource (with comment at the end)'].each do |s|
      # Test #parse_descriptions
      ActionAnnotation::Utils.parse_description(s).should == result
    end
  end

  it 'should detect bindings of a description' do
    { # Test data => test result
      'show the resource in @res' =>
        {:action => :show,:resource => :resource,:source => '@res'},
      'show the resource from :id' =>
        {:action => :show,:resource => :resource,:source => :id},
    }.each_pair do |key, value|
      ActionAnnotation::Utils.parse_description(key,true).should == value
    end
  end

  it 'should raise an error if an unexpected binding is detected in a description' do
    lambda {
      ActionAnnotation::Utils.parse_description('show the resource :id')
    }.should raise_error(ArgumentError)
  end

end
