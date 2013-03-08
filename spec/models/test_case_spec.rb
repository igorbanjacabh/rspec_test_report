require 'spec_helper'

describe "TestCase Model" do
  let(:test_case) { TestCase.new }
  it 'can be created' do
    test_case.should_not be_nil
  end
end
