require 'gchart'

Admin.controllers :base do

  get :index, :map => "/" do

    #Get sum of pass/failed/pending in last run and display its results on pie3d chart
    last_run_query = "select * from test_runs order by updated_at desc limit 1"
    @last_test_runs = TestRun.find_by_sql(last_run_query)

    @last_test_runs.each do |test_run|
      if test_run.example_count.nil?
        success_count = test_run.example_count.to_i - test_run.failure_count.to_i
        @last_build_chart = GChart.pie3d :data => [test_run.failure_count, test_run.pending_count, success_count]
        @last_build_chart.title = "Sum for last build result"
        @last_build_chart.colors = [:red, :yellow, :green]
        @last_build_chart.legend = ["Failed: #{test_run.failure_count}", "Pending: #{test_run.pending_count}", "Pass: #{success_count}"]
        @last_build_chart.width = 480
        @last_build_chart.height = 250
        @last_build_chart.entire_background = "F7F7F8"
      else
        @last_build_chart = GChart.pie3d :data => [100, 100, 100]
        @last_build_chart.title = "Sum for last build result"
        @last_build_chart.colors = [:red, :yellow, :green]
        @last_build_chart.legend = ["Failed: N/A", "Pending: N/A", "Pass: N/A"]
        @last_build_chart.width = 480
        @last_build_chart.height = 250
        @last_build_chart.entire_background = "F7F7F8"
      end
    end

    #Get sum of pass/failed/pending in last 10 runs and display its sum stats on pie3d chart
    last_10run_query = "select * from test_runs order by updated_at desc limit 10"
    @last_10test_runs = TestRun.find_by_sql(last_10run_query)

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
    @last_10build_chart.width = 480
    @last_10build_chart.height = 250
    @last_10build_chart.entire_background = "F7F7F8" 

    #Get success rate for last 10 runs and display it on line chart
    success_rate_array = Array.new()
    build_namas_array = Array.new()

    @last_10test_runs.each do |test_run|
      if test_run.example_count.nil?
        success_rate_array << 0
      else
        success_rate_array << ((test_run.example_count.to_i - test_run.failure_count.to_i).to_f/test_run.example_count.to_f)*100
      end
      build_namas_array << test_run.build
    end

    #Build string that represents list of graph dots that will be visible
    graph_dots = ""
    build_namas_array.each_with_index do |build, i|
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
      a.labels = build_namas_array.reverse
    end
    @last_10test_runs_graph.width = 963
    @last_10test_runs_graph.height = 250
    @last_10test_runs_graph.entire_background = "F7F7F8"

    render "base/index"
  end
end
