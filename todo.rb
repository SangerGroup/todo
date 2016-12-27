require 'bundler'
require 'bundler/setup'
require 'sinatra'

require './lib/task'
require './lib/task_store'
require './lib/todo_helpers'
enable :sessions

store = TaskStore.new('tasks.yml')

get('/') do |*user_message|
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  @overlong_description = session[:overlong_description] if
    session[:overlong_description]
  @bad_categories = session[:bad_categories] if
    session[:bad_categories]
  session[:message] = "" # clear message after being used
  session[:overlong_description] = "" # ditto
  session[:bad_categories] = "" # ditto
  @tasks = store.all
  @display_categories = compile_categories(@tasks)
  puts "DISPLAY CATEGORIES ARE #{@display_categories}"
  @tasks.reject! do |task|
    (task.categories["completed"] == true ||
    task.categories["deleted"] == true)
  end
  # prepare complete list of categories to show in list
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
  @tasks = store.all
  # prepare complete list of categories to show in list
  @display_categories = compile_categories(@tasks)
  @tasks.reject! do |task|
    (task.categories["completed"] == false ||
    task.categories["deleted"] == true)
  end
  @pg_type = 'completed'
  erb :completed
end

get('/deleted') do
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  session[:message] = "" # clear message after being used
  @tasks = store.all
  # prepare complete list of categories to show in list
  @display_categories = compile_categories(@tasks) # compile before tossing some
  @tasks.select! {|task| task.categories["deleted"] == true}
  @pg_type = 'deleted'
  erb :deleted
end

post('/check_completed/:id') do
  store.move_to_completed(params[:id].to_i)
  redirect "/" if params[:pg_type] == "index"
  redirect "/category/#{params[:cat_page]}" if params[:pg_type] == "category"
  redirect "/#{params[:pg_type]}"
end

post('/uncheck_completed/:id') do
  store.move_to_index(params[:id].to_i)
  redirect "/category/#{params[:cat_page]}" if params[:pg_type] == "category"
  redirect "/#{params[:pg_type]}"
end

post('/delete/:id') do
  store.delete_task(params[:id].to_i)
  session[:message] << " " + "Deleted task!"
  redirect "/" if params[:pg_type] == "index"
  redirect "/category/#{params[:cat_page]}" if params[:pg_type] == "category"
  redirect params[:pg_type]
end

post('/undelete/:id') do
  store.undelete_task(params[:id].to_i)
  session[:message] << " " + "Undeleted task!"
  redirect "/" if params[:pg_type] == "index"
  redirect params[:pg_type]
end

post('/perma_delete/:id') do
  store.delete_forever(params[:id].to_i)
  session[:message] << " " + "Permanently deleted task!"
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
    session[:bad_categories] = @task.bad_categories if
      @task.bad_categories
    @task.message = ""
    @task.overlong_description = nil
    @task.bad_categories = nil
  end
  redirect '/'
end

get('/category/:cat_page') do
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  session[:message] = "" # clear message after being used
  @cat_page = params['cat_page'] # name of page to fetch
  @pg_type = 'category' # so task_table knows page type
  puts "CAT PAGE = #{@cat_page}, PAGE TYPE = #{@pg_type}"
  @tasks = store.all
  # don't show completed or deleted
  @tasks.reject! do |task|
    (task.categories["completed"] == true || task.categories["deleted"] == true)
  end
  # prepare complete list of categories to show in list
  @display_categories = compile_categories(@tasks)
  # show only tasks that include @cat_page as a category
  @tasks.select! { |task| task.categories.has_key?(@cat_page) }
  if @display_categories.include?(@cat_page)
    erb :categories
  else
    redirect '/'
  end
end
