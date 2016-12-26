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
  session[:message] = "" # clear message after being used
  session[:overlong_description] = nil # ditto
  @tasks = store.all.reject {|task| task.categories["completed"] == true}
  @pg_type = 'index' # for use formatting task_table
  erb :index #, user_message => {:user_message => params[:user_message]}
end

get('/index.html') do
  redirect '/'
end

get('/completed') do
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  session[:message] = "" # clear message after being used
  @tasks = store.all.reject {|task| task.categories["completed"] == false}
  @pg_type = 'completed'
  erb :completed
end

post('/check_completed/:id') do
  store.move_to_completed(params[:id].to_i)
  p "request.path  = #{request.path}"
  p "request.accept  = #{request.accept}"
  p "request.script_name  = #{request.script_name}"
  p "request.path_info  = #{request.path_info}"
  p "request.host  = #{request.host}"
  p "request.url  = #{request.url}"
  p params
  puts "YOOOOOOOO!!!!! page type = #{params['pg_type']}"
  redirect "/#{params[:pg_type]}"
end

post('/uncheck_completed/:id') do
  store.move_to_index(params[:id].to_i)
  p "request.script_name  = #{request.script_name}"
  puts "Params are #{params}"
  puts "YOOOOOOOO!!!!! page type = #{params[:pg_type]}"
  redirect "/#{params[:pg_type]}"
end

post('/delete/:id') do
  store.delete(params[:id].to_i)
  session[:message] << " " + "Deleted task!"
  p params
  puts "params[:id] = #{params[:id]}"
  puts "YOOOOOOOO!!!!! page type = #{params[:pg_type]}"
  redirect "/" if params[:pg_type] == "index"
  redirect params[:pg_type]
end

post('/newtask') do
  @task = Task.new(store, params)
  # decide whether to save & prepare user messages
  if @task.ok == true # task is ok!
    @task.message << " " + "Task saved!"
    session[:message] = @task.message # use session[:message] for user messages
    @task.message = ""
    store.save(@task)
  else
    @task.message << " " + "Not saved." # task not ok
    session[:message] = @task.message # use session[:message] for user messages
    session[:overlong_description] = @task.overlong_description if
      @task.overlong_description
    @task.message = ""
    @task.overlong_description = nil
  end
  redirect '/'
end
