require 'will_paginate/array'

Admin.controllers :test_cases do

  get :index do
    query = "select tc.test_group, count(tc.test_group) as \"test_steps\", sum(tc.duration) as \"duration\", tr.build
      from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id
      where tr.build = ? and tr.test_suites_id = ?
      group by tc.test_group, tr.build 
      order by tc.test_group", params[:build_id], params[:test_suite_id]
    @test_cases = TestCase.find_by_sql(query)
    @build_name = params[:build_id]
    @test_suite = params[:test_suite]
    @test_suite_id = params[:test_suite_id]

    puts "test suite:", @test_suite
    puts "test suite id:", @test_suite_id

    @pass_array = Array.new()
    @fail_array = Array.new()

    @test_cases.each do |test_case|
      pass_subquery = "select count(tc.execution_result) as \"pass_count\" 
        from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id 
        where tr.build = ? and tc.test_group = ? and tc.execution_result = ? and tr.test_suites_id = ?", 
        params[:build_id], test_case.test_group, "passed", params[:test_suite_id]
      pass_counts = TestCase.find_by_sql(pass_subquery)
      pass_counts.each do |count|
        @pass_array << count.pass_count
      end

      fail_subquery = "select count(tc.execution_result) as \"fail_count\" 
        from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id 
        where tr.build = ? and tc.test_group = ? and tc.execution_result = ? and tr.test_suites_id = ?", 
        params[:build_id], test_case.test_group, "failed", params[:test_suite_id]
      fail_counts = TestCase.find_by_sql(fail_subquery)
      fail_counts.each do |count|
        @fail_array << count.fail_count
      end
    end
    render 'test_cases/index'
  end

  #get :latest do
  #  max_value = TestCase.select(:test_runs_id).maximum(:test_runs_id)
  #  query = "select tc.*, tr.build 
  #  from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id 
  #  where test_runs_id = ? order by tc.updated_at asc", max_value
  #  @test_cases = TestCase.find_by_sql(query)
  #  render 'test_cases/latest'
  #end

  get :specific do
    query = "select tc.* 
      from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id 
      where tr.build = ? and tc.test_group = ? and tr.test_suites_id = ? order by tc.updated_at asc", 
      params[:build_id], params[:test_group], params[:test_suite_id]
    @test_cases = TestCase.find_by_sql(query)
    @test_group = params[:test_group]
    @build_name = params[:build_id]
    @test_suite = params[:test_suite]
    @test_suite_id = params[:test_suite_id]
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
