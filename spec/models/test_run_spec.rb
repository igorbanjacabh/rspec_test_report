require 'spec_helper'

describe "TestRun Model" do
  let(:test_run) { TestRun.new }
  it 'can be created' do
    test_run.should_not be_nil
  end
end
