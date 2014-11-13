App.DataBinder = (object_id, model_name) ->
  # Use a jQuery object as simple PubSub
  pubSub = jQuery({})

  # We expect a `data` element specifying the binding
  # in the form: data-bind-<object_id>="<property_name>"
  data_attr = "input"
  message = object_id + ":change"

  jQuery(document).on "keydown", "[data-input]", (evt) ->
    $input = jQuery(this)
    pubSub.trigger message, [
      $input.data(data_attr)
      $input.val()
    ]

  # PubSub propagates changes to all bound elements, setting value of
  # input tags or HTML content of other tags
  pubSub.on message, (evt, prop_name, new_val, id) ->
    # model_name = "purchase-order"
    model_elem = jQuery("[data-model-" + model_name + "=" + object_id + "]")

    attr_elm = model_elem.find("[data-attr=" + prop_name + "]")
    input_elm = $("[data-input=" + prop_name + "]")

    input_elm.val new_val
    attr_elm.html new_val

  pubSub
