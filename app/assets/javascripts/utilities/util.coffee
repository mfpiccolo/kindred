class App.Util

  @snake_case_camel_keys: (obj) ->
    # Stupid hack because jQuery converts data to camelCase
    keys = Object.keys(obj)
    n = keys.length
    newobj = {}
    while n--
      key = keys[n]
      snake_key = key.replace(/([A-Z])/g, ($1) ->
        "_" + $1.toLowerCase()
        )
      newobj[snake_key] = obj[key]

    newobj
