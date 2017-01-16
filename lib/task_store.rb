require 'yaml/store'
# require 'dropbox'
# dbx = Dropbox::Client.new(ENV['DROPBOX_ACCESS_TOKEN'])
# folder = dbx.create_folder('/myfolder') # => Dropbox::FolderMetadata
# folder.id

class TaskStore

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

  # move item to deleted page
  def delete_task(id)
    @store.transaction do
      @store[id].categories["deleted"] = true
    end
  end

  # move item to deleted page
  def undelete_task(id)
    @store.transaction do
      @store[id].categories["deleted"] = false
    end
  end

  # delete item entirely
  def delete_forever(id)
    @store.transaction do
      @store.delete(id)
    end
  end

  # add task to 'completed'
  def move_to_completed(id)
    @store.transaction do
      @store[id].categories["completed"] = true
    end
  end

  # remove task from 'completed'
  def move_to_index(id)
    @store.transaction do
      @store[id].categories["completed"] = false
    end
  end

end
