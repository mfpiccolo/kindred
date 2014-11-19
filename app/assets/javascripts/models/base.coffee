class App.Base
  constructor: (@opts) ->
    dash_str = @constructor.name.replace /([A-Z])/g, ($1) ->
      "-" + $1.toLowerCase()
    @model = dash_str[1 .. dash_str.length - 1]

    # @binder = new App.DataBinder(@id, @model)
    @attributes = {}
    template = @opts.template || App[@constructor.name].template

    if @opts.attrs?
      $.each @opts.attrs, (key, val) =>
        @set key, val

    @uuid = @opts.uuid || @attributes.uuid || App.UUID.generate()
    @id = @opts.id || @attributes.id

    @template = template.replace(/\b(data-adq-uuid)\.?[^\s]+/g, "data-adq-uuid=" + @uuid)
    @template = @template.replace(/\b(data-id)\.?[^\s]+/g, "data-id=" + @id)

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
    @route ||= @model.replace("-", "_") + "s"
    if !isNaN(parseFloat(@id)) && isFinite(@id)
      url = "/" + @route + "/" + @id + ".json"
      method = "PATCH"
    else
      url = "/" + @route + ".json"
      method = "POST"

    params = {}
    params[@model.replace("-", "_")] = @attributes

    JSON.parse $.ajax(
      type: method
      url: url
      dataType: "json"
      data: params
      global: false
      async: false
      success: (data, textStatus, xhr) ->
        { data: data, status: textStatus }
    ).responseText

  destroy: ->
    @route ||= @model.replace("-", "_") + "s"
    url = "/" + @route + "/" + @id + ".json"
    method = "DELETE"

    $.ajax
      type: method
      url: url
      dataType: "json"
      global: false
      async: false

  set_attributes: (attrs) ->
    $.each attrs, (attr, val) =>
      @set(attr, val)

  append_to_page: ->
    $template = $(@template)
    $.each @attributes, (key, value) =>
      input = $($template).find("input[data-attr='" + key + "']")
      if input.length
        input = $template.find("input[data-attr='" + key + "']")
        input.val(value)

    $("[data-append='" + @model + "']").append($template)

  assign_attributes_from_page: ->
    $("input[data-adq-uuid='" + @uuid + "']").each (i, input) =>
      $input = $(input)
      @set $input.data("attr"), $input.val()
      if $input.data("id")?
        @id = $input.data("id")
    @


