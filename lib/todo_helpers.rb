# prepare list of displayable categories for user consumption
def compile_categories(tasks)
  display_categories = []
  tasks.each do |task|
    next if task.categories["deleted"] == true
    next if task.categories["completed"] == true
    task.categories.each_key do |cat|
      display_categories << cat unless display_categories.include?(cat)
    end
  end
  display_categories.reject! do |cat|
    (cat == "completed" || cat == "deleted" || cat == nil)
  end
  return display_categories
end
