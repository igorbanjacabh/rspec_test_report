require 'yaml'

Admin.controllers :test_suites do

  get :index do
    #Load test suite type name from config.yml
    @config = YAML.load(File.open('./config/config.yml'))
    regression_suite_name = @config['test_suites']['regression_suite']
    smoke_suite_name = @config['test_suites']['smoke_suite']

    @test_suites = TestSuite.where("suite = ? or suite = ?", regression_suite_name, smoke_suite_name)
    render 'test_suites/index'
  end

  get :new do
    @test_suite = TestSuite.new
    render 'test_suites/new'
  end

  post :create do
    @test_suite = TestSuite.new(params[:test_suite])
    if @test_suite.save
      flash[:notice] = 'TestSuite was successfully created.'
      redirect url(:test_suites, :edit, :id => @test_suite.id)
    else
      render 'test_suites/new'
    end
  end

  get :edit, :with => :id do
    @test_suite = TestSuite.find(params[:id])
    render 'test_suites/edit'
  end

  put :update, :with => :id do
    @test_suite = TestSuite.find(params[:id])
    if @test_suite.update_attributes(params[:test_suite])
      flash[:notice] = 'TestSuite was successfully updated.'
      redirect url(:test_suites, :edit, :id => @test_suite.id)
    else
      render 'test_suites/edit'
    end
  end

  delete :destroy, :with => :id do
    test_suite = TestSuite.find(params[:id])
    if test_suite.destroy
      flash[:notice] = 'TestSuite was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy TestSuite!'
    end
    redirect url(:test_suites, :index)
  end
end
