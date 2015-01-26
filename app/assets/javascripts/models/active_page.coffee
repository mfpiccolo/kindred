class App.ActivePage

  @collection_from_page: ->
    indices = $("[data-kindred-model]").find("[data-k-uuid][data-class='#{@snake_name}']")
    uuids = []

    indices.map (i, tag) ->
      uuids.push($(tag).data("k-uuid"))

    # map args for JS array seem to differ from jQuery array above
    collection_attrs = uuids.map (uuid, i) =>
      new @({uuid: uuid}).assign_attributes_from_page().attributes

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

  remove_from_page: ->
    $("[data-wrapper][data-k-uuid='" + @uuid + "']").remove()
    $("[data-kindred-model]").find("div[data-k-uuid='" + @uuid + "']").remove()

  update_vals_on_page: ->
    $.each @attributes, (attr, val) =>
      $("[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").val(val)

  update_displays_on_page: ->
    $.each @attributes, (attr, val) =>
      # TODO make this work with span and p
      $("div[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "'], span[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "'], p[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").html(val)

  update_meta_on_page: ->
    $("[data-kindred-model]").find("div[data-k-uuid='" + @uuid + "']").data("meta", @meta)

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

  remove_errors_from_page: ->
    $("[data-error][data-k-uuid='" + @uuid + "']").each (i, elem) =>
      $(elem).remove()

  _update_data_vals_on_page: ->
    model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
    model_data.data("id", @id)
    $.each @attributes, (attr, val) =>
      $("[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").data("val", val)

  _append_data_model_to_page: ->
    model_div = "<div data-k-uuid=" + @uuid + " data-id=" + @id + " data-class=" + @snake_name + " data-meta=" + @_stringified_meta() + " ></div>"
    $("[data-kindred-model]").append(model_div)

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
