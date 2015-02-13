class App.ActivePage

  # This class method will with find all the models on the dom that are of a
  # particular class.  Exapmle:
  # `App.LineItem.collection_from_page() # => [LineItemObject, LineItemObject]
  @collection_from_page: ->
    indices = $("[data-kindred-model]").find("[data-k-uuid][data-class='#{@snake_name}']")
    uuids = []

    indices.map (i, tag) ->
      uuids.push($(tag).data("k-uuid"))

    # map args for JS array seem to differ from jQuery array above
    collection_attrs = uuids.map (uuid, i) =>
      new @({uuid: uuid}).assign_attributes_from_page().attributes

  # If a model has a target_uuid and there is a corresponding element on the dom
  # with data-target and data-target-uuid="<specific-record-uuid>" this method
  # will append that models template to the target element.
  append_to_page: ->
    $template = $(@template)
    $.each @attributes, (key, value) =>
      input = $template.find("input[data-attr='" + key + "']")
      if input.length
        if input.is(':checkbox')
          input.prop('checked', value)
        else
          input.val(value)

      select = $template.find("select[data-attr='" + key + "']")
      if select.length
        select.val(value)

      display = $template.find("div[data-attr='" + key + "'], span[data-attr='" + key + "'], p[data-attr='" + key + "']")
      if display.length
        new_display = display.html(value)
        display.replaceWith(new_display)

    @_append_data_model_to_page()

    $("[data-target][data-target-uuid='" + @target_uuid + "']").append($template)

    error_tag = $("[data-error][data-k-uuid='" + @uuid + "']")
    error_tag.hide()

  # Removes the wrapper element and the model from the data-kindred-model store.
  remove_from_page: ->
    $("[data-wrapper][data-k-uuid='" + @uuid + "']").remove()
    $("[data-kindred-model]").find("div[data-k-uuid='" + @uuid + "']").remove()

  # Iterates through a modeals attributes and updates the values of the inputs or
  # selects based on the models attributes
  update_vals_on_page: ->
    $.each @attributes, (attr, val) =>
      $("[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").val(val)

  # A display attribute can be wrapped in a div, p, or span tag.  This method
  # will replace the contents of these tags with the corrosponding attributes
  # value
  update_displays_on_page: ->
    $.each @attributes, (attr, val) =>
      $("div[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "'], span[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "'], p[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").html(val)

  # Updtaes the meta data on the dom
  update_meta_on_page: ->
    $("[data-kindred-model]").find("div[data-k-uuid='" + @uuid + "']").data("meta", @meta)

  # Boolean method that will check if a page representation of a model is dirty
  # by checking if any of the values of the inputs and selects differ from the ones
  # originally added to the page
  dirty_from_page: ->
    dirty = []
    $.each $("input[data-k-uuid='" + @uuid + "'], select[data-k-uuid='" + @uuid + "']"), (i, input) =>
      $input = $(input)

      dirty_object = {}
      attr = $input.data("attr")

      if @_input_dirty($input)
        dirty.push(dirty_object[attr] = [$input.data("val").toString(), $input.val().toString()])

    if dirty.length
      true
    else
      false

  # This method will pull all the inputs with the specific model uuid and assign
  # the values to attributes.
  # Example:
  # html: <input data-attr="foo" data-k-uuid="long-uuid"> # user entered "bar"
  # js: li = App.LineItem.new({uudi: "long-uuid"});
  #     li.assign_attributes_from_page()
  #     li.attributes # => {uuid: "long-uuid", foo: "bar"}
  #     li.get("foo") # => "bar"
  assign_attributes_from_page: ->
    $("input[data-k-uuid='" + @uuid + "']").each (i, input) =>
      $input = $(input)

      if $input.is(':checkbox')
        @set $input.data("attr"), $input.prop('checked')
      else
        @set $input.data("attr"), $input.val()

    model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
    if !isNaN(parseFloat(model_data.data("id"))) && isFinite(model_data.data("id"))
      @id = model_data.data("id")

    @meta = model_data.data("meta")

    $("select[data-k-uuid='" + @uuid + "']").each (i, select) =>
      @set $(select).data("attr"), $(select).val()

    @

  # Cleans up error elements.  This method is only useful if you are not using
  # the wrapper element.
  remove_errors_from_page: ->
    $("[data-error][data-k-uuid='" + @uuid + "']").each (i, elem) =>
      $(elem).remove()

  # Used to update the data-val values when returned from a server.
  _update_data_vals_on_page: ->
    model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
    model_data.data("id", @id)
    $.each @attributes, (attr, val) =>
      $("[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").data("val", val)

  # Adds a model to the data model on page store.  This should probably be converted
  # over to using local storage or some other browser store.
  _append_data_model_to_page: ->
    model_div = "<div data-k-uuid=" + @uuid + " data-id=" + @id + " data-class=" + @snake_name + " data-meta=" + @_stringified_meta() + " ></div>"
    $("[data-kindred-model]").append(model_div)

  # Checks if a particular jquery inputs data differes from the data-val
  _input_dirty: (input) ->
    if input.is("select") && input.data("val").length == 0
      false
    else if input.is(":checkbox")
      !(input.data("val").toString() == input.prop("checked").toString())
    else
      !(input.data("val").toString() == input.val().toString())

  _stringified_meta: ->
    if @meta?
      JSON.stringify(@meta)
    else
      ""
