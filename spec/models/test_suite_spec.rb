require 'spec_helper'

describe "TestSuite Model" do
  let(:test_suite) { TestSuite.new }
  it 'can be created' do
    test_suite.should_not be_nil
  end
end
