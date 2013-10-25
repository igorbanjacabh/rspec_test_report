require 'gchart'
require 'yaml'

def draw_last_test_run(test_suite_name)
  id = TestSuite.where(:suite => test_suite_name).pluck(:id)

  if (!id.empty?)
    @last_test_runs = TestRun.where(:test_suites_id => id)
    @last_test_runs.each do |test_run|
      if !test_run.example_count.nil?
        success_count = test_run.example_count.to_i - test_run.failure_count.to_i
        @last_build_chart = GChart.pie3d :data => [test_run.failure_count, test_run.pending_count, success_count]
        @last_build_chart.title = "Sum for last build result"
        @last_build_chart.colors = [:red, :yellow, :green]
        @last_build_chart.legend = ["Failed: #{test_run.failure_count}", "Pending: #{test_run.pending_count}", "Pass: #{success_count}"]
        @last_build_chart.width = 450
        @last_build_chart.height = 230
        @last_build_chart.entire_background = "F7F7F8"
      else
        @last_build_chart = GChart.pie3d :data => [100, 100, 100]
        @last_build_chart.title = "Sum for last build result"
        @last_build_chart.colors = [:red, :yellow, :green]
        @last_build_chart.legend = ["Failed: N/A", "Pending: N/A", "Pass: N/A"]
        @last_build_chart.width = 450
        @last_build_chart.height = 230
        @last_build_chart.entire_background = "F7F7F8"
      end
    end
  else
    @last_build_chart = GChart.pie3d :data => [100]
    @last_build_chart.title = "Sum for last build result"
    @last_build_chart.colors = [:grey]
    @last_build_chart.legend = ["Not avaliable"]
    @last_build_chart.width = 450
    @last_build_chart.height = 230
    @last_build_chart.entire_background = "F7F7F8"
  end
  return @last_build_chart
end

def draw_last_10_test_runs(test_suite_name)
  id = TestSuite.where(:suite => test_suite_name).pluck(:id)

  if (!id.empty?)
    @last_10test_runs = TestRun.where(:test_suites_id => id).order("updated_at DESC").limit(10)

    success_count = 0
    failure_count = 0
    pending_count = 0

    @last_10test_runs.each do |test_run|
      success_count += test_run.example_count.to_i - test_run.failure_count.to_i
      failure_count += test_run.failure_count.to_i
      pending_count += test_run.pending_count.to_i
    end

    @last_10build_chart = GChart.pie3d :data => [failure_count, pending_count, success_count]
    @last_10build_chart.title = "Sum of last 10 build results"
    @last_10build_chart.colors = [:red, :yellow, :green]
    @last_10build_chart.legend = ["Failed: #{failure_count}", "Pending: #{pending_count}", "Pass: #{success_count}"]
    @last_10build_chart.width = 450
    @last_10build_chart.height = 230
    @last_10build_chart.entire_background = "F7F7F8"
  else
    @last_10build_chart = GChart.pie3d :data => [100]
    @last_10build_chart.title = "Sum of last 10 build results"
    @last_10build_chart.colors = [:grey]
    @last_10build_chart.legend = ["Not available"]
    @last_10build_chart.width = 450
    @last_10build_chart.height = 230
    @last_10build_chart.entire_background = "F7F7F8"
  end
  return @last_10build_chart
end

def draw_last_10_builds_success_rate(test_suite_name)
  #Get success rate for last 10 runs and display it on line chart
  id = TestSuite.where(:suite => test_suite_name).pluck(:id)
  @last_10test_runs = TestRun.where(:test_suites_id => id).order("updated_at DESC").limit(10)

  success_rate_array = Array.new()
  build_names_array = Array.new()

  @last_10test_runs.each do |test_run|
    if test_run.example_count.nil?
      success_rate_array << 0
    else
      success_rate_array << ((test_run.example_count.to_i - test_run.failure_count.to_i).to_f/test_run.example_count.to_f)*100
    end
    build_names_array << test_run.build
  end

  #Build string that represents list of graph dots that will be visible
  graph_dots = ""
  build_names_array.each_with_index do |build, i|
    graph_dots << "o,3399CC,0,#{i}.0,10.0|"
  end
  graph_dots.chop!

  @last_10test_runs_graph = GChart.line :data => success_rate_array.reverse, :extras => { "chg" => "0,10", "chm" => graph_dots }
  @last_10test_runs_graph.title = "Last 10 builds success rate"
  @last_10test_runs_graph.colors = [:green]
  @last_10test_runs_graph.axis(:left) do |a|
    a.range = 0..100
  end
  @last_10test_runs_graph.axis(:bottom) do |a| 
    a.labels = build_names_array.reverse
  end
  @last_10test_runs_graph.width = 963
  @last_10test_runs_graph.height = 250
  @last_10test_runs_graph.entire_background = "F7F7F8"
  return @last_10test_runs_graph
end

Admin.controllers :base do

  get :index, :map => "/" do

    #Load test suite type name from config.yml
    @config = YAML.load(File.open('./config/config.yml'))
    regression_suite_name = @config['test_suites']['regression_suite']
    smoke_suite_name = @config['test_suites']['smoke_suite']

    #Draw regression charts
    @regression_last_build_chart = draw_last_test_run(regression_suite_name)
    @regression_last_10build_chart = draw_last_10_test_runs(regression_suite_name)
    @regression_last_10test_runs_graph = draw_last_10_builds_success_rate(regression_suite_name)

    #Draw smoke charts
    @smoke_last_build_chart = draw_last_test_run(smoke_suite_name)
    @smoke_last_10build_chart = draw_last_10_test_runs(smoke_suite_name)
    @smoke_last_10test_runs_graph = draw_last_10_builds_success_rate(smoke_suite_name)

    render "base/index"
  end
end