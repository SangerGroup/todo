require 'minitest/autorun'
require './lib/todo_helpers'
require './lib/task_store'

class TestToDoHelpers < Minitest::Test

  def setup
    @store = TaskStore.new('tasks.yml')
    # dummy data mimics user input
    params = {"description" => "Test task 123", "categories" => "foo, bar"}
    @task1 = Task.new(@store, params)
    @task1.categories["deleted"] = true
    @task1.categories["foobar"] = true
    @store.save(@task1)
    @task2 = Task.new(@store, params)
    @task2.categories["completed"] = true
    @task2.categories["foobar"] = true
    @store.save(@task2)
    @task3 = Task.new(@store, params)
    @task3.categories[nil] = "foobar"
    @store.save(@task3)
    @task4 = Task.new(@store, params)
    @task4.categories["deleted"] = true
    @task4.categories["completed"] = true
    @store.save(@task4)
    @tasks = @store.all
    # list of items that should be deleted; update if you add more "deleted"s
    @testers_to_delete = [@task1, @task4]
    @testers_to_delete_length = @testers_to_delete.length
  end

  def test_compile_categories
    # removes "deleted" and "completed" from categories
    refute(compile_categories(@tasks).include?("deleted"))
    refute(compile_categories(@tasks).include?("completed"))
    # includes categories only once (no duplicates)
    assert(1, compile_categories(@tasks).count {|x| x == "foo"})
    # rejects the nil category
    refute(compile_categories(@tasks).include? nil)
  end

  def test_delete_forever_all
    @store_length_before_deletion = @store.all.length
    @store = delete_forever_all(@store, @testers_to_delete)
    @store_length_after_deletion = @store.all.length
    assert_equal(@testers_to_delete_length, @store_length_before_deletion -
      @store_length_after_deletion)
  end

  def teardown
    # These Task objects were actually saved to the yaml file; they need to be
    # deleted or else they accumulate and are actually shown to the user.
    @store.delete_forever(@task1.id)
    @store.delete_forever(@task2.id)
    @store.delete_forever(@task3.id)
    @store.delete_forever(@task4.id)
  end

end
