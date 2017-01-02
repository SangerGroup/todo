ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../todo'

require './lib/task'
require './lib/task_store'

class ToDoTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    @store = TaskStore.new('tasks.yml')
    @tasks = @store.all
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
  end

  def app
    Sinatra::Application
  end

  def test_get_slash
    get '/'
    assert last_response.ok?
    # Test index.erb returns required content
    assert last_response.body.include?("Simple To Do List") # page title correct
    # task checkbox present
    assert last_response.body.include?('<label for="task_checkbox"><input class="checkbox"')
    # description from test task present
    assert last_response.body.include?("Test task 123")
    assert last_response.body.include?("<table") # table present
    assert last_response.body.include?("<th") # header present
    assert last_response.body.include?("<tr")
    assert last_response.body.include?("Add new task") # new task dialogue present


    # FINISH THIS LATER
    # all input boxes are followed by placeholders; requires regexen, so deferred
=begin
    more items are shown (e.g., checkboxes, date added, etc.)
    checkboxes are unchecked
    various required user messages are shown on page
    overlong description message is shown on page
    bad categories message is shown on page
    all display_categories are shown in tags dropdown
    tasks marked as "completed" and "deleted" are *not* shown in task list
    other tasks are shown
=end
  end

  def teardown
    # These Task objects were actually saved to the yaml file; they need to be
    # deleted or else they accumulate and are actually shown to the user.
    @store.delete_forever(@task1.id)
    @store.delete_forever(@task2.id)
    @store.delete_forever(@task3.id)
  end

end
