require 'will_paginate/array'

Admin.controllers :test_cases do

  get :index do
    query = "select tc.test_group, min(tr.created_at) as \"execution_start\", max(tr.updated_at) as \"execution_end\", count(tc.test_group) as \"test_steps\", sum(tc.duration) as \"duration\", tr.build
      from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id
      where tr.build = ?
      group by tc.test_group, tr.build", params[:build_id]
    @test_cases = TestCase.find_by_sql(query)
    @build_name = params[:build_id]
    render 'test_cases/index'
  end

  #get :latest do
  #  max_value = TestCase.select(:test_runs_id).maximum(:test_runs_id)
  #  query = "select tc.*, tr.build from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id where test_runs_id = ? order by tc.updated_at asc", max_value
  #  @test_cases = TestCase.find_by_sql(query)
  #  render 'test_cases/latest'
  #end

  get :specific do
    query = "select tc.* from test_cases tc INNER JOIN test_runs tr on tc.test_runs_id = tr.id where tr.build = ? and tc.test_group = ? order by tc.updated_at asc", params[:build_id], params[:test_group]
    @test_cases = TestCase.find_by_sql(query)
    @test_group = params[:test_group]
    @build_name = params[:build_id]
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
