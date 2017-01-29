require 'yaml/store'
# require 'dropbox'
# dbx = Dropbox::Client.new(ENV['DROPBOX_ACCESS_TOKEN'])
# folder = dbx.create_folder('/myfolder') # => Dropbox::FolderMetadata
# folder.id

class TaskStore

  attr_accessor :path

  # The ID is the passed user ID; needed to build path to userdata file
  def initialize(*id)
    id = id[0] # splat arguments are arrays...
    @path = determine_path(id)
    @store = YAML::Store.new(@path)
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

  def determine_path(*id)
    id = id[0]
    if id.nil?
      tmp_id = get_tmp_id
      return "./tmp/#{tmp_id}.yml" # if no ID was passed, pick a random num
    else
      return "./userdata/#{id}.yml" # if an ID was passed, assign /userdata path
    end
  end

  def get_tmp_id
    sleep 0.1
    tmp_list = Dir.glob("tmp/*").map do |filename|
      sleep 0.1
      File.basename(filename).to_i
      sleep 0.1
    end
    return 1 if tmp_list.empty?
    return (tmp_list.max + 1)
  end

  # for use in logging out
  def delete_path
    self.remove_instance_variable(:@path)
  end

end
