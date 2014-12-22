class App.Listener
  # Create a closure so that we can define intermediary
  # method pointers that don't collide with other items
  # in the global name space.
  (->
    # Store a reference to the original remove method.
    originalOnMethod = jQuery.fn.on

    # Define overriding method.
    jQuery.fn.on = ->
      if (jQuery.type( arguments[0] ) == "string")
        listener_function = arguments[2]
        element = arguments[1]

        listener_namespace = arguments[0].split(".")
        event_trigger = listener_namespace[0]
        listener_name = listener_namespace[listener_namespace.length - 1]
        namespaces = listener_namespace.slice(1, -1)

        listener_info = {
          trigger: event_trigger,
          element: element,
          name: listener_name,
          funct: listener_function
        }

        App.Listener.createNestedObject(App, namespaces, listener_info)

        # Execute the original method.
        originalOnMethod.apply this, arguments

      else
        originalOnMethod.apply this, arguments
  )()

  @createNestedObject = (base, names, value) ->

    # If a value is given, remove the last name and keep it for later:
    lastName = (if arguments.length is 3 then names.pop() else false)

    # Walk the hierarchy, creating new objects where needed.
    # If the lastName was removed, then the last object is not set yet:
    i = 0

    while i < names.length
      base = base[names[i]] = base[names[i]] or {}
      i++

    # If a value was given, set it to the last name:
    if Array.isArray(base[lastName])
      base[lastName].push(value)
    else
      base[lastName] = [value]

    # Return the last object in the hierarchy:
    base

  @params: (obj) ->
    # Stupid hack because jQuery converts data to camelCase
    keys = Object.keys(obj)
    n = keys.length
    newobj = {}
    while n--
      key = keys[n]

      if keys[n] == "kUuid"
        snake_key = "uuid"
      else
        snake_key = key.replace(/([A-Z])/g, ($1) ->
          "_" + $1.toLowerCase()
          )
      newobj[snake_key] = obj[key]

    newobj
