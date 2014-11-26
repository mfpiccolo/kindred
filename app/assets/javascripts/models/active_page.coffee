class App.ActivePage

  @collection_from_page: ->
    indices = $("[data-kindred-model]").find("[data-k-uuid][data-class='#{@_get_snake_name()}']")
    uuids = []

    indices.map (i, tag) ->
      uuids.push($(tag).data("k-uuid"))

    # map args for JS array seem to differ from jQuery array above
    collection_attrs = uuids.map (uuid, i) ->
      new App.LineItem({uuid: uuid}).assign_attributes_from_page().attributes

  append_to_page: ->
    $template = $(@template)
    $.each @attributes, (key, value) =>
      input = $($template).find("input[data-attr='" + key + "']")
      if input.length
        input = $template.find("input[data-attr='" + key + "']")
        input.val(value)

    @_append_data_model_to_page()

    $("[data-append='" + @dash_name + "']").append($template)

    error_tag = $("[data-error][data-k-uuid='" + @uuid + "']")
    error_tag.hide()

  dirty_from_page: ->
    dirty = []
    $.each $("input[data-k-uuid='" + @uuid + "']"), (i, attr) =>
      dirty_object = {}
      unless $(attr).data("val").toString() == $(attr).val().toString()
        dirty.push(dirty_object[attr] = [$(attr).data("val").toString(), $(attr).val().toStrin])

    if dirty.length
      true
    else
      false

  assign_attributes_from_page: ->
    $("input[data-k-uuid='" + @uuid + "']").each (i, input) =>
      $input = $(input)
      @set $input.data("attr"), $input.val()

      model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
      if !isNaN(parseFloat(model_data.data("id"))) && isFinite(model_data.data("id"))
        @id = model_data.data("id")
    @

  _update_data_vals_on_page: ->
    model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
    model_data.data("id", @id)
    $.each @attributes, (attr, val) =>
      $("input[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").data("val", val)

  _append_data_model_to_page: ->
    model_div = "<div data-k-uuid=" + @uuid + " data-id=" + @id + " data-class=" + @snake_name + " data-parent-type=" + @parent + " data-parent-id=" + @parent_id + "></div>"
    $("[data-kindred-model]").append(model_div)
