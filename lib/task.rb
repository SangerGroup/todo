class Task
  attr_accessor :id, :position, :description, :date_added, :date_due,
    :categories, :message, :complete

  def initialize(store, params)
    @id = assign_id(store.ids)
    @complete = true # by default
    @message = ""
    if check_description(params["description"]) == "ok"
      @description = params["description"]
    else
      # this outputs an error message for the user
      @message << " " + check_description(params["description"])
      @complete = false
    end
    @position = ""
    @date_added = ""
    @date_due = ""
    @categories = ""
  end

  # Determine highest ID; assign ID + 1 to this object
  def assign_id(all_ids)
    highest_id = all_ids.max || 0
    return highest_id + 1
  end

  # Description must be between 0 and 140 characters. Returns string.
  def check_description(description)
    # Return error message if description is blank.
    return "Description cannot be blank." if description == ""
    # Return error message if description is too long.
    return "Description was #{description.length} characters long; cannot exceed 140." if
      description.length > 140
    # Otherwise "ok"
    return "ok"
  end

end
