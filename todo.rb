require 'sinatra'
require './lib/task'
require './lib/task_store'
enable :sessions

store = TaskStore.new('tasks.yml')

get('/') do |*user_message|
  erb :index, user_message => {:user_message => params[:user_message]}
end

post('/newtask') do
  @task = Task.new(store, params)
  # decide whether to save & prepare user messages
  if @task.complete == true
    @task.message << " " + "Task saved!"
    user_message = @task.message
    store.save(@task)
  else
    # Prepare error message
    @task.message << " " + "Not saved."
    user_message = @task.message
  end
  redirect '/'
end
