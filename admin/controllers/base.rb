require 'gchart'

Admin.controllers :base do

  get :index, :map => "/" do

    #Get sum of pass/failed/pending in last run and display its results on pie3d chart
    last_run_query = "select * from test_runs order by updated_at desc limit 1"
    @last_test_runs = TestRun.find_by_sql(last_run_query)

    @last_test_runs.each do |test_run|
      success_count = test_run.example_count.to_i - test_run.failure_count.to_i
      @last_build_chart = GChart.pie3d :data => [test_run.failure_count, test_run.pending_count, success_count]
      @last_build_chart.title = "Sum for last build result"
      @last_build_chart.colors = [:red, :yellow, :green]
      @last_build_chart.legend = ["Failed: #{test_run.failure_count}", "Pending: #{test_run.pending_count}", "Pass: #{success_count}"]
      @last_build_chart.width = 480
      @last_build_chart.height = 250
      @last_build_chart.entire_background = "F7F7F8" 
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
      success_rate_array << ((test_run.example_count.to_i - test_run.failure_count.to_i).to_f/test_run.example_count.to_f)*100
      build_namas_array << test_run.build
    end

    @test_chart = GChart.line :data => success_rate_array.reverse
    @test_chart.title = "Last 10 builds success rate"
    @test_chart.colors = [:green]
    @test_chart.axis(:left) { |a| a.range = 0..100 }
    @test_chart.axis(:bottom) do |a| 
      a.labels = build_namas_array.reverse
    end
    @test_chart.width = 963
    @test_chart.height = 250
    @test_chart.entire_background = "F7F7F8"

    render "base/index"
  end
end
