class Task
  attr_accessor :id, :position, :description, :date_added, :date_due,
    :categories, :message, :complete, :overlong_description

  def initialize(store, params)
    @id = assign_id(store.ids)
    @complete = true # by default
    @message = ""
    @description = params["description"]
    unless check_description(@description) == "ok"
      # this outputs an error message for the user
      @message << " " + check_description(@description)
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
    if description.length > 140
      @overlong_description = description
      return "Description was #{description.length} characters long; cannot exceed 140."
    end
    # Otherwise "ok"
    return "ok"
  end

end
