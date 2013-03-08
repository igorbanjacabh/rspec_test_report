Admin.controllers :test_cases do

  get :index do
    @test_cases = TestCase.paginate(:page => params[:page], :per_page => 10)
    render 'test_cases/index'
  end


  get :latest do
    @max_value = TestCase.select(:test_runs_id).maximum(:test_runs_id)
    @test_cases = TestCase.all(:conditions => { :test_runs_id => @max_value })
    render 'test_cases/latest'
  end

  get :specific do
    @test_cases = TestCase.all(:conditions => { :test_runs_id => params[:test_run] })
    @test_run_id = params[:test_run]
    render 'test_cases/specific'
  end

  post :create do
    @test_case = TestCase.new(params[:test_case])
    if @test_case.save
      flash[:notice] = 'TestCase was successfully created.'
      redirect url(:test_cases, :edit, :id => @test_case.id)
    else
      render 'test_cases/new'
    end
  end

  get :edit, :with => :id do
    @test_case = TestCase.find(params[:id])
    render 'test_cases/edit'
  end

  put :update, :with => :id do
    @test_case = TestCase.find(params[:id])
    if @test_case.update_attributes(params[:test_case])
      flash[:notice] = 'TestCase was successfully updated.'
      redirect url(:test_cases, :edit, :id => @test_case.id)
    else
      render 'test_cases/edit'
    end
  end

  delete :destroy, :with => :id do
    test_case = TestCase.find(params[:id])
    if test_case.destroy
      flash[:notice] = 'TestCase was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy TestCase!'
    end
    redirect url(:test_cases, :index)
  end
end
