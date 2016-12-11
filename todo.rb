require 'sinatra'
require './lib/task'
require './lib/task_store'
enable :sessions

store = TaskStore.new('tasks.yml')

get('/') do |*user_message|
  @user_message = session[:message] if session[:message] # assign message
  session[:message] = "" # clear message after being used
  @tasks = store.all
  erb :index #, user_message => {:user_message => params[:user_message]}
end

post('/newtask') do
  @task = Task.new(store, params)
  # decide whether to save & prepare user messages
  if @task.complete == true
    @task.message << " " + "Task saved!"
    session[:message] = @task.message # use session[:message] for user messages
    @task.message = ""
    store.save(@task)
  else
    # Prepare error message
    @task.message << " " + "Not saved."
    session[:message] = @task.message # use session[:message] for user messages
    @task.message = ""
  end
  redirect '/'
end
