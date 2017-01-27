require './lib/task_store.rb'
# prepare list of displayable categories for user consumption
def compile_categories(tasks)
  display_categories = []
  tasks.each do |task|
    next if (task.categories["deleted"] == true ||
      task.categories["completed"] == true)
    task.categories.each_key do |cat|
      display_categories << cat unless display_categories.include?(cat)
    end
  end
  display_categories.reject! do |cat|
    (cat == "completed" || cat == "deleted" || cat == nil)
  end
  return display_categories
end

# first get method working for post /newtask
def judge_and_maybe_save(store, task)
  if task.ok == true # task is ok!
    task.message << " " + "Task saved!"
    session[:message] = task.message # use session[:message] for user messages
    task.message = ""
    store.save(task)
    session[:id_to_edit] = nil # exits from editing mode
  else
    task.message << " " + "Not saved." # task not ok
    session[:message] = task.message # use session[:message] for user messages
    session[:overlong_description] = task.overlong_description if
      task.overlong_description
    session[:bad_categories] = task.bad_categories if
      task.bad_categories
    task.message = ""
    task.overlong_description = nil
    task.bad_categories = nil
  end
end

def delete_forever_all(store, to_delete)
  # examine array of tasks to delete; delete each permanently from store
  to_delete.each { |task| store.delete_forever(task.id) }
  return store # Note!
end

def new_account_valid(users)
  account_valid = true # until proven false
  # validate email
  unless validate_email(params[:email])
    # if email doesn't validate, appropriate message appears on page
    session[:email_message] = "Sorry, check the email address."
    session[:bad_email] = params[:email]
    account_valid = false
  end
  # validate password
  unless validate_pwd(params[:password]) == true # error msg is truthy but not true!
    # if pwd doesn't validate, appropriate message appears on page
    session[:pwd_message] = validate_pwd(params[:password])
    session[:bad_email] = params[:email] # not actually bad here, necessarily
    account_valid = false
  end
  # validate password match
  unless passwords_match(params[:password], params[:password_again])
    # if no match, appropriate message appears on page
    session[:no_match_message] = "Sorry, those passwords don't match. Try again."
    session[:bad_email] = params[:email] # not actually bad here, necessarily
    account_valid = false
  end
  # check that email isn't a duplicate
  unless email_not_duplicate(params[:email], users)
    session[:email_message] = "That email has an account already. "\
      "<a href=\"/login\">Login?</a>"
    session[:bad_email] = params[:email]
    account_valid = false
  end
  return account_valid
end

# simply validates email; returns true if valid and false if not
def validate_email(email)
  email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i ?
    (return true) : (return false)
end

# returns true if password validates; returns error msg otherwise
def validate_pwd(pwd)
  message = ""
  message << "Password must have at least 8 characters. " unless
    pwd.length > 7
  message << "Password must have at least one number. " unless
    /\d/.match(pwd)
  message << "Password must have at least one letter. " unless
    /[[:alpha:]]/.match(pwd)
  message == "" ? (return true) : (return message)
end

def passwords_match(pwd1, pwd2)
  pwd1 == pwd2 ? true : false
end

# Determine highest ID; assign ID + 1 to this object
def assign_user_id(users)
  highest_id = users.ids.max || 100 # reserve first 100 ids for testing
  return highest_id + 1
end

# returns true if no duplicate; false if duplicate found
def email_not_duplicate(email, users)
  return false if users.all.find {|user| user.email == email}
  return true
end
