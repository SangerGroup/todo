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

  def all
    @store.transaction do
      @store.roots.map { |id| @store[id] }
    end # the mapped array is returned by the block and thus by .transaction
  end

  # returns an array of all task IDs
  def ids
    @store.transaction do
      @store.roots
    end
  end

end
