class App.Base
  constructor: (@id) ->
    dash_str = @constructor.name.replace /([A-Z])/g, ($1) ->
      "-" + $1.toLowerCase()
    @model = dash_str[1 .. dash_str.length - 1]

    @binder = new App.DataBinder(@id, @model)
    @attributes = {}

    # Subscribe to the PubSub
    @binder.on @id + ":change", (evt, attr_name, new_val, initiator) =>
      @set attr_name, new_val  if initiator isnt @

  # The attribute setter publish changes using the DataBinder PubSub
  set: (attr_name, val) ->
    @attributes[attr_name] = val
    @binder.trigger @id + ":change", [
      attr_name
      val
      @
    ]

  get: (attr_name) ->
    @attributes[attr_name]

  save: ->
    @route ||= @model.replace("-", "_") + "s"
    if @id?
      url = "/" + @route + "/" + @id + ".js"
    else
      url = "/" + @route + ".js"

    $.ajax
      url: url
      type: "PATCH"
      data: {
        @model.replace("-", "_"): @attributes,
      }

  set_attributes: (attrs) ->
    $.each attrs, (attr, val) =>
      @set(attr, val)
