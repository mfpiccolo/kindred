class App.Base extends App.VirtualClass App.ActivePage, App.Setup

  @set_template: (template) ->
    @template = template

  @save_all: (opts) ->
    data = {}
    # TODO fix the naive inflection
    collection = @collection_from_page(@snake_name)
    added_attrs = []

    $.each collection, (i, attrs) ->
      added_attrs.push($.extend attrs, opts.add_data_to_each)

    data[@snake_name + "s"] = added_attrs

    path = @route + "/save_all.json"

    $.ajax
      type: "PATCH"
      url: App.BaseUrl + "/" + path
      data: data

      success: (data, textStatus, xhr) =>
        $(data).each (i, response_object) =>
          attrs = response_object[@snake_name]
          model = new App[@class_name]({uuid: attrs["uuid"]})
          model.assign_attributes(attrs)
          model._clear_errors()
          model._update_data_vals_on_page()
          # TODO in demo app
          # model.mark_dirty_or_clean()
      error: (xhr) =>
        data = JSON.parse(xhr.responseText)
        $(data).each (i, response_object) =>
          unless $.isEmptyObject(response_object["errors"])
            uuid = response_object[@snake_name].uuid
            model = new App[@class_name](response_object[@snake_name])
            model.assign_attributes_from_page()
            model._handle_errors(response_object["errors"])

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

  save: ->
    if !isNaN(parseFloat(@id)) && isFinite(@id)

      # TODO REMOVE THIS AFTER WEBKIT BUG FIX. https://github.com/thoughtbot/capybara-webkit/issues/553
      # This conditonal is for testing but there is no easy fix at the moment.
      # Put passes through data.  Patch dosn't.
      if (userAgent = window?.navigator?.userAgent).match /capybara-webkit/ || userAgent.match /PhantomJS/
        path = @route + "/" + @id + ".json"
        method = 'PUT'
      else
        path = @route + "/" + @id + ".json"
        method = 'PATCH'
    else
      path = @route + ".json"
      method = "POST"

    params = {}
    params[@snake_name] = @attributes

    response = $.ajax
      type: method
      url: App.BaseUrl + "/" + path
      dataType: "json"
      data: params
      global: false
      async: false
      success: (data, textStatus, xhr) =>
        @after_save(data, textStatus, xhr)
      error: (xhr) =>
        @after_save_error(xhr)

  destroy: ->
    @route ||= @snake_name + "s"
    url = @route + "/" + @id + ".json"
    method = "DELETE"

    if !isNaN(parseFloat(@id)) && isFinite(@id)
      $.ajax
        type: method
        url: url
        dataType: "json"
        global: false
        async: false
        success: (data, textStatus, xhr) =>
          @after_destroy(data, textStatus, xhr)
        error: (xhr) =>
          @after_destroy_error(xhr)
    else
      @after_destroy()

  assign_attributes: (attrs) ->
    $.each attrs, (attr, val) =>
      if attr == "id" && !isNaN(parseFloat(val)) && isFinite(val)
        @id = val
      @set(attr, val)

  #overwritable hook
  after_save: (data, textStatus, xhr) ->
    @assign_attributes(data)
    @_clear_errors()
    @_update_data_vals_on_page()
    @_setup_interpolated_vars()

  #overwritable hook
  after_save_error: (xhr) ->
    errors = JSON.parse(xhr.responseText)
    @_handle_errors(errors)

  #overwritable hook
  after_destroy: (data, textStatus, xhr) ->
    @remove_errors_from_page()

  #overwritable hook
  after_destroy_error: (xhr) ->

  _handle_errors: (errors_obj, uuid) ->
    hideable_error_inputs = $(Object.keys(@attributes)).not(Object.keys(errors_obj)).get()
    $.each hideable_error_inputs, (i, attr) =>
      $("[data-error][data-attr='" + attr + "'][data-k-uuid='" + @uuid + "']").hide()

    $.each errors_obj, (attr, messages) =>
      error_tag = $("[data-error][data-attr='" + attr + "'][data-k-uuid='" + @uuid + "']")
      error_tag.html("")

      $.each messages, (i, message) ->
        error_tag.append("<span>" + message + "</span><br>")

      error_tag.show()

  _clear_errors: () ->
    $.each @attributes, (attr, val) =>
      $("[data-error][data-attr='" + attr + "'][data-k-uuid='" + @uuid + "']").hide()
