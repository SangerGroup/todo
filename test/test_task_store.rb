require 'minitest/autorun'
require './lib/task_store'

class TestTaskStore < Minitest::Test

  def setup
    @store = TaskStore.new('tasks.yml')
    params = {"description" => ""} # dummy data mimics user input
    @task = Task.new(@store, params)
  end

  # test saves a new task to the YAML store under the task.rb-assigned id
  # not a clue how to do this :-(
  def test_save

  end

end
