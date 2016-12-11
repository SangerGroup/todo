require 'minitest/autorun'
require './lib/task'
require './lib/task_store'

class TestTask < Minitest::Test

  def setup
    @store = TaskStore.new('tasks.yml')
    params = {"description" => ""} # dummy data mimics user input
    @task = Task.new(@store, params)
  end

  # New Task object has attributes: id, position, description, date added,
  # due date, and categories.
  def test_initialize
    refute_nil(@task.id)
    refute_nil(@task.position)
    refute_nil(@task.description)
    refute_nil(@task.date_added)
    refute_nil(@task.date_due)
    refute_nil(@task.categories)
    refute_nil(@task.complete)
  end

  # given a set of ids (check they're all numerical), determine the highest
  # and then return the numeral of the next number
  def test_assign_id
    bad_sample_ids = [0, 1, 3, 5, "b", 4]
    assert_raises "Invalid ID" do
      assign_id(bad_sample_ids)
    end
    good_sample_ids = [0, 1, 3, 5, 4]
    perfect_sample_ids = [0, 1, 2, 3, 4, 5, 6, 7]
    assert_equal(@task.assign_id(good_sample_ids), 6)
    assert_equal(@task.assign_id(perfect_sample_ids), 8)
  end

  def test_check_description
    # Return error message if description is blank.
    assert_equal(@task.check_description(""),"Description cannot be blank.")
    # Return error message if description is too long.
    assert_equal(@task.check_description("x" * 141), "Description was 141 characters long; cannot exceed 140.")
    # Otherwise return "ok"
    assert_equal(@task.check_description("This is a test."), "ok")
  end

end
