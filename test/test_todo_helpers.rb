require 'minitest/autorun'
require './lib/todo_helpers'
require './lib/task_store'

class TestTask < Minitest::Test

  def setup
    @store = TaskStore.new('tasks.yml')
    @tasks = @store.all
    # dummy data mimics user input
    params = {"description" => "Test task 123", "categories" => "foo, bar"}
    @task1 = Task.new(@store, params)
    @task1.categories["deleted"] = true
    @task1.categories["completed"] = true
    @store.save(@task1)
    @task2 = Task.new(@store, params)
    @store.save(@task2)
    @task3 = Task.new(@store, params)
    @store.save(@task3)
  end

  def compile_categories
    # removes "deleted" and "completed" from categories
    # includes categories only once (no duplicates)
    # rejects the nil category
  end

  def teardown
  end

end
