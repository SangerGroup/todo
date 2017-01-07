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
    # test tasks for /
    @task0 = Task.new(@store, params)
    @task0.categories["deleted"] = false
    @task0.categories["completed"] = false
    @store.save(@task0)
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
    # test tasks for /completed
    @task4 = Task.new(@store, params)
    @task4.categories["deleted"] = false
    @task4.categories["completed"] = true
    @store.save(@task4)
    @task5 = Task.new(@store, params)
    @task5.categories["deleted"] = true
    @task5.categories["completed"] = true
    @task5.categories["foobar"] = true
    @store.save(@task5)
    params_for_6 = params.merge("description" => "I ain't completed")
    @task6 = Task.new(@store, params_for_6)
    @task6.categories["completed"] = false # so shouldn't show up in /completed
    @task6.categories["foobar"] = true
    @store.save(@task6)
    params_for_7 = params.merge("date_due" => "1/1/2016")
    @task7 = Task.new(@store, params_for_7)
    @task7.categories["completed"] = true
    @task7.categories[nil] = "foobar"
    @store.save(@task7)
    # test tasks for /deleted
    params_for_8 = params.merge("date_due" => "1/1/2016")
    @task8 = Task.new(@store, params_for_8)
    @task8.categories["completed"] = true
    @task8.categories["deleted"] = true
    @store.save(@task8)
    params_for_9 = params.merge("description" => "Should not show up 9262")
    @task9 = Task.new(@store, params_for_9)
    @task9.categories["completed"] = false
    @task9.categories["deleted"] = false # this one isn't deleted, shouldn't show up
    @store.save(@task9)
    params_for_10 = {"description" => "I am not a foo task", "categories" => "bar"}
    @task10 = Task.new(@store, params_for_10)
    @task10.categories["completed"] = false
    @task10.categories["deleted"] = false
    @store.save(@task10)
    # Note, based on the above data, the complete list of added drop-down tags
    # (because they are not completed & not deleted) should be as follows
    @drop_down_tags = ["foo", "bar"]
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
    # all categories in setup are shown in the Tags list
    @drop_down_tags.each do |tag|
      assert last_response.body.include?("<a href=\"/category/#{tag}")
    end
    # SAVED FOR LATER:
    # various required user messages are shown on page
    # overlong description message is shown on page
    # bad categories message is shown on page
  end

  def test_get_completed
    get '/completed'
    assert last_response.ok?
    # Test completed.erb returns required content
    assert last_response.body.include?("Completed!") # page title correct
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
    # ADD THESE LATER!
    # assert last_response.body.include?("Add new task") # new task dialogue present
    # placeholders present
    # assert last_response.body.include?("What do you have to do?")
    # assert last_response.body.include?("Optional: format mm/dd")
    # assert last_response.body.include?("Separate by commas")

    # checkbox is checked
    assert last_response.body.include?('<form method="post" action="/uncheck_completed/')
    # non-deleted task doesn't appear
    refute last_response.body.include?("I ain't completed")
    # all categories in setup are shown in the Tags list
    @drop_down_tags.each do |tag|
      assert last_response.body.include?("<a href=\"/category/#{tag}")
    end
  end

  def test_get_deleted
    get '/deleted'
    assert last_response.ok?
    # Test deleted.erb returns required content
    assert last_response.body.include?("Deleted items") # page title correct
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
    # ADD THESE LATER!
    # assert last_response.body.include?("Add new task") # new task dialogue present
    # placeholders present
    # assert last_response.body.include?("What do you have to do?")
    # assert last_response.body.include?("Optional: format mm/dd")
    # assert last_response.body.include?("Separate by commas")

    # checkbox is checked
    assert last_response.body.include?('<form method="post" action="/uncheck_completed/')
    # non-deleted task doesn't appear
    refute last_response.body.include?("Should not show up 9262")
    # all categories in setup are shown in the Tags list
    @drop_down_tags.each do |tag|
      assert last_response.body.include?("<a href=\"/category/#{tag}")
    end
  end

  def test_get_category
    get '/category/foo'
    assert last_response.ok?
    # Test categories.erb returns required content
    assert last_response.body.include?("<title>Foo") # page title correct
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
    # ADD THESE LATER!
    # assert last_response.body.include?("Add new task") # new task dialogue present
    # placeholders present
    # assert last_response.body.include?("What do you have to do?")
    # assert last_response.body.include?("Optional: format mm/dd")
    # assert last_response.body.include?("Separate by commas")

    # checkbox is checked
    assert last_response.body.include?('<form method="post" action="/check_completed/')
    # non-foo task doesn't appear
    refute last_response.body.include?("I am not a foo task")
    # all categories in setup are shown in the Tags list
    @drop_down_tags.each do |tag|
      assert last_response.body.include?("<a href=\"/category/#{tag}")
    end
  end


  def teardown
    # These Task objects were actually saved to the yaml file; they need to be
    # deleted or else they accumulate and are actually shown to the user.
    @store.delete_forever(@task0.id)
    @store.delete_forever(@task1.id)
    @store.delete_forever(@task2.id)
    @store.delete_forever(@task3.id)
    @store.delete_forever(@task4.id)
    @store.delete_forever(@task5.id)
    @store.delete_forever(@task6.id)
    @store.delete_forever(@task7.id)
    @store.delete_forever(@task8.id)
    @store.delete_forever(@task9.id)
    @store.delete_forever(@task10.id)
  end

end
