require 'bundler'
require 'bundler/setup'
require 'sinatra'

require './lib/task'
require './lib/task_store'
enable :sessions

store = TaskStore.new('tasks.yml')

get('/') do |*user_message|
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  @overlong_description = session[:overlong_description] if
    session[:overlong_description]
  session[:message] = nil # clear message after being used
  session[:overlong_description] = nil # ditto
  @tasks = store.all
  erb :index #, user_message => {:user_message => params[:user_message]}
end

get('/index.html')
  redirect '/'
end

post('/newtask') do
  @task = Task.new(store, params)
  # decide whether to save & prepare user messages
  if @task.complete == true # task is complete!
    @task.message << " " + "Task saved!"
    session[:message] = @task.message # use session[:message] for user messages
    @task.message = ""
    store.save(@task)
  else
    @task.message << " " + "Not saved." # task incomplete
    session[:message] = @task.message # use session[:message] for user messages
    session[:overlong_description] = @task.overlong_description if
      @task.overlong_description
    @task.message = ""
    @task.overlong_description = nil
  end
  redirect '/'
end
