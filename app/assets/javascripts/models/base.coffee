class App.Base
  constructor: (@opts) ->
    @opts ||= {}

    dash_str = @constructor.name.replace /([A-Z])/g, ($1) ->
      "-" + $1.toLowerCase()
    @model_name = dash_str[1 .. dash_str.length - 1]

    # @binder = new App.DataBinder(@id, @model_name)
    @attributes = {}
    template = @opts.template || App[@constructor.name].template

    if @opts.attrs?
      $.each @opts.attrs, (key, val) =>
        @set key, val

    @uuid = @opts.uuid || @attributes.uuid || App.UUID.generate()
    @id = @opts.id || @attributes.id

    @attributes["uuid"] = @uuid

    if template?
      @template = template.replace(/\b(data-k-uuid)\.?[^\s|>]+/g, "data-k-uuid=" + @uuid)
      @template = @template.replace(/\b(data-id)\.?[^\s|>]+/g, "data-id=" + @id)
      @build_attrs_template()

  @set_template: (template) ->
    @template = template

  @collection_from_page: (model_name) ->
    indices = $("[data-kindred-model]").find("[data-k-uuid][data-class='#{model_name}']")
    uuids = []

    indices.map (i, tag) ->
      uuids.push($(tag).data("k-uuid"))

    # map args for JS array seem to differ from jQuery array above
    collection_attrs = uuids.map (uuid, i) ->
      new App.LineItem({uuid: uuid}).assign_attributes_from_page().attributes

  # The attribute setter publish changes using the DataBinder PubSub
  set: (attr_name, val) ->
    @attributes[attr_name] = val
    # @binder.trigger @id + ":change", [
    #   attr_name
    #   val
    #   @
    # ]

  get: (attr_name) ->
    @attributes[attr_name]

  handle_errors: (errors_obj, uuid) ->
    if @error?
      hideable_error_inputs = $(Object.keys(@attributes)).not(Object.keys(errors_obj)).get()
      $.each hideable_error_inputs, (i, attr) =>
        $("[data-error][data-attr='" + attr + "'][data-k-uuid='" + @uuid + "']").hide()

      $.each errors_obj, (attr, messages) =>
        error_tag = $("[data-error][data-attr='" + attr + "'][data-k-uuid='" + @uuid + "']")
        error_tag.html("")

        $.each messages, (i, message) ->
          error_tag.append("<span>" + message + "</span><br>")

        error_tag.show()
    else
      $.each @attributes, (attr, val) =>
        $("[data-error][data-attr='" + attr + "'][data-k-uuid='" + @uuid + "']").hide()

  save: ->
    @route ||= @model_name.replace("-", "_") + "s"
    if !isNaN(parseFloat(@id)) && isFinite(@id)

      # TODO REMOVE THIS AFTER WEBKIT BUG FIX. https://github.com/thoughtbot/capybara-webkit/issues/553
      # This conditonal is for testing but there is no easy fix at the moment.
      # Put passes through data.  Patch dosn't.
      if (userAgent = window?.navigator?.userAgent).match /capybara-webkit/ || userAgent.match /PhantomJS/
        url = "/" + @route + "/" + @id + ".json"
        method = 'PUT'
      else
        url = "/" + @route + "/" + @id + ".json"
        method = 'PATCH'
    else
      url = "/" + @route + ".json"
      method = "POST"

    params = {}
    params[@model_name.replace("-", "_")] = @attributes

    response = $.ajax(
      type: method
      url: url
      dataType: "json"
      data: params
      global: false
      async: false
      success: (data, textStatus, xhr) ->
        xhr.status
      error: (xhr) =>
        @error = xhr.status
    ).responseText

    obj = JSON.parse(response)
    @set_attributes(obj)

    @handle_errors(obj)

    unless @error?
      @update_data_vals()

  destroy: ->
    @route ||= @model_name.replace("-", "_") + "s"
    url = "/" + @route + "/" + @id + ".json"
    method = "DELETE"

    if !isNaN(parseFloat(@id)) && isFinite(@id)
      $.ajax
        type: method
        url: url
        dataType: "json"
        global: false
        async: false

  set_attributes: (attrs) ->
    $.each attrs, (attr, val) =>
      if attr == "id" && !isNaN(parseFloat(val)) && isFinite(val)
        @id = val
      @set(attr, val)

  append_to_page: ->
    $template = $(@template)
    $.each @attributes, (key, value) =>
      input = $($template).find("input[data-attr='" + key + "']")
      if input.length
        input = $template.find("input[data-attr='" + key + "']")
        input.val(value)

    @append_data_model()

    $("[data-append='" + @model_name + "']").append($template)

    unless @error?
      error_tag = $("[data-error][data-k-uuid='" + @uuid + "']")
      error_tag.hide()

  assign_attributes_from_page: ->
    $("input[data-k-uuid='" + @uuid + "']").each (i, input) =>
      $input = $(input)
      @set $input.data("attr"), $input.val()

      model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
      if !isNaN(parseFloat(model_data.data("id"))) && isFinite(model_data.data("id"))
        @id = model_data.data("id")
    @

  build_attrs_template: ->
    $.each @attributes, (attr, val) =>
      j_attr = $(@template).find("input[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']")
      clone = j_attr.clone()

      replace_string = clone.wrap('<span/>').parent().html()

      cloned_template = $(@template).clone()
      updated_template = $("<div />").append($(@template).clone()).html()


      if replace_string? && replace_string.length
        replace_regex = new RegExp(replace_string)

        new_attr_string = replace_string.replace(/\b(data-val)\.?[^\s]+/g, "data-val='" + val + "'")

        @template = updated_template.replace(replace_regex, new_attr_string)

  dirty: ->
    dirty = []
    $.each $("input[data-k-uuid='" + @uuid + "']"), (i, attr) =>
      dirty_object = {}
      unless $(attr).data("val").toString() == $(attr).val().toString()
        dirty.push(dirty_object[attr] = [$(attr).data("val").toString(), $(attr).val().toStrin])

    if dirty.length
      true
    else
      false

  update_data_vals: ->
    model_data = $("[data-kindred-model]").find("[data-k-uuid='" + @uuid + "']")
    model_data.data("id", @id)
    $.each @attributes, (attr, val) =>
      $("input[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']").data("val", val)

  append_data_model: ->
    model_div = "<div data-k-uuid=" + @uuid + " data-id=" + @id + " data-class=" + @model_name.replace("-", "_") + " data-parent-type=" + @parent + " data-parent-id=" + @parent_id + "></div>"
    $("[data-kindred-model]").append(model_div)
