class App.Setup
  constructor: (@opts) ->
    @_set_name_properties()
    @_set_self()

    @opts ||= {}

    @attributes = {}
    template = @opts.template || App[@constructor.name].template

    @_set_opts_to_attributes()

    @_setup_route()

    @uuid = @opts.uuid || @attributes.uuid || App.UUID.generate()
    @id = @opts.id || @attributes.id
    @target_uuid = @opts.target_uuid || @attributes.target_uuid

    @attributes["uuid"] = @uuid

    if template?
      @template = template.replace(/\b(data-k-uuid)\.?[^\s|>]+/g, "data-k-uuid=" + @uuid)
      @template = @template.replace(/\b(data-id)\.?[^\s|>]+/g, "data-id=" + @id)
      @_build_attrs_template()
      @_setup_interpolated_vars()

  @set_class_name: (class_name) ->
    @class_name = class_name
    @dash_name =  @_get_dash_name(class_name)
    @snake_name = @_get_snake_name(class_name)

  @_get_class_name: ->
    @name

  @_get_dash_name: (name) ->
    dash_str = name.replace /([A-Z])/g, ($1) ->
      "-" + $1.toLowerCase()
    dash_str[1 .. dash_str.length - 1]

  @_get_snake_name: (name) ->
    under_str = name.replace /([A-Z])/g, ($1) ->
      "_" + $1.toLowerCase()
    under_str[1 .. under_str.length - 1]

  _set_self: ->
    @_self = @

  _set_name_properties: =>
    @class_name ||= App[@constructor.name].class_name
    @dash_name =  App[@constructor.name]._get_dash_name(@class_name)
    @snake_name = App[@constructor.name].snake_name

  _build_attrs_template: ->
    $.each @attributes, (attr, val) =>
      j_attr = $(@template).find("[data-k-uuid='" + @uuid + "'][data-attr='" + attr + "']")
      clone = j_attr.clone()

      replace_string = clone.wrap('<span/>').parent().html()

      cloned_template = $(@template).clone()
      updated_template = $("<div />").append($(@template).clone()).html()

      if replace_string? && replace_string.length
        replace_regex = new RegExp(replace_string)

        new_attr_string = replace_string.replace(/\b(data-val)\.?[^\s]+/g, "data-val='" + val + "'")

        @template = updated_template.replace(replace_regex, new_attr_string)

  _setup_interpolated_vars: =>
    template_match = new RegExp(/{{([^{}]+)}}/g)

    new_template = @template.replace(template_match, (match, p1) =>
      class_name = match.split(".")[0].substr(2)
      attribute = match.split(".")[1].slice(0, - 2)

      if class_name == @snake_name && (typeof @get(attribute) != 'undefined')
        @get(attribute)
      else
        match
    )

    @template = new_template

  _set_opts_to_attributes: ->
    if @opts?
      $.each @opts, (key, val) =>
        @set key, val

  _setup_route: =>
    url_match = new RegExp(/{{([^{}]+)}}/g)
    @route ||= App[@constructor.name].route
    @route ||= "/" + @snake_name + "s"
    @route = @route.replace(url_match, (match, p1) =>
      attribute = match.slice(2, - 2)
      @get(attribute)
    )
