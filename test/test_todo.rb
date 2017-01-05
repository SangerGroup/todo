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
    # dummy data mimics user input; tests that user input is saved and displayed
    # groovily
    params = {"description" => "Test task 123", "categories" => "foo, bar"}
    @task1 = Task.new(@store, params)
    @task1.categories["deleted"] = true
    @task1.categories["foobar"] = true
    @store.save(@task1)
    @task2 = Task.new(@store, params)
    @task2.categories["completed"] = true
    @task2.categories["foobar"] = true
    @store.save(@task2)
    params_for_3 = params.merge("date_due" => "1/1/2016")
    @task3 = Task.new(@store, params_for_3)
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
    assert last_response.body.include?('<label for="task_checkbox"><input '\
      'class="checkbox"')
    # description from test task present
    assert last_response.body.include?("Test task 123")
    assert last_response.body.include?("2016-01-01") # task's date present
    # category link present
    assert last_response.body.include?('<a href="/category/foo')
    assert last_response.body.include?("<table") # table present
    assert last_response.body.include?("<th") # header present
    assert last_response.body.include?("<tr") # row present
    assert last_response.body.include?("Add new task") # new task dialogue present
    # placeholders present
    assert last_response.body.include?("What do you have to do?")
    assert last_response.body.include?("Optional: format mm/dd")
    assert last_response.body.include?("Separate by commas")
    # checkbox is unchecked
    assert last_response.body.include?('<form method="post" action="/check_completed/')
    # all categories in the store are shown in the Tags list
    @tasks.each do |task|
      task.categories.each do |cat, value|
        next if (cat == "deleted" || cat == "completed" || cat == nil)
        puts "CAT = href=\"/category/#{cat}"
        assert last_response.body.include?("href=\"/category/#{cat}")
      end
    end
    #all display_categories are shown in tags dropdown
    #tasks marked as "completed" and "deleted" are *not* shown in task list
    #other tasks are shown
=begin
    # various required user messages are shown on page
    # overlong description message is shown on page
    # bad categories message is shown on page
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
