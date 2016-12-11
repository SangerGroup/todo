require 'yaml/store'

class TaskStore

  attr_accessor :ids

  def initialize(file_name)
    @store = YAML::Store.new(file_name)
  end

  # saves a new task to the YAML store under the task.rb-assigned id
  def save(task)
    @store.transaction do
      @store[task.id] = task
    end
  end

  def ids
    @store.transaction do
      @store.roots
    end
  end

end
