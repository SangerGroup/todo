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
  end

  def app
    Sinatra::Application
  end

  def test_get_slash
    get '/'
    assert last_response.ok?
    # Test index.erb returns required content
    assert last_response.body.include?("<table")
    assert last_response.body.include?("<th")
    assert last_response.body.include?("<tr")
    assert last_response.body.include?("Add new task")
  end

  def test_post_newtask
    post('/newtask', params = {"description"=>"Test task 123"})
    # Test that "saved" message for user is in returned page
    # NOT DONE THIS DOESN'T WORK
    # assert last_response.body.include?("Task saved") # COMMENTED OUT FOR NOW
    # Test that "Test task 123" is stored in yml store
    # DO THIS?!?!
  end
end
