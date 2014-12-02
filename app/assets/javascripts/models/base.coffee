class App.Base extends App.VirtualClass App.ActivePage, App.Setup

  @set_template: (template) ->
    @template = template

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
        url = @route + "/" + @id + ".json"
        method = 'PUT'
      else
        url = @route + "/" + @id + ".json"
        method = 'PATCH'
    else
      url = @route + ".json"
      method = "POST"

    params = {}
    params[@snake_name] = @attributes

    response = $.ajax
      type: method
      url: url
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
          @after_destory(data, textStatus, xhr)
        error: (xhr) =>
          @after_destroy_error(xhr)
    else
      @remove_errors_from_page()

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

  #overwritable hook
  after_save_error: (xhr) ->
    errors = JSON.parse(xhr.responseText)
    @_handle_errors(errors)

  #overwritable hook
  after_destory: (data, textStatus, xhr) ->
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
