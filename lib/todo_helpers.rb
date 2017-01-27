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
