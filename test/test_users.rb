ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'minitest/autorun'
require_relative "../todo"
require './lib/users'

class TestUsers < Minitest::Test
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  def setup
    @sample_user = {email: "yo.larrysanger@gmail.com", password: "password5",
      password_again: "password5"} # change this up below by substituting data
  end

  def test_submit_new_account
    # EMAIL VALIDATION
    post '/submit_new_account', params = @sample_user
    follow_redirect!
    assert last_response.ok?
    # error messages don't appear when input validates
    refute last_response.body.include?("Sorry, check the email address.")
    refute last_response.body.include?("Password must have at least 8 characters.")
    refute last_response.body.include?("Sorry, those passwords don't match. Try again.")
    # if email doesn't validate, appropriate message appears on page...
    @sample_user[:email] = "foo, this ain't an email address!"
    post '/submit_new_account', params = @sample_user
    follow_redirect!
    assert last_response.body.include?("Sorry, check the email address.")
    # ...and bad email attempt also reappears
    assert last_response.body.include?(@sample_user[:email])
    # but email disappears after that (on page refresh)
    get '/create_account'
    refute last_response.body.include?(@sample_user[:email])
    # and message disappears after that
    refute last_response.body.include?("Sorry, check the email address.")

    # PASSWORD VALIDATION
    @sample_user[:email] = "yo.larrysanger@gmail.com" # fix bad tester for new test
    @sample_user[:password] = "asd3f"
    post '/submit_new_account', params = @sample_user
    follow_redirect!
    # if password doesn't validate, appropriate message appears...
    assert last_response.body.include?("Password must have at least 8 characters.")
    # but email address does
    assert last_response.body.include?(@sample_user[:email])
    # password doesn't appear on page
    refute last_response.body.include?(@sample_user[:password])
    # but message disappears after that (on page refresh)
    get '/create_account'
    refute last_response.body.include?("Password must have at least 8 characters.")

    # PASSWORD INSTANCES MATCH (don't validate second one)
    @sample_user[:password] == "password5" # fix bad tester for new test
    post '/submit_new_account', params = @sample_user
    follow_redirect!
    # if passwords don't match, appropriate message appears...
    assert last_response.body.include?("Sorry, those passwords don't match. Try again.")
    # ...but message disappears after that (on page refresh)
    get '/create_account'
    refute last_response.body.include?("Sorry, those passwords don't match. Try again.")
  end

  def teardown
    # delete @sample_user account
  end

end
