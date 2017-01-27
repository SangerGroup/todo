require 'bundler'
require 'bundler/setup'
require 'sinatra'
require 'yaml'

require './lib/task'
require './lib/task_store'
require './lib/todo_helpers'
require './lib/users'
require './lib/user_store'
enable :sessions

store = TaskStore.new('tasks.yml')
users = UserStore.new('users.yml')

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
  judge_and_maybe_save(store, @task)
  redirect '/'
end

post('/start_edit/:id') do
  session[:id_to_edit] = params[:id].to_i
  redirect "/" if params[:pg_type] == "index"
  redirect params[:pg_type]
end

post('/submit_edit/:id') do
  params[:id] = params[:id].to_i
  @task = Task.new(store, params)
  session[:id_to_edit] = params[:id] # prepare data for possible re-editing
  judge_and_maybe_save(store, @task)
  redirect "/" if params[:pg_type] == "index"
  redirect params[:pg_type]
end

post('/delete_all') do
  # note, this prepares a deletion list before calling #delete_forever_all
  # to allow the test script to delete just tested items
  to_delete = store.all.find_all {|task| task.categories["deleted"] == true}
  before_length = store.all.length
  store = delete_forever_all(store, to_delete)
  session[:message] = "Deleted all tasks!" if before_length > store.all.length
  redirect '/deleted'
end

post('/submit_new_account') do
  # simplifies route method by validating in todo_helpers.rb
  new_account_valid(users)
  # create account: assign id and save email & password in account store
  if new_account_valid(users)
    id = assign_user_id(users)
    user = User.new(params[:email], params[:password], id)
    users.save(user)
  end
  # check if email is already in store
  # NEXT: if all validates, create account & redirect to login
  redirect "/create_account"
end

# This is kind of complicated because it is used for (1) presenting the task
# list, (2) passing parameters for editing, and (3) passing parameters for when
# the user wants to
get('/') do
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  session[:message] = "" # clear message after being used
  # prepare page for editing if in editing mode
  if session[:id_to_edit]
    @id_to_edit = session[:id_to_edit]
    @editing_mode = true
    session[:id_to_edit] = nil # clear id_to_edit after use
  else # otherwise, check for error messages
    @editing_mode = false
    @overlong_description = session[:overlong_description] if
      session[:overlong_description]
    @bad_categories = session[:bad_categories] if
      session[:bad_categories]
    session[:overlong_description] = "" # ditto
    session[:bad_categories] = "" # ditto
  end
  @tasks = store.all
  @all_tasks = @tasks.clone.reject {|task| task.categories["completed"] == true ||
    task.categories["deleted"] == true}
  @display_categories = compile_categories(@tasks)
  @tasks.reject! do |task|
    (task.categories["completed"] == true ||
    task.categories["deleted"] == true)
  end
  # prepare complete list of categories to show in list
  @pg_type = 'index' # for use formatting task_table
  erb :index
end

get('/index.html') do
  redirect '/'
end

get('/completed') do
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  session[:message] = "" # clear message after being used
  @tasks = store.all
  @all_tasks = @tasks.clone.reject {|task| task.categories["completed"] == true ||
    task.categories["deleted"] == true}
 # for e.g. the number of items in tags
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
  @all_tasks = @tasks.clone.reject {|task| task.categories["completed"] == true ||
    task.categories["deleted"] == true}
 # for e.g. the number of items in tags
  # prepare complete list of categories to show in list
  @display_categories = compile_categories(@tasks) # compile before tossing some
  @tasks.select! {|task| task.categories["deleted"] == true}
  @pg_type = 'deleted'
  erb :deleted
end

get('/create_account') do
  # prepare erb messages for email errors
  if session[:email_message] # always about bad email
    @email_message = session[:email_message]
    session[:email_message] = nil
    @bad_email = session[:bad_email]
    session[:bad_email] = nil
  end
  # prepare erb messages for password errors
  if session[:pwd_message]
    @pwd_message = session[:pwd_message]
    session[:pwd_message] = nil
    @bad_email = session[:bad_email] if session[:bad_email]
    session[:bad_email] = nil
  end
  # prepare erb message for no-match
  if session[:no_match_message]
    @no_match_message = session[:no_match_message]
    session[:no_match_message] = nil
    @bad_email = session[:bad_email] if session[:bad_email]
    session[:bad_email] = nil
  end
  erb :create_account
end

get('/category/:cat_page') do
  # prepare erb messages
  @user_message = session[:message] if session[:message]
  session[:message] = "" # clear message after being used
  @cat_page = params['cat_page'] # name of page to fetch
  @pg_type = 'category' # so task_table knows page type
  @tasks = store.all
  @all_tasks = @tasks.clone.reject {|task| task.categories["completed"] == true ||
    task.categories["deleted"] == true}
  # for e.g. the number of items in tags
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

get('/login') do
  erb :login
end
